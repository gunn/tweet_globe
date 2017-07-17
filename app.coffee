fs      = require('fs')
path    = require('path')
connect = require('connect')
http    = require('http')

hbsTags = ()->
  tags = for name in ["chart", "index"]
    hbsTag(name)

  tags.join("\n")

hbsTag = (name)->
  template = path.join(__dirname, "assets/js/templates/#{name}.handlebars")
  """
  <script type="text/x-handlebars" data-template-name="#{name}">
    #{fs.readFileSync(template)}
  </script>
  """

requireHTTPS = (req, res, next)->
  if process.env.FORCE_SSL && req.headers['x-forwarded-proto'] != 'https'
     res.writeHead 301,
       'Content-Type': 'text/plain', 
       'Location':     'https://'+req.headers.host+req.url

     res.end 'Redirecting to SSL\n'
  else
    next()

app = connect()
  .use(requireHTTPS)

[getJs, getCss] =
  if process.env.NODE_ENV == "production"
    manifest = require "./public/assets/manifest.json"

    js  = (name)-> "<script src='/assets/#{manifest.assets[name+'.js']}'></script>"
    css = (name)-> "<link rel='stylesheet' href='/assets/#{manifest.assets[name+'.css']}'/>"
    [js, css]

  else
    app = app.use require('connect-assets')()
    [js, css]

app = app
  .use(require('serve-static')('public'))
  .use((req, res)->
    res.writeHead 200
    res.end """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Tweet Globe</title>
        #{getCss("application")}
      </head>
      <body>
        #{hbsTags()}
        #{getJs("application")}
      </body>
    </html>
    """
  ).listen(process.env.PORT || 1337)

console.log "Listening on port", (process.env.PORT || 1337)


class Tweet
  @buffer      : []
  @history     : []

  @bufferSize  : 20
  @historySize : 100
  @maxRate     : 8

  @add: (data)->
    @buffer.unshift new Tweet(data)

  @getLatest: ->
    removed = @buffer.splice(@bufferSize)
    @history = removed.concat(@history).slice(0, @historySize)

    latest = removed.slice(0, @maxRate)
    latest

  constructor: (data)->
    [lat, long] = data.geo.coordinates
    @coordinates = [long, lat]

    @text = data.text

    @screen_name = data.user.screen_name
    # @profile_image_url = data.user.profile_image_url
    @country = data.place?.country


twitter = new require('twitter')
  consumer_key        : process.env.CONSUMER_KEY
  consumer_secret     : process.env.CONSUMER_SECRET
  access_token_key    : process.env.ACCESS_TOKEN_KEY
  access_token_secret : process.env.ACCESS_TOKEN_SECRET

twitter.stream 'statuses/filter',
  locations: "-180,-90,180,90",
  (stream)->
    stream.on 'data', (data)->
      if data.geo?.coordinates?
        Tweet.add data

    stream.on 'error', (e)-> console.error e

io = require('socket.io').listen app

io.sockets.on 'connection', (socket)->
  socket.emit "news", Tweet.history

setInterval ->
  io.sockets.emit "news", Tweet.getLatest()
, 500

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

app = connect()
  .use(connect.logger('dev'))
  .use(require('connect-assets')())
  .use(connect.static('public'))
  .use((req, res)->
    res.writeHead 200
    res.end """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Tweet Globe</title>
        #{css("application")}
      </head>
      <body>
        #{hbsTags()}
        #{js("application")}
      </body>
    </html>
    """
  ).listen(process.env.PORT || 1337)


class Tweet
  @buffer      : []
  @history     : []

  @bufferSize  : 20
  @historySize : 100
  @maxRate     : 2

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
    @country = data.place?.country


ntwitter = new require('ntwitter')
  consumer_key        : process.env.CONSUMER_KEY
  consumer_secret     : process.env.CONSUMER_SECRET
  access_token_key    : process.env.ACCESS_TOKEN_KEY
  access_token_secret : process.env.ACCESS_TOKEN_SECRET

ntwitter.stream 'statuses/filter',
  locations: "-180,-90,180,90",
  (stream)->
    stream.on 'data', (data)->

      if data.geo?.coordinates?
        Tweet.add data


io = require('socket.io').listen app
io.set('log level', 0)

io.sockets.on 'connection', (socket)->
  socket.emit "news", Tweet.history

setInterval ->
  io.sockets.emit "news", Tweet.getLatest()
, 200

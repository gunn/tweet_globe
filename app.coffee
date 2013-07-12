fs      = require('fs')
path    = require('path')
connect = require('connect')
http    = require('http')

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
        <div class='container-fluid' id='content'>

        </div>
        #{hbsTags()}
        #{js("application")}
      </body>
    </html>
    """
  ).listen(process.env.PORT || 1337)

io = require('socket.io').listen app
io.set('log level', 0)

hbsTags = ()->
  tags = for name in ["application", "chart", "tweets"]
    hbsTag(name)

  console.log(tags, "!")
  tags.join("\n")


hbsTag = (name)->
  template = path.join(__dirname, "assets/js/templates/#{name}.handlebars")
  """
  <script type="text/x-handlebars" data-template-name="#{name}">
    #{fs.readFileSync(template)}
  </script>
  """

ntwitter = new require('ntwitter')
  consumer_key:        'gcnju0wIvzpwsbu7gdR2pA'
  consumer_secret:     'lGVCmvWRwgEG4RAqMUCS5xFhXRrKeBquGVTd0qRY'
  access_token_key:    '98638549-zuVhkvxPUV4CoIJXqE4EMhvmrgNg11rvhmoHPSYv4'
  access_token_secret: 'jpjXU0xXCUTh2LwF8HTzrxP0cvMd2uil2loNamhDk'

ntwitter.stream 'statuses/filter',
  locations: "-180,-90,180,90",
  (stream)->
    count = 0
    stream.on 'data', (data)->

      if data.geo?.coordinates? && ++count==4
        io.sockets.emit 'news', new Tweet(data)
        count = 0

class Tweet
  constructor: (data)->
    [@lat, @long] = data.geo.coordinates
    @text = data.text

    @screen_name = data.user.screen_name
    @name = data.user.name
    @country = data.place?.country


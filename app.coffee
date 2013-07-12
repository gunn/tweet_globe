fs      = require('fs')
path    = require('path')
connect = require('connect')
http    = require('http')

app = connect()
  .use(connect.logger('dev'))
  .use(require('connect-assets')())
  .use((req, res)->
    res.writeHead 200
    res.end """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Tweet Globe</title>
        <link href="/assets/application.css?body=1" media="screen" rel="stylesheet" type="text/css" />
        <meta content="authenticity_token" name="csrf-param" />
        <meta content="OKIhrU6kWZ+kbp6Ukj//8718Zsz4Gdmp0JqGwcB6TkE=" name="csrf-token" />
      </head>
      <body>
        <div class='container-fluid' id='content'>

        </div>
        #{hbsTags()}
        #{js("application")}
      </body>
    </html>
    """
  ).listen(1337)

io = require('socket.io').listen app

hbsTags = ()->
  tags = for name in ["application", "chart", "tweets"]
    hbsTag(name)

  console.log(tags, "!")
  tags.join("\n")


hbsTag = (name)->
  template = path.join(__dirname, "assets/js/templates/#{name}.handlebars")
  """
  <script type="text/x-handlebars">
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
    stream.on 'data', (data)->

      if data.geo?.coordinates? && Math.random()>0.7
        io.sockets.emit 'news', new Tweet(data)

class Tweet
  constructor: (data)->
    [@lat, @long] = data.geo.coordinates
    @text = data.text

    @screen_name = data.user.screen_name
    @name = data.user.name
    @country = data.place?.country


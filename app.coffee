fs = require('fs')
app = require('http').createServer (req, res)->
  fs.readFile __dirname + '/index.html', (err, data)->
    res.writeHead 200
    res.end data

app.listen 1337


io = require('socket.io').listen(app)

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

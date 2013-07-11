fs = require('fs')
app = require('http').createServer (req, res)->
  fs.readFile __dirname + '/index.html', (err, data)->
    res.writeHead 200
    res.end data

app.listen 1337


io = require('socket.io').listen(app)

twitter = require('ntwitter')
uri = 'statuses/filter'

io.sockets.on 'connection', (socket)->
  # socket.emit 'news', hello: 'world'

twit = new twitter
  consumer_key:        'gcnju0wIvzpwsbu7gdR2pA'
  consumer_secret:     'lGVCmvWRwgEG4RAqMUCS5xFhXRrKeBquGVTd0qRY'
  access_token_key:    '98638549-zuVhkvxPUV4CoIJXqE4EMhvmrgNg11rvhmoHPSYv4'
  access_token_secret: 'jpjXU0xXCUTh2LwF8HTzrxP0cvMd2uil2loNamhDk'

term = "phone"

twit.stream uri,
  locations: "-180,-90,180,90",
  # track: term,
  (stream)->
    stream.on 'data', (data)->
      # console.log data
      new Tweet data

class Tweet
  @filteredTweets = []
  
  constructor: (data)->
    if data.geo?.coordinates? && Math.random()>0.7 #&& data.text.indexOf(term)!=-1
      [@lat, @long] = data.geo.coordinates
      @text = data.text

      @screen_name = data.user.screen_name
      @name = data.user.name
      @country = data.place?.country

      # Tweet.filteredTweets.push @
      io.sockets.emit 'news', @
      # console.log "push!!!!"


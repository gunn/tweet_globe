#= require_self

#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require ./router
#= require_tree ./routes


window.TweetGlobe = Ember.Application.create
  rootElement: "#content"

TweetGlobe.ready = ->
  socket = io.connect 'http://localhost:1337'

  TweetGlobe.tweetsController = TweetGlobe.TweetsController.create()

  socket.on 'news', (data)->
    TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(data)

  $(window).resize ->
    stretchyDiv = $("#stretchy")
    return unless stretchyDiv
    w = 1000
    h = 400

    stretchyWidth = stretchyDiv.width()
    newHeight = h*(stretchyWidth / w)

    stretchyDiv.height newHeight

    TweetGlobe.tweetsController.set "chartWidth", stretchyWidth
    TweetGlobe.tweetsController.set "chartHeight", newHeight

    console.log TweetGlobe.tweetsController.get("chartWidth"), TweetGlobe.tweetsController.get("chartHeight")

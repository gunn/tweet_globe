#= require_self

#= require ./store
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
    TweetGlobe.tweetsController.unshiftObject TweetGlobe.Tweet.createRecord(data)

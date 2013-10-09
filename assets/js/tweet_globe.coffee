window.App = Ember.Application.create
  rootElement:  "#content"
  USE_FIXTURES: false

App.ready = ->
  App.tweetsController = App.TweetsController.create()

  if App.USE_FIXTURES
    for tweetFixture in App.SAMPLE_TWEETS
      App.tweetsController.addTweet App.Tweet.create(tweetFixture)
  else
    socket = io.connect '/'
    socket.on 'news', (data)->
      for tweetData in data
        App.tweetsController.addTweet App.Tweet.create(tweetData)
      App.tweetsController.trigger "filterEnd"

  $(window).resize ->
    App.tweetsController.trigger "resize"

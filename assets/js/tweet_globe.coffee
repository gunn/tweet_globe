window.TweetGlobe = Ember.Application.create
  rootElement:  "#content"
  USE_FIXTURES: false

TweetGlobe.ready = ->
  TweetGlobe.tweetsController = TweetGlobe.TweetsController.create()

  if TweetGlobe.USE_FIXTURES
    for tweetFixture in TweetGlobe.SAMPLE_TWEETS
      TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(tweetFixture)
  else
    socket = io.connect '/'
    socket.on 'news', (data)->
      for tweetData in data
        TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(tweetData)
      TweetGlobe.tweetsController.trigger "filterEnd"

  $(window).resize ->
    TweetGlobe.tweetsController.trigger "resize"

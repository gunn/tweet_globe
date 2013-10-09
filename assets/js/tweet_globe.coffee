window.TweetGlobe = Ember.Application.create
  rootElement: "#content"

TweetGlobe.ready = ->
  TweetGlobe.tweetsController = TweetGlobe.TweetsController.create()

  unless TweetGlobe.SAMPLE_TWEETS
    socket = io.connect '/'
    socket.on 'news', (data)->
      for tweetData in data
        TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(tweetData)
  else
    for tweetFixture in TweetGlobe.SAMPLE_TWEETS
      TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(tweetFixture)

  $(window).resize ->
    TweetGlobe.tweetsController.trigger "resize"

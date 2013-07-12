window.TweetGlobe = Ember.Application.create
  rootElement: "#content"

TweetGlobe.ready = ->
  TweetGlobe.tweetsController = TweetGlobe.TweetsController.create()

  unless TweetGlobe.SAMPLE_TWEETS
    socket = io.connect 'http://localhost:1337'
    socket.on 'news', (data)->
      TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(data)
  else
    for tweet_fixture in TweetGlobe.SAMPLE_TWEETS
      TweetGlobe.tweetsController.addTweet TweetGlobe.Tweet.create(tweet_fixture)

  $(window).resize ->
    TweetGlobe.tweetsController.trigger "resize"
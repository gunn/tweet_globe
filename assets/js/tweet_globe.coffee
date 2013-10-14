window.App = Ember.Application.create
  USE_FIXTURES: false

App.IndexRoute = Em.Route.extend
  setupController: (controller)->
    if App.USE_FIXTURES
      for tweetFixture in App.SAMPLE_TWEETS
        controller.addTweet App.Tweet.create(tweetFixture)
    else
      socket = io.connect '/'
      socket.on 'news', (data)->
        for tweetData in data
          controller.addTweet App.Tweet.create(tweetData)
        controller.trigger "filterEnd"

    controller.trigger "filterEnd"

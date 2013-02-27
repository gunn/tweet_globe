TweetGlobe.TweetsController = Ember.ArrayController.extend
  content: []
  count: (->
    @get "length"
  ).property "@each"
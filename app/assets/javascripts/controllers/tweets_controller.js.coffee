TweetGlobe.TweetsController = Ember.ArrayController.extend Ember.Evented,
  content: []
  filteredTweets: []
  maxStoredTweets: 800
  maxDisplayedTweets: 80
  searchTerm: ""

  chartHeight: 400
  chartWidth:  1000

  addTweet: (tweet)->
    @unshiftObject(tweet)
    @filterTweet(tweet)
    if @content.length > @maxStoredTweets
      @popObject()

  filterTweet: (tweet)->
    if tweet.hasContent @get("searchTerm").toLowerCase()
      @filteredTweets.unshiftObject(tweet)
      if @filteredTweets.length > @maxDisplayedTweets
        @filteredTweets.popObject()

  filterTweets: (->
    @set "filteredTweets", []

    for tweet in @content
      @filterTweet tweet
      break if @filteredTweets.length >= @maxDisplayedTweets

    @trigger "filterEnd"

  ).observes "searchTerm"

  filteredCount: (->
    @get "filteredTweets.length"
  ).property "filteredTweets.@each"

  count: (->
    @get "length"
  ).property "@each"

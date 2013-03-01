TweetGlobe.TweetsController = Ember.ArrayController.extend
  content: []
  filteredTweets: []
  maxStoredTweets: 1000
  maxDisplayedTweets: 25
  searchTerm: ""

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
  ).observes "searchTerm"

  filteredCount: (->
    @get "filteredTweets.length"
  ).property "filteredTweets.@each"

  count: (->
    @get "length"
  ).property "@each"

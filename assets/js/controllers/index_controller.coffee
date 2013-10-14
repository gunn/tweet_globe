App.IndexController = Ember.ArrayController.extend
  content: []
  filteredTweets: []
  maxStoredTweets: 800
  maxDisplayedTweets: 40
  searchTerm: ""

  chartHeight: 400
  chartWidth:  1000

  toggleOdd: true

  init: ->
    App.indexController = @

  addTweet: (tweet)->
    @unshiftObject(tweet)
    @filterTweet(tweet)
    if @content.length > @maxStoredTweets
      @popObject()

  filterTweet: (tweet)->
    if tweet.hasContent @get("searchTerm").toLowerCase()
      tweet.set "odd", (@toggleOdd = !@toggleOdd)
      @filteredTweets.unshiftObject(tweet)

      if @filteredTweets.length > @maxDisplayedTweets
        @filteredTweets.popObject()

  filterTweets: (->
    @set "filteredTweets", []

    for tweet in @content
      @filterTweet tweet
      break if @filteredTweets.length >= @maxDisplayedTweets

  ).observes "searchTerm"

App.IndexController = Ember.ArrayController.extend
  content            : []
  filteredTweets     : []

  maxStoredTweets    : 2000
  maxDisplayedTweets : 40
  searchTerm         : ""

  paused: false

  init: ->
    App.indexController = @

  addTweet: (tweet)->
    @unshiftObject tweet
    @filterTweet   tweet unless @paused
    @popObject() if @content.length > @maxStoredTweets

  term: Em.auto "searchTerm", (term)-> term.toLowerCase()

  filterTweet: (tweet)->
    if tweet.hasContent @get("term")
      tweet.set "odd", (@toggleOdd = !@toggleOdd)
      @filteredTweets.unshiftObject(tweet)

      if @filteredTweets.length > @maxDisplayedTweets
        @filteredTweets.popObject()

  filterTweets: (->
    @set "filteredTweets", []

    for tweet in @content by -1
      @filterTweet tweet
      break if @filteredTweets.length >= @maxDisplayedTweets
  ).observes "searchTerm"

  # pauseChanged: (->
  #   @filterTweets() unless @paused
  # ).observes "paused"

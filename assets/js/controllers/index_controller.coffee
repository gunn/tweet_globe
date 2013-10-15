App.IndexController = Ember.ArrayController.extend
  content            : []
  filteredTweets     : []

  maxStoredTweets    : 800
  maxDisplayedTweets : 40
  searchTerm         : ""

  init: ->
    App.indexController = @

  addTweet: (tweet)->
    @unshiftObject tweet
    @filterTweet   tweet
    @popObject() if @length > @maxStoredTweets

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

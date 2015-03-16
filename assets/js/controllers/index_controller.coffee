App.IndexController = Ember.ArrayController.extend
  filteredTweets     : []

  maxStoredTweets    : 5000
  maxDisplayedTweets : 40
  searchTerm         : ""

  paused: false

  init: ->
    App.indexController = @

  actions:
    selectTweet: (tweet)->
      @set "selectedTweet", tweet

  addTweet: (tweet)->
    @pushObject tweet
    @filterTweet   tweet unless @paused
    @popObject() if @get("model.length") > @maxStoredTweets

  term: Em.auto "searchTerm", (term)-> term.toLowerCase()

  filterTweet: (tweet)->
    if tweet.hasContent @get("term")
      tweet.set "odd", (@toggleOdd = !@toggleOdd)
      @filteredTweets.unshiftObject(tweet)

      if @filteredTweets.length > @maxDisplayedTweets
        @filteredTweets.popObject()

  filterTweets: (->
    @set "filteredTweets", []

    for tweet in @get("model")
      @filterTweet tweet
      break if @filteredTweets.length >= @maxDisplayedTweets
  ).observes "searchTerm"

  # pauseChanged: (->
  #   @filterTweets() unless @paused
  # ).observes "paused"

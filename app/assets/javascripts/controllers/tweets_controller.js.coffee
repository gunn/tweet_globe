TweetGlobe.TweetsController = Ember.ArrayController.extend
  content: []
  maxStoredTweets: 5000
  maxDisplayedTweets: 100
  searchTerm: ""

  addTweet: (tweet)->
    @unshiftObject(tweet)
    if @content.length > @maxStoredTweets
      @popObject()

  filteredTweets: (->
    count = 0
    goodTweets = []
    for tweet in @content
      for f in ["name", "text"]
        if tweet.get(f).indexOf(@searchTerm)!=-1
          count++
          goodTweets.push tweet
          break
      break if goodTweets.length >= @maxDisplayedTweets
    goodTweets
  ).property "searchTerm", "@each"

  filteredCount: (->
    @get "filteredTweets.length"
  ).property "filteredTweets.@each"

  count: (->
    @get "length"
  ).property "@each"

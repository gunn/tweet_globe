TweetGlobe.TweetsController = Ember.ArrayController.extend
  content: []
  searchTerm: ""

  filteredTweets: (->
    @content.filter (tweet)=>
      for f in ["name", "text"]
        return true if tweet.get(f).indexOf(@searchTerm)!=-1
  ).property "searchTerm", "@each"

  filteredCount: (->
    @get "filteredTweets.length"
  ).property "filteredTweets.@each"

  count: (->
    @get "length"
  ).property "@each"

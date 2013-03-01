TweetGlobe.Tweet = Ember.Object.extend
  searchFields: ["name", "text", "country"]

  searchIndex: (->
    @searchFields
      .map((f)=> @get f)
      .join("\n")
      .toLowerCase()
  ).property @searchFields...

  hasContent: (text)->
    @get("searchIndex").indexOf(text) != -1
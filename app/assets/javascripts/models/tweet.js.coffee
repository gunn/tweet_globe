TweetGlobe.Tweet = Ember.Object.extend

  hasContent: (text)->
    for f in ["name", "text", "country"]
      field = @get(f)
      if field? && field.indexOf(text)!=-1
        return true
    false

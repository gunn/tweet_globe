App.Tweet = Ember.Object.extend
  searchIndex: Em.auto "name", "text", "country", ()->
    [].slice.call(arguments)
      .join("\n")
      .toLowerCase()

  hasContent: (text)->
    @get("searchIndex").indexOf(text) != -1

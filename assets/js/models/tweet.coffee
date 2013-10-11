App.Tweet = Ember.Object.extend
  type: "Point"

  init: ->
    @set "time", new Date().toTimeString().split(/\s+/)[0]

  searchIndex: Em.auto "screen_name", "text", "country", ()->
    [].slice.call(arguments)
      .join("\n")
      .toLowerCase()

  hasContent: (text)->
    @get("searchIndex").indexOf(text) != -1

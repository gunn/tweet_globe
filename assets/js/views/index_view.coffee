App.IndexView = Ember.View.extend
  didInsertElement: ->
    list = $("#tweets")
    list.mouseenter =>
      @get("controller").set "paused", true

    list.mouseleave =>
      @get("controller").set "paused", false

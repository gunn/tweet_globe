TweetGlobe.Tweet = DS.Model.extend
  name: DS.attr('string')
  text: DS.attr('string')
  lat:  DS.attr('number')
  long: DS.attr('number')

  hasContent: (text)->
    for f in ["name", "text"]
      if @get(f).indexOf(text)!=-1
        return true
    false

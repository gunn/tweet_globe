TweetGlobe.Tweet = DS.Model.extend
  name:    DS.attr('string')
  text:    DS.attr('string')
  country: DS.attr('string')
  lat:     DS.attr('number')
  long:    DS.attr('number')

  hasContent: (text)->
    for f in ["name", "text", "country"]
      field = @get(f)
      if field? && field.indexOf(text)!=-1
        return true
    false

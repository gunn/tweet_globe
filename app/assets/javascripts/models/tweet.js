TweetGlobe.Tweet = DS.Model.extend({
  name: DS.attr('string'),
  text: DS.attr('string'),
  lat: DS.attr('number'),
  long: DS.attr('number')
});
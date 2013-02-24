#= require jquery
#= require handlebars
#= require ember
#= require ember-data
#= require socket.io

#= require_self

#= require tweet_globe

window.TweetGlobe = Ember.Application.create()

socket = io.connect 'http://localhost:1337'

table = $("#tweets")

socket.on 'news', (data)->
  console.log data
  row = "<tr><td>"+data.screen_name+"</td><td>"+data.text+"</td></tr>"
  table.prepend(row)

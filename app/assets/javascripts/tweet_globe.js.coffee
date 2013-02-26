#= require_self

#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require ./router
#= require_tree ./routes


window.TweetGlobe = Ember.Application.create
  rootElement: "#content"

socket = io.connect 'http://localhost:1337'

table = $("#tweets")

socket.on 'news', (data)->
  console.log data
  row = "<tr><td>"+data.screen_name+"</td><td>"+data.text+"</td></tr>"
  table.prepend(row)


#= require jquery
#= require ember
#= require_tree .

socket = io.connect 'http://localhost:1337'
window.table = $ "#tweets"
socket.on 'news', (data)->
  console.log data
  row = "<tr><td>"+data.screen_name+"</td><td>"+data.text+"</td></tr>"
  table.prepend(row)

TweetGlobe.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("{{ view.svgElement }}")
  controller: TweetGlobe.TweetsController

  svgElement: "<svg data-whatever='lala'></svg>"

  init: ->
    TweetGlobe.tweetsController.on "filterEnd", => @drawPoints()

  didInsertElement: ->
    @xy = d3.geo.mercator()
    path = d3.geo.path().projection(@xy)

    states = d3.select("svg")
      .append("g")
        .attr("id", "states")

    equator = d3.select("svg")
      .append("line")
        .attr("x1", "0%")
        .attr("x2", "100%")

    d3.json "/world-countries.json", (collection)=>
      states
        .selectAll("path")
          .data(collection.features)
        .enter().append("path")
          .attr("d", path)
        .append("title")
          .text((d)-> d.properties.name)

      equator
          .attr("y1", @xy([0, 0])[1])
          .attr("y2", @xy([0, 0])[1])

  drawPoints: ->
    filteredTweets = TweetGlobe.tweetsController.get "filteredTweets"

    d3.select("svg").selectAll("circle")
      .data(filteredTweets)
    .enter().append("circle")
      .attr("cx", (t)=> @xy([t.long, t.lat])[0])
      .attr("cy", (t)=> @xy([t.long, t.lat])[1])
      .attr("r", 10)

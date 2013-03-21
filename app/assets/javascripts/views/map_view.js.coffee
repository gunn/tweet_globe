TweetGlobe.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("{{ view.svgElement }}")
  controller: TweetGlobe.TweetsController

  svgElement: "<svg data-whatever='lala'></svg>"

  init: ->
    @xy = d3.geo.azimuthal().scale(240).mode("orthographic")
    @circle = d3.geo.greatCircle()

    setInterval (()=>@nextFrame()), 90

    TweetGlobe.tweetsController.on "filterEnd", => @drawPoints()

  didInsertElement: ->

    @path = d3.geo.path().projection(@xy)

    @states = d3.select("svg")
      .append("g")
        .attr("id", "states")
        

    # equator = d3.select("svg")
    #   .append("line")
    #     .attr("x1", "0%")
    #     .attr("x2", "100%")

    d3.json "/world-countries.json", (collection)=>
      @states
        .selectAll("path")
          .data(collection.features)
        .enter().append("path")
          .attr("d", (d)=>@path(@circle.clip(d)))
        .append("title")
          .text((d)-> d.properties.name)

      # equator
      #     .attr("y1", @xy([0, 0])[1])
      #     .attr("y2", @xy([0, 0])[1])

  drawPoints: ->
    filteredTweets = TweetGlobe.tweetsController.get "filteredTweets"

    circles = d3.select("svg").selectAll("circle")
      .data(filteredTweets)

    circles
      .attr("cx", (t)=> @xy([t.long, t.lat])[0])
      .attr("cy", (t)=> @xy([t.long, t.lat])[1])

    circles.enter()
      .append("circle")
        .attr("cx", (t)=> @xy([t.long, t.lat])[0])
        .attr("cy", (t)=> @xy([t.long, t.lat])[1])
        .attr("r", 1e-6)
        .style("stroke-opacity", 1e-6)
        .transition()
          .duration(1000)
          .ease(Math.sqrt)
          .attr("r", 10)
          .style("stroke-opacity", 0.6)

    circles.exit()
      .transition()
        .duration(1000)
        .ease(Math.sqrt)
        .attr("r", 20)
        .style("stroke-opacity", 1e-6)
        .remove()

    circles
      .style "display", (t)=>
        p = { type: "Point" , coordinates: [t.long, t.lat] }
        @circle.clip(p) && "inline" || "none"

    # @circle.clip(circles)

  refresh: ->
    @states.selectAll("path")
      .attr("d", (d)=>@path(@circle.clip(d)))

    @drawPoints()

  nextFrame: ->
    origin = @xy.origin()
    origin[0] -= 1
    origin[0] -= 360 if origin[0] > 180

    @circle.origin(origin)
    @xy.origin(origin)

    @refresh()

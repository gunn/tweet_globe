TweetGlobe.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("{{ view.svgElement }}")
  controller: TweetGlobe.TweetsController

  svgElement: "<svg data-whatever='lala'></svg>"

  init: ->
    @xy = d3.geo.azimuthal().scale(240).mode("orthographic")
    @xy.origin([-60, 0])
    @circle = d3.geo.greatCircle()
    @circle.origin([-60, 0])

    @tweetKey = (t)-> t.name

    TweetGlobe.tweetsController.on "filterEnd", => @drawPoints()

  didInsertElement: ->

    @path = d3.geo.path().projection(@xy)

    @states = d3.select("svg")
      .append("g")
        .attr("id", "states")


    @mousedown = =>
      @m0 = [d3.event.pageX, d3.event.pageY]
      @o0 = @xy.origin()
      d3.event.preventDefault()

    @mousemove = =>
      if @m0
        stopRotating = true

        m1 = [d3.event.pageX, d3.event.pageY]
        o1 = [@o0[0] + (@m0[0] - m1[0]) / 8, @o0[1] + (m1[1] - @m0[1]) / 8];

        @xy.origin(o1)

        @circle.origin(o1)
        @refresh()

    @mouseup = =>
      if @m0
        @mousemove()
        @m0 = null


    d3.select("svg")
      .on("mousedown", @mousedown)

    d3.select("svg")
      .on("mousemove", @mousemove)
      .on("mouseup", @mouseup)

    d3.select("svg").append("text")
      .attr("class", "label")

    $("svg")
      .on "mousemove", (e)->
        if e.target?.tagName == "circle"
          if (circle=d3.select(e.target)).style("display") == "inline"
            circle = d3.select(e.target)
            data   = e.target.__data__

            d3.select(".label")
              .style("display", "inline")
              .text(data.text)
              .attr("x", circle.attr("cx"))
              .attr("y", circle.attr("cy"))
            return true

        d3.select(".label")
          .style("display", "none")
        

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

    circles = d3.select("svg").selectAll("circle:not(.exiting)")
      .data(filteredTweets, @tweetKey)

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
          .duration(2000)
          .ease(Math.sqrt)
          .attr("r", 10)
          .style("stroke-opacity", 0.6)

    circles.exit()
        .attr("class", "exiting")
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

  refresh: ->
    @states.selectAll("path")
      .attr("d", (d)=>@path(@circle.clip(d)))

    @drawPoints()

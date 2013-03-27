TweetGlobe.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("<svg id='globe'></svg>")
  controller: TweetGlobe.TweetsController

  init: ->
    @xy = d3.geo.azimuthal().scale(240).mode("orthographic")
    @xy.origin([-60, 0])
    @circle = d3.geo.greatCircle()
    @circle.origin([-60, 0])

    @tweetKey = (t)-> t.name

    TweetGlobe.tweetsController.on "filterEnd", => @drawPoints()
    TweetGlobe.tweetsController.on "resize", => @resize()

  didInsertElement: ->
    @globe = d3.select("#globe")

    @draggingSetup()
    @drawGlobe()
    @mouseoverSetup()

  draggingSetup: ->
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

    @globe
      .on("mousedown", @mousedown)

    d3.selectAll("#globe,html")
      .on("mousemove", @mousemove)
      .on("mouseup", @mouseup)

  drawGlobe: ->
    @path = d3.geo.path().projection(@xy)

    @states = @globe
      .append("g")
        .attr("id", "states")

    d3.json "/world-countries.json", (collection)=>
      @states
        .selectAll("path")
          .data(collection.features)
        .enter().append("path")
      @resize()

  mouseoverSetup: ->
    @globe.append("text")
      .attr("class", "label")

    $("#globe")
      .on "mousemove", (e)->
        if e.target?.tagName == "circle"
          if d3.select(e.target).style("display") == "inline"
            circle = d3.select(e.target)
            data   = e.target.__data__

            @label
              .style("display", "inline")
              .text(data.text)
              .attr("x", circle.attr("cx") - $(@label[0]).width()/2)
              .attr("y", circle.attr("cy"))
            return true

        @label = d3.select(".label")
          .style("display", "none")

  drawPoints: ->
    filteredTweets = TweetGlobe.tweetsController.get "filteredTweets"

    circles = @globe.selectAll("circle:not(.exiting)")
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

  resize: ->
    [stretchyDiv, w, h] = [$("#stretchy"), 1000, 600]

    width = stretchyDiv.width()
    height = h*(width / w)

    stretchyDiv.height height

    @xy.scale(height/2)
       .translate [width/2, height/2]

    @refresh()

  refresh: ->
    @states.selectAll("path")
      .attr("d", (d)=>@path(@circle.clip(d)))

    @drawPoints()

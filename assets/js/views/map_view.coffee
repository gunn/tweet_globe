App.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("<svg id='globe'></svg>")
  controller: App.TweetsController

  init: ->
    @xy = d3.geo.orthographic()
      .scale(240)
      .clipAngle(90)

    # @xy.origin([-60, 0])
    # @circle = d3.geo.circle()
    # @circle.origin([-60, 0])

    @tweetKey = (t)-> t.name

    App.tweetsController.on "filterEnd", => @drawPoints()
    App.tweetsController.on "resize", => @resize()

  didInsertElement: ->
    @globe     = d3.select("#globe")
    @graticule = d3.geo.graticule()

    @draggingSetup()
    @drawGlobe()
    @mouseoverSetup()

  draggingSetup: ->
    @mousedown = =>
      rotate = @xy.rotate()
      @origin =
        x: (d3.event.x/2) - rotate[0]
        y: (d3.event.y/2) + rotate[1]

      d3.event.preventDefault()

    @mousemove = =>
      if @origin
        @xy.rotate([
          (d3.event.x/2) - @origin.x,
          @origin.y - (d3.event.y/2),
          @xy.rotate()[2]
        ])

        @refresh()

    @mouseup = =>
      if @origin
        @mousemove()
        @origin = null

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

    @grid = @globe.append("path")
      .datum(@graticule)
      .attr("d", @path)


  mouseoverSetup: ->
    @globe.append("text")
      .attr("class", "label")

    $("#globe").on "mousemove", (e)=>
      if @highlightedTweet && @highlightedTweet != e.target?.__data__
        @highlightedTweet.set "highlighted", false

        @label.style("display", "none")

      if e.target?.tagName == "circle"
        circle = d3.select(e.target)

        if circle.style("display") == "inline"
          tweet  = e.target.__data__
          tweet.set "highlighted", true

          @highlightedTweet = tweet

          @label
            .style("display", "inline")
            .text(tweet.text)
            .attr("x", circle.attr("cx") - $(@label[0]).width()/2)
            .attr("y", circle.attr("cy"))
          return true

    @label = d3.select(".label")

  drawPoints: ->
    filteredTweets = App.tweetsController.get "filteredTweets"

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
        # @circle.clip(p) && "inline" || "none"

  resize: ->
    [stretchyDiv, w, h] = [$("#stretchy"), 1000, 600]

    width = stretchyDiv.width()
    height = h*(width / w)

    stretchyDiv.height height

    @xy.scale(height/2)
       .translate [width/2, height/2]

    @refresh()

  refresh: ->
    @globe.selectAll("path")
      .attr "d", (d)=>
        @path d
        # @path @circle.clip(d)

    @drawPoints()

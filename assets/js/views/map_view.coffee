App.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("<svg id='globe'></svg>")
  controller: App.TweetsController

  init: ->
    @tweetKey = (t)-> t.text

    @xy = d3.geo.orthographic()
      .scale(240)
      .clipAngle(90)
      .rotate([0, -15])

    @path = d3.geo.path().projection(@xy)
    @graticule = d3.geo.graticule()

    App.indexController.on "filterEnd", => @drawPoints()
    App.indexController.on "resize", => @resize()

  didInsertElement: ->
    @globe = d3.select("#globe")

    @drawGlobe()
    @draggingSetup()
    @rotateSetup()
    @labelSetup()

  drawGlobe: ->
    @states = @globe
      .append("g")
        .attr("id", "states")

    d3.json "/countries.json", (world)=>
      @states
        .selectAll("path")
          .data(topojson.feature(world, world.objects["world-countries"]).features)
        .enter().append("path")
      @resize()

    @grid = @globe.append("path")
      .attr("class", "graticule")
      .datum(@graticule)
      .attr("d", @path)

  rotateSetup: ->
    @globe.on "mouseover", => @hovering = true
    @globe.on "mouseout",  => @hovering = false

    d3.timer =>
      unless @origin || @hovering
        r = @xy.rotate()
        @xy.rotate [r[0]+0.5, r[1]]
        @refresh()
      null

  draggingSetup: ->
    @globe.on "mousedown", =>
      rotate = @xy.rotate()
      @origin =
        x: (d3.event.x/2) - rotate[0]
        y: (d3.event.y/2) + rotate[1]

      d3.event.preventDefault()

    @mousemove = =>
      if @origin
        @xy.rotate [
          (d3.event.x/2) - @origin.x
          @origin.y - (d3.event.y/2)
        ]

        @refresh()

    @mouseup = =>
      if @origin
        @mousemove()
        @origin = null

    d3.selectAll("#globe,html")
      .on("mousemove", @mousemove)
      .on("mouseup", @mouseup)

  labelSetup: ->
    @label = @globe.append("text")
      .attr("class", "label")

    $("#globe").on "mousemove", (e)=>
      if @highlightedTweet && @highlightedTweet != e.target?.__data__
        @highlightedTweet.set "highlighted", false

        @label.style("display", "none")

      if e.target && $(e.target).is(".circle")
        circle = d3.select(e.target)

        if circle.style("display") == "inline"
          tweet  = e.target.__data__
          tweet.set "highlighted", true

          @highlightedTweet = tweet

          @label
            .style("display", "inline")
            .text(tweet.text)
            .attr("x", @xy(tweet.coordinates)[0] - $(@label[0]).width()/2)
            .attr("y", @xy(tweet.coordinates)[1])
          return true

  drawPoints: ->
    filteredTweets = App.indexController.get "filteredTweets"

    circles = @globe.selectAll("path.circle:not(.exiting)")
      .data(filteredTweets, @tweetKey)

    circles.attr("d", @path.pointRadius(8))

    circles.enter()
      .append("path")
        .attr("class", "circle")
        .attr("d", @path.pointRadius(8))
        .style("stroke-opacity", 1e-6)
        .transition()
          .duration(2000)
          .ease(Math.sqrt)
          .style("stroke-opacity", 1)

    circles.exit()
        .attr("class", "circle exiting")
      .transition()
        .duration(1000)
        .ease(Math.sqrt)
        .style("stroke-opacity", 1e-6)
        .remove()

  resize: ->
    w = $( window ).width()
    h = $( window ).height()-50

    s = Math.min(w, h)/2

    o = Math.max(w - h, 0)/4

    @xy.scale(s)
       .translate [w/2-o, h/2]

    @refresh()

  refresh: ->
    @globe.selectAll("path")
      .attr "d", @path

    @drawPoints()

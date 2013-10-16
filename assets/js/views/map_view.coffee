App.MapView = Ember.View.extend
  defaultTemplate: Ember.Handlebars.compile("<canvas id='globe'></canvas>")
  controller: App.TweetsController

  init: ->
    # @tweetKey = (t)-> t.text

    @xy = d3.geo.orthographic()
      .scale(240)
      .clipAngle(90)
      .rotate([0, -15])

    @graticule = d3.geo.graticule()


  didInsertElement: ->
    @globe = d3.select("#globe")
    @c = @globe.node().getContext("2d")

    @path = d3.geo.path()
      .projection(@xy)
      .context(@c)

    d3.json "/countries.json", (world)=>
      @borderData = topojson.feature(world, world.objects["world-countries"])
      @resize()

    @draggingSetup()
    @rotateSetup()
    # @labelSetup()

    $(window).resize => @resize()

  rotateTo: (->
    @paused = true
    # @highlightTweet @get("selectedTweet")

    d3.transition()
      .duration(1000)
      .tween("rotate", =>
        p = d3.geo.centroid @get("selectedTweet")
        r = d3.interpolate @xy.rotate(), [-p[0], -p[1]]

        (t)=>
          @xy.rotate r(t)
          @refresh()
      )
      .transition()

  ).observes "selectedTweet"

  rotateSetup: ->
    @globe.on "mouseover", => @paused = true
    @globe.on "mouseout",  => @paused = false

    d3.timer =>
      unless @origin || @paused
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

  # labelSetup: ->
  #   @label = @globe.append("text")
  #     .attr("class", "label")

  #   $("#globe").on "mousemove", (e)=>
  #     if @highlightedTweet && @highlightedTweet != e.target?.__data__
  #       @highlightedTweet.set "highlighted", false

  #       @label.style("display", "none")

  #     if e.target && $(e.target).is(".circle")
  #       circle = d3.select(e.target)

  #       if circle.style("display") == "inline"
  #         @highlightTweet e.target.__data__
  #         return true

  # highlightTweet: (tweet)->
  #   tweet.set "highlighted", true
  #   @highlightedTweet = tweet

  #   @label
  #     .style("display", "inline")
  #     .text(tweet.text)
  #     .attr("x", @xy(tweet.coordinates)[0] - $(@label[0]).width()/2)
  #     .attr("y", @xy(tweet.coordinates)[1])

  # drawPoints: (->
  #   circles = @globe.selectAll("path.circle:not(.exiting)")
  #     .data(@get("tweets"), @tweetKey)

  #   circles.attr("d", @path.pointRadius(8))

  #   circles.enter()
  #     .append("path")
  #       .attr("class", "circle")
  #       .attr("d", @path.pointRadius(8))
  #       .style("stroke-opacity", 1e-6)
  #       .transition()
  #         .duration(2000)
  #         .ease(Math.sqrt)
  #         .style("stroke-opacity", 1)

  #   circles.exit()
  #       .attr("class", "circle exiting")
  #     .transition()
  #       .duration(1000)
  #       .ease(Math.sqrt)
  #       .style("stroke-opacity", 1e-6)
  #       .remove()
  # ).observes("tweets.[]")

  resize: ->
    w = $( window ).width()
    h = $( window ).height()-50

    @globe
      .attr("width",  w)
      .attr("height", h)

    s = Math.min(w, h)/2
    o = Math.max(w - h, 0)/4

    @xy.scale(s)
       .translate [w/2-o, h/2]

    @refresh()

  strokePath: (data, colour)->
    @c.beginPath()
    @c.strokeStyle = colour
    @path data
    @c.stroke()

  refresh: ->
    @c.clearRect 0, 0, $("#globe").width(), $("#globe").height()
    @c.lineWidth = 1

    @strokePath @graticule(), "#002f00"
    @strokePath @borderData,  "#006000"

    # if tweet = @highlightedTweet
    #   @label
    #     .attr("x", @xy(tweet.coordinates)[0] - $(@label[0]).width()/2)
    #     .attr("y", @xy(tweet.coordinates)[1])

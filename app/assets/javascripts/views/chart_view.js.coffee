TweetGlobe.ChartView = Ember.View.extend
  templateName: "chart"
  controller: TweetGlobe.TweetsController

  marginLeft:   40
  marginBottom: 20

  height: (->
    TweetGlobe.tweetsController.get("chartHeight") - @marginBottom
  ).property "TweetGlobe.tweetsController.chartHeight"

  width: (->
    TweetGlobe.tweetsController.get("chartWidth") - @marginLeft
  ).property "TweetGlobe.tweetsController.chartWidth"

  # === SETUP ===
  init: ->
    @_super()
    @data = @generateData()

  svgElement: "<svg></svg>"

  click: ->
    @set "data", @generateData()

  generateData: ->
    for n in [0..33]
      label: n.toString(32)
      value: Math.random()*100

  didInsertElement: ->
    @svg = d3.select("svg")
      .append("g")
      .attr("transform", "translate(" + @marginLeft + "," + 0 + ")");
    @drawChart()
    $(window).resize()

  # === CHART METHODS ===
  setScales: ->
    data = @data

    @x = d3.scale.ordinal()
      .rangeRoundBands([0, @get("width")], .1)
      .domain data.map((d)-> d.label)

    @y = d3.scale.linear()
      .range([@get("height"), 0])
      .domain [0, d3.max(data, (d)-> d.value)]

  scaleChart: (->
    @setScales()

    # @svg.attr("width",  @get("width")-@marginLeft)
    #     .attr("height", @get("height")-@marginBottom)

    @svg.selectAll(".bar")
      .attr("x", (d)=> @x(d.label))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))

    @drawAxes()
  ).observes "width", "height"

  drawAxes: ->
    xAxis = d3.svg.axis()
      .scale(@x)
      .orient("bottom")

    yAxis = d3.svg.axis()
      .scale(@y)
      .orient("left")

    @svg.select(".x.axis")
      .attr("transform", "translate(0," + (@get("height")).toString()+ ")")
      .call(xAxis)

    @svg.select(".y.axis")
      .call(yAxis)

  drawChart: ->
    @setScales()

    @svg.append("g").attr("class", "x axis")
    @svg.append("g").attr("class", "y axis")

    @svg.selectAll(".bar")
      .data(@data)
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d)=> @x(d.label))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))

  update: (->
    @setScales()

    @svg.selectAll(".bar")
      .data(@get("data"))
      .transition().duration(1000)
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))
  ).observes "data"


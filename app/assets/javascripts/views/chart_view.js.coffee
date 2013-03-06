TweetGlobe.ChartView = Ember.View.extend
  templateName: "chart"
  controller: TweetGlobe.TweetsController

  heightBinding: Ember.Binding.oneWay "TweetGlobe.tweetsController.chartHeight"
  widthBinding:  Ember.Binding.oneWay "TweetGlobe.tweetsController.chartWidth"

  # === SETUP ===
  init: ->
    @_super()
    @data = @generateData()

  svgElement: "<svg></svg>"

  click: ->
    @set "data", @generateData()

  generateData: ->
    for n in [0..33]
      cc: n.toString(32)
      value: Math.random()*100

  didInsertElement: ->
    @svg = d3.select("svg")
    @drawChart()
    $(window).resize()

  # === CHART METHODS ===
  setScales: ->
    data = @data

    @x = d3.scale.ordinal()
      .rangeRoundBands([0, @get("width")], .1)
      .domain data.map((d)-> d.cc)

    @y = d3.scale.linear()
      .range([@get("height"), 0])
      .domain [0, d3.max(data, (d)-> d.value)]

  scaleChart: (->
    @setScales()

    @svg.attr("width",  @get("width"))
        .attr("height", @get("height"))

    @svg.selectAll(".bar")
      .attr("x", (d)=> @x(d.cc))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))
  ).observes "width", "height"

  drawChart: ->
    @setScales()

    @svg.selectAll(".bar")
      .data(@data)
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d)=> @x(d.cc))
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


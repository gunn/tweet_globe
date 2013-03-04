TweetGlobe.ChartView = Ember.View.extend
  templateName: "chart"
  controller: TweetGlobe.TweetsController

  height: 400
  width:  1000

  data: (->
    for n in [0..33]
      cc: n.toString(32)
      value: Math.random()*100
  )

  svgElement: "<svg></svg>"

  click: ->
    console.log "!!!"
    @update()

  didInsertElement: ->
    @svg = d3.select("svg")
    @scaleChart()

  attatchChart: ->
    d3.select("#stretchy").append(@svg)

  scaleChart: (->
    @x = d3.scale.ordinal()
      .rangeRoundBands([0, @get("width")], .1)

    @y = d3.scale.linear()
      .range([@get("height"), 0]);

    @svg.attr("width",  @get("width"))
        .attr("height", @get("height"))
    @drawChart()
  ).observes "width", "height"

  drawChart: ->
    data = @data()
    @x.domain data.map((d)-> d.cc)
    @y.domain [0, d3.max(data, (d)-> d.value)]

    @svg.selectAll(".bar")
      .data(data)
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d)=> @x(d.cc))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))

  update: ->
    data = @data()

    @svg.selectAll(".bar")
      .data(data)
      .transition().duration(1000)
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))


App.ChartView = Ember.View.extend
  templateName: "chart"
  controller: App.TweetsController

  marginLeft:   40
  marginBottom: 20

  height: (->
    App.tweetsController.get("chartHeight") - @marginBottom
  ).property "App.tweetsController.chartHeight"

  width: (->
    App.tweetsController.get("chartWidth") - @marginLeft
  ).property "App.tweetsController.chartWidth"

  # === SETUP ===
  init: ->
    @_super()
    @data = @generateData()
    # console.log @data

  svgElement: "<svg></svg>"

  click: (->
    @set "data", @generateData()
  ).observes("App.tweetsController.filteredTweets.@each")

  generateData: ->
    tweets = App.tweetsController.filteredTweets
    lengths = Array(14).join("0").split("").map -> 0

    for tweet in tweets
      ll = Math.round(tweet.get("text").length/10)
      lengths[ll] += 1

    for count, index in lengths
      label: index*10
      value: count

  didInsertElement: ->
    @svg = d3.select("svg")
      .append("g")
      .attr("transform", "translate(" + @marginLeft + "," + 0 + ")")

    console.log @data
    console.log "draw!!!"
    @drawChart()
    $(window).resize()
    

  # === CHART METHODS ===
  setScales: ->
    data = @get("data") || @data

    @x = d3.scale.ordinal()
      .rangeRoundBands([0, @get("width")], .1)
      .domain data.map((d)-> d.label)

    @y = d3.scale.linear()
      .range([@get("height"), 0])
      .domain [0, d3.max(data, (d)-> d.value)]

    @drawAxes()

  scaleChart: (->
    @setScales()

    # @svg.attr("width",  @get("width")-@marginLeft)
    #     .attr("height", @get("height")-@marginBottom)


    @svg.selectAll(".bar")
      .attr("x", (d)=> @x(d.label))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))
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
      .enter().append("rect")
      .attr("class", "bar")
      .attr("x", (d)=> @x(d.label))
      .attr("width", @x.rangeBand())
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))

    @svg.selectAll(".bar")
      .data(@get("data"))
      .attr("y", (d)=> @y(d.value))
      .attr("height", (d)=> @get("height")- @y(d.value))
  ).observes "data"


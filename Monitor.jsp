<!DOCTYPE html>
<meta charset="utf-8">
<style>

body {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {
  display: none;
}

.line {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}

@import url(http://fonts.googleapis.com/css?family=Yanone+Kaffeesatz:400,700);

body {
  font-family: "Helvetica Neue";
  margin: 40px auto;
  width: 960px;
  min-height: 2000px;
}

#body {
  position: relative;
}

footer {
  padding: 2em 0 1em 0;
  font-size: 12px;
}

h1 {
  font-size: 96px;
  margin-top: .3em;
  margin-bottom: 0;
}

h1 + h2 {
  margin-top: 0;
}

h2 {
  font-weight: 400;
  font-size: 28px;
}

h1, h2 {
  font-family: "Yanone Kaffeesatz";
  text-rendering: optimizeLegibility;
}

#body > p {
  line-height: 1.5em;
  width: 640px;
  text-rendering: optimizeLegibility;
}

#charts {
  padding: 10px 0;
}

.Max{
}

.Min{
}

.Avg{
}

.hidden { 
display: none; 
}
.chart {
  display: inline-block;
  height: 151px;
  margin-bottom: 20px;
}

.reset {
  padding-left: 1em;
  font-size: smaller;
  color: #ccc;
}

.background.bar {
  fill: #ccc;
}

.foreground.bar {
  fill: steelblue;
}

.axis path, .axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.axis text {
  font: 10px sans-serif;
}

.brush rect.extent {
  fill: steelblue;
  fill-opacity: .125;
}

.brush .resize path {
  fill: #eee;
  stroke: #666;
}

#hour-chart {
  width: 260px;
}

#delay-chart {
  width: 230px;
}

#distance-chart {
  width: 420px;
}

#date-chart {
  width: 920px;
}

#flight-list {
  min-height: 1024px;
}

#flight-list .date,
#flight-list .day {
  margin-bottom: .4em;
}

#flight-list .flight {
  line-height: 1.5em;
  background: #eee;
  width: 640px;
  margin-bottom: 1px;
}

#flight-list .time {
  color: #999;
}

#flight-list .flight div {
  display: inline-block;
  width: 100px;
}

#flight-list div.distance,
#flight-list div.delay {
  width: 160px;
  padding-right: 10px;
  text-align: right;
}

#flight-list .early {
  color: green;
}

aside {
  position: absolute;
  left: 740px;
  font-size: smaller;
  width: 220px;
}

</style>
<div id="option">
    <input type="checkbox"  class="messageCheckbox" value="Max"/>Maximum
    <input type="checkbox"  class="messageCheckbox" value="Min"/>Minimum
    <input type="checkbox" class="messageCheckbox" id="AVG" value="Average""/>Average
    <input type="checkbox"  class="messageCheckbox" id="USER" value="User""/>User
</div>

<div id="body">


</div>

<script src="crossfilter.js"></script>
<script src="d3.v3.min.js"></script>



<script>

var parseTimestamp = d3.time.format("%Y-%m-%d %H:%M:%S").parse;


var margin = {top: 20, right: 80, bottom: 30, left: 50},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var x = d3.time.scale()
    .range([0, width]);

var y = d3.scale.linear()
    .range([height, 0]);

var color = d3.scale.category10();

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var line = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.Timestamp); })
    .y(function(d) { return y(d.usage); });

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


d3.csv("1.csv", function(error, data) {
  color.domain(d3.keys(data[0]).filter(function(key) { return key !== "Timestamp"; }));

  data.forEach(function(d) {
    d.Timestamp = parseTimestamp(d.Timestamp);
    d.Min = +d.Min;
    d.Max = +d.Max;
    d.Average = +d.Average;
    d.User = +d.User;
  });

  var cities = color.domain().map(function(name) {
    return {
      name: name,
      values: data.map(function(d) {
        return {Timestamp: d.Timestamp, usage: +d[name]};
      })
    };
  });

  x.domain(d3.extent(data, function(d) { return d.Timestamp; }));

  y.domain([
    d3.min(cities, function(c) { return d3.min(c.values, function(v) { return v.usage; }); }),
    d3.max(cities, function(c) { return d3.max(c.values, function(v) { return v.usage; }); })
  ]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("usage");

  var city = svg.selectAll(".city")
      .data(cities)
    .enter().append("g")
      .attr("class", "city");

  city.append("path")
      .attr("class", function(d) { return "line " +  d.name})
      .attr("d", function(d) { return line(d.values); })
      .style("stroke", function(d) { return color(d.name); });

  city.append("text")
      .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
      .attr("transform", function(d) { return "translate(" + x(d.value.Timestamp) + "," + y(d.value.usage) + ")"; })
      .attr("x", 3)
      .attr("dy", ".35em")
      .text(function(d) { return d.name; });
});

d3.selectAll('.messageCheckbox').on('click', function () {
    var value = this.value,
        checked = this.checked;
    d3.select('.' + value).classed('hidden', !checked);
});


</script>

<!DOCTYPE html>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>
<%@ page import="org.apache.commons.lang3.*" %>

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

<div id="body">



<div id="charts">
  <div id="hour-chart" class="chart">
    <div class="title">Time of Day</div>
  </div>
  <div id="delay-chart" class="chart">
    <div class="title">Minimum</div>
  </div>
  <div id="distance-chart" class="chart">
    <div class="title">Average</div>
  </div>
  <div id="date-chart" class="chart">
    <div class="title">Date</div>
  </div>
</div>

<aside id="totals"><span id="active">-</span> of <span id="total">-</span> records selected.</aside>

</div>

            <%
                Class.forName("org.sqlite.JDBC");
                Connection conn =
                     DriverManager.getConnection("jdbc:sqlite:/home/kunkunur/dev/tools/apache-tomcat-7.0.30/webapps/energy/db/original.db");
                Statement stat = conn.createStatement();
		String id = request.getParameter("id");
		id = id == null? "1": id;
		String sql = "SELECT datetime(stats.timestamp, 'unixepoch') as Timestamp, average || '.0' as Average, maximum || '.0' as Max, minimum || '.0' as Min,value || '.0' as User " + 
				" from stats,usage where usage.id = " + id + " and stats.timestamp = usage.timestamp limit 100";
 
                ResultSet rs = stat.executeQuery(sql);
 		
		String csv = "Timestamp,Average,Max,Min,User\n";
                while (rs.next()) {
                    csv = csv + rs.getString("Timestamp") + ",";
                    csv = csv + rs.getString("Average") + ",";
		    csv = csv + rs.getString("Max") + ",";
		    csv = csv + rs.getString("Min") + ",";
		    csv = csv + rs.getString("User") + "\n";
                }
		
		System.out.println(csv);
 
                rs.close();
                conn.close();
            %>
<script src="crossfilter.js"></script>
<script src="d3.v3.min.js"></script>

<script>

var csv_string = '<%=  StringEscapeUtils.escapeEcmaScript(csv) %>';
var parseTimestamp = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

// (It's CSV, but GitHub Pages only gzip's JSON at the moment.)
d3.csv("stats4.csv", function(error, flights) {

  // Various formatters.
  var formatNumber = d3.format(",d"),
      formatChange = d3.format("+,d"),
      formatDate = d3.time.format("%B %d, %Y"),
      formatTime = d3.time.format("%I:%M %p");

  // A nest operator, for grouping the flight list.
  var nestByDate = d3.nest()
      .key(function(d) { return d3.time.day(d.date); });

  // A little coercion, since the CSV is untyped.
  flights.forEach(function(d, i) {
    d.index = i;
    d.date = new Date(parseTimestamp(d.date));
    d.delay = +d.delay;
    d.distance = +d.distance;
  });

var delayMin = d3.min(flights, function(d){ return Math.min(d.delay); });
var delayMax = d3.max(flights, function(d){ return Math.max(d.delay); });

var distanceMin = d3.min(flights, function(d){ return Math.min(d.distance); });
var distanceMax = d3.max(flights, function(d){ return Math.max(d.distance); });

  // Create the crossfilter for the relevant dimensions and groups.
  var flight = crossfilter(flights),
      all = flight.groupAll(),
      date = flight.dimension(function(d) { return d.date; }),
      dates = date.group(d3.time.day),
      hour = flight.dimension(function(d) { return d.date.getHours() + d.date.getMinutes() / 60; }),
      hours = hour.group(Math.floor),
      delay = flight.dimension(function(d) { return Math.max(delayMin, Math.min(delayMax, d.delay)); }),
      delays = delay.group(function(d) { return Math.floor(d / 10) * 10; }),
      distance = flight.dimension(function(d) { return Math.min(1999, d.distance); }),
      distances = distance.group(function(d) { return Math.floor(d / 50) * 50; });

  var charts = [

    barChart()
        .dimension(hour)
        .group(hours)
      .x(d3.scale.linear()
        .domain([0, 24])
        .rangeRound([0, 10 * 24])),

    barChart()
        .dimension(delay)
        .group(delays)
      .x(d3.scale.linear()
        .domain([delayMin, delayMax])
        .rangeRound([0, 10 * 21])),

    barChart()
        .dimension(distance)
        .group(distances)
      .x(d3.scale.linear()
        .domain([distanceMin, distanceMax])
        .rangeRound([0, 10 * 40])),

    barChart()
        .dimension(date)
        .group(dates)
        .round(d3.time.day.round)
      .x(d3.time.scale()
        .domain([new Date(2001, 0, 1), new Date(2001, 3, 1)])
        .rangeRound([0, 10 * 90]))
        .filter([new Date(2001, 1, 1), new Date(2001, 2, 1)])

  ];

  // Given our array of charts, which we assume are in the same order as the
  // .chart elements in the DOM, bind the charts to the DOM and render them.
  // We also listen to the chart's brush events to update the display.
  var chart = d3.selectAll(".chart")
      .data(charts)
      .each(function(chart) { chart.on("brush", renderAll).on("brushend", renderAll); });

  // Render the initial lists.
  var list = d3.selectAll(".list")
      .data([flightList]);

  // Render the total.
  d3.selectAll("#total")
      .text(formatNumber(flight.size()));

  renderAll();

  // Renders the specified chart or list.
  function render(method) {
    d3.select(this).call(method);
  }

  // Whenever the brush moves, re-rendering everything.
  function renderAll() {
    chart.each(render);
    list.each(render);
    d3.select("#active").text(formatNumber(all.value()));
  }

  window.filter = function(filters) {
    filters.forEach(function(d, i) { charts[i].filter(d); });
    renderAll();
  };

  window.reset = function(i) {
    charts[i].filter(null);
    renderAll();
  };

  function flightList(div) {
    var flightsByDate = nestByDate.entries(date.top(40));

    div.each(function() {
      var date = d3.select(this).selectAll(".date")
          .data(flightsByDate, function(d) { return d.key; });

      date.enter().append("div")
          .attr("class", "date")
        .append("div")
          .attr("class", "day")
          .text(function(d) { return formatDate(d.values[0].date); });

      date.exit().remove();

      var flight = date.order().selectAll(".flight")
          .data(function(d) { return d.values; }, function(d) { return d.index; });

      var flightEnter = flight.enter().append("div")
          .attr("class", "flight");

      flightEnter.append("div")
          .attr("class", "time")
          .text(function(d) { return formatTime(d.date); });

      flightEnter.append("div")
          .attr("class", "distance")
          .text(function(d) { return formatNumber(d.distance) + " mi."; });

      flightEnter.append("div")
          .attr("class", "delay")
          .classed("early", function(d) { return d.delay < 0; })
          .text(function(d) { return formatChange(d.delay) + " min."; });

      flight.exit().remove();

      flight.order();
    });
  }

  function barChart() {
    if (!barChart.id) barChart.id = 0;

    var margin = {top: 10, right: 10, bottom: 20, left: 10},
        x,
        y = d3.scale.linear().range([100, 0]),
        id = barChart.id++,
        axis = d3.svg.axis().orient("bottom"),
        brush = d3.svg.brush(),
        brushDirty,
        dimension,
        group,
        round;

    function chart(div) {
      var width = x.range()[1],
          height = y.range()[0];

      y.domain([0, group.top(1)[0].value]);

      div.each(function() {
        var div = d3.select(this),
            g = div.select("g");

        // Create the skeletal chart.
        if (g.empty()) {
          div.select(".title").append("a")
              .attr("href", "javascript:reset(" + id + ")")
              .attr("class", "reset")
              .text("reset")
              .style("display", "none");

          g = div.append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
            .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          g.append("clipPath")
              .attr("id", "clip-" + id)
            .append("rect")
              .attr("width", width)
              .attr("height", height);

          g.selectAll(".bar")
              .data(["background", "foreground"])
            .enter().append("path")
              .attr("class", function(d) { return d + " bar"; })
              .datum(group.all());

          g.selectAll(".foreground.bar")
              .attr("clip-path", "url(#clip-" + id + ")");

          g.append("g")
              .attr("class", "axis")
              .attr("transform", "translate(0," + height + ")")
              .call(axis);

          // Initialize the brush component with pretty resize handles.
          var gBrush = g.append("g").attr("class", "brush").call(brush);
          gBrush.selectAll("rect").attr("height", height);
          gBrush.selectAll(".resize").append("path").attr("d", resizePath);
        }

        // Only redraw the brush if set externally.
        if (brushDirty) {
          brushDirty = false;
          g.selectAll(".brush").call(brush);
          div.select(".title a").style("display", brush.empty() ? "none" : null);
          if (brush.empty()) {
            g.selectAll("#clip-" + id + " rect")
                .attr("x", 0)
                .attr("width", width);
          } else {
            var extent = brush.extent();
            g.selectAll("#clip-" + id + " rect")
                .attr("x", x(extent[0]))
                .attr("width", x(extent[1]) - x(extent[0]));
          }
        }

        g.selectAll(".bar").attr("d", barPath);
      });

      function barPath(groups) {
        var path = [],
            i = -1,
            n = groups.length,
            d;
        while (++i < n) {
          d = groups[i];
          path.push("M", x(d.key), ",", height, "V", y(d.value), "h9V", height);
        }
        return path.join("");
      }

      function resizePath(d) {
        var e = +(d == "e"),
            x = e ? 1 : -1,
            y = height / 3;
        return "M" + (.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
            + "Z"
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
      }
    }

    brush.on("brushstart.chart", function() {
      var div = d3.select(this.parentNode.parentNode.parentNode);
      div.select(".title a").style("display", null);
    });

    brush.on("brush.chart", function() {
      var g = d3.select(this.parentNode),
          extent = brush.extent();
      if (round) g.select(".brush")
          .call(brush.extent(extent = extent.map(round)))
        .selectAll(".resize")
          .style("display", null);
      g.select("#clip-" + id + " rect")
          .attr("x", x(extent[0]))
          .attr("width", x(extent[1]) - x(extent[0]));
      dimension.filterRange(extent);
    });

    brush.on("brushend.chart", function() {
      if (brush.empty()) {
        var div = d3.select(this.parentNode.parentNode.parentNode);
        div.select(".title a").style("display", "none");
        div.select("#clip-" + id + " rect").attr("x", null).attr("width", "100%");
        dimension.filterAll();
      }
    });

    chart.margin = function(_) {
      if (!arguments.length) return margin;
      margin = _;
      return chart;
    };

    chart.x = function(_) {
      if (!arguments.length) return x;
      x = _;
      axis.scale(x);
      brush.x(x);
      return chart;
    };

    chart.y = function(_) {
      if (!arguments.length) return y;
      y = _;
      return chart;
    };

    chart.dimension = function(_) {
      if (!arguments.length) return dimension;
      dimension = _;
      return chart;
    };

    chart.filter = function(_) {
      if (_) {
        brush.extent(_);
        dimension.filterRange(_);
      } else {
        brush.clear();
        dimension.filterAll();
      }
      brushDirty = true;
      return chart;
    };

    chart.group = function(_) {
      if (!arguments.length) return group;
      group = _;
      return chart;
    };

    chart.round = function(_) {
      if (!arguments.length) return round;
      round = _;
      return chart;
    };

    return d3.rebind(chart, brush, "on");
  }
});


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

d3.csv.parse(csv_string, function(error, data) {
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
      .attr("class", "line")
      .attr("d", function(d) {  return line(d.values); })
      .style("stroke", function(d) { return color(d.name); });

  city.append("text")
      .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
      .attr("transform", function(d) { return "translate(" + x(d.value.Timestamp) + "," + y(d.value.usage) + ")"; })
      .attr("x", 3)
      .attr("dy", ".35em")
      .text(function(d) { return d.name; });
});

</script>

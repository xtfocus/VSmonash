window.onload = function() {
  var width = 1000;
  var height = 600;

  // Create a SVG canvas
  var thisCanvas = d3.select("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("class", "svgCanvas");

  // We want some margin between the boundary of the canvas and the bar charts
  var margin = {
    top: 10,
    right: 20,
    bottom: 30,
    left: 50
  };
  width = width - margin.left - margin.right;
  height = height - margin.top - margin.bottom;

  // create the area to draw the bar chart
  // g is a SVG element to group multiple SVG elements
  var netWorkArea = thisCanvas
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  d3.json("https://raw.githubusercontent.com/xtfocus/VSmonash/master/asm/d3/data.json", function(data) {

    var xMin = Infinity;
    var xMax = -1;

    var yMin = Infinity;
    var yMax = -1;

    // radius
    var rMin = Infinity;
    var rMax = -100;

    // tooltip
    var div = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);


    // this is a loop
    data.nodes.forEach(function(node) {
      xMin = Math.min(xMin, node.x);
      xMax = Math.max(xMax, node.x);

      yMin = Math.min(yMin, node.y);
      yMax = Math.max(yMax, node.y);
    });

    // compute total trade


    var scaledX = d3.scaleLinear()
      .domain([xMin, xMax])
      .range([100, width - 100]);

    var scaledY = d3.scaleLinear()
      .domain([yMin, yMax])
      .range([100, height - 100]);

    var scaledR = d3.scaleLinear()
      .domain([rMin, rMax])
      .range([10, 30]);

    var arrNodes = d3.values(data.nodes);
    // console.log(arrNodes);

    // extract links
    var arrLinks = d3.values(data.links);
    // console.log(arrLinks);

    // get to entries
    arrTrade_From = d3.nest()
      .key(function(d) {
        return d.node01
      })
      .rollup(function(v) {
        return {
          // return d.amount
          count: v.length,
          total: d3.sum(v, function(d) {
            return d.amount;
          })
        };
      })
      .entries(arrLinks)

    // console.log(JSON.stringify(arrTrade_From));
    // console.log(arrTrade_From);

    arrTrade_To = d3.nest()
      .key(function(d) {
        return d.node02
      })
      .rollup(function(v) {
        return {
          // return d.amount
          count: v.length,
          total: d3.sum(v, function(d) {
            return d.amount;
          })
        };
      })
      .entries(arrLinks)

    // console.log(JSON.stringify(arrTrade_From));
    // console.log(arrTrade_To);

    var arrTotal = d3.merge([
      arrTrade_From,
      arrTrade_To
    ]);

    // console.log(arrTotal);

    var arrTotal_aggregated = d3.nest()
      .key(function(d) {
        return d.key;
      })
      .rollup(function(v) {
        return {
          total_connection: d3.sum(v, function(d) {
            return d.value["count"];
          }),
          total_trade: d3.sum(v, function(d) {
            return d.value["total"];
          })
        };
      })
      .entries(arrTotal)

    d3.select("svg").selectAll("g")
      .data(data.nodes)
      .enter()
      .append("g")
      .attr("transform", function(d) {
        return "translate(" + (d.x) + "," + (d.y) + ")";
      })
      .on("mouseover", function(d) {
        // tooltip
        div.transition()
          .duration(200)
          .style("opacity", .9);
        div.html(function(v) {
            return d.id;
          })
          .style("left", (d3.event.pageX) + "px")
          .style("top", (d3.event.pageY - 28) + "px");
      })
      .append("circle")
      .attr("r", 50)

    // var node = netWorkArea.selectAll("g")
    //   .data(data.nodes)
    //   .enter()
    //   .append("g")
    //   .attr("transform", function(d) {
    //     return "translate(" + scaledX(d.x) + "," + scaledY(d.y) + ")";
    //   })
    //   .on("mouseover", function(d) {
    //     // tooltip
    //     div.transition()
    //       .duration(200)
    //       .style("opacity", .9);
    //     div.html(function(v) {
    //         return d.id;
    //       })
    //       .style("left", (d3.event.pageX) + "px")
    //       .style("top", (d3.event.pageY - 28) + "px");
    //   })
    //   .append("circle")
    //   .attr("r",  50)
    //   .attr("fill", "blue");



    //
    // .on("mouseover", function(d) {
    //
    //   div.transition()
    //     .duration(200)
    //     .style("opacity", .9);
    //   div.html(function(v) {
    //       return d.id;
    //     })
    //     .style("left", (d3.event.pageX) + "px")
    //     .style("top", (d3.event.pageY - 28) + "px");
    // });

    //
    // node.data(totalTradejs)
    //   .attr("r", function(thisNode, index) {
    //     return scaledR(Math.log(thisNode["amount"]));
    //   })
    //   .attr("fill", "lightblue");

    var cLines = d3.select("svg")
      .selectAll("lines")
      .data(arrLinks)
      .enter().append("line")
      .attr("name", function(d) {
        return "group_" + d.node01;
      })
      .attr("class", "shots")
      // from
      .attr("x1", function(d) {
        return d3.values(arrNodes.filter(function(v) {
          return v.id == d.node01;
        }))[0].x;
      })
      .attr("y1", function(d) {
        return d3.values(arrNodes.filter(function(v) {
          return v.id == d.node01;
        }))[0].y;
      })
      // to
      .attr("x2", function(d) {
        return d3.values(arrNodes.filter(function(v) {
          return v.id == d.node02;
        }))[0].x;
      })
      .attr("y2", function(d) {
        return d3.values(arrNodes.filter(function(v) {
          return v.id == d.node02;
        }))[0].y;
      })
      //amount
      .attr("stroke-width", function(d) {
        return d.amount / 50;
      })
      .attr("stroke", "gray")
      .lower() // cirles on top


  });


}

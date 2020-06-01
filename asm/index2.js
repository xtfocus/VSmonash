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

    var Tooltip = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);
    var mouseover = function(d) {
      Tooltip
        .style("opacity", 1)
      d3.select(this)
        .style("stroke", "black")
        .style("opacity", 1)
      Tooltip
        .html(d.id)
        .style("top", (d3.mouse(this)[1]) + "px")
        .style("left", (d3.mouse(this)[0]) + "px")
    };
    // var mousemove = function(d) {
    //   Tooltip
    //     .html(d.id)
    //     .style("left", (d3.mouse(this)) + "px")
    //     .style("top", (d3.mouse(this)) + "px")
    // };
    var mouseout = function(d) {
      Tooltip
        .style("opacity", 0)
      d3.select(this)
        .style("stroke", "none")
        .style("opacity", 0.8)
    };


    // this is a loop
    data.nodes.forEach(function(node) {
      xMin = Math.min(xMin, node.x);
      xMax = Math.max(xMax, node.x);

      yMin = Math.min(yMin, node.y);
      yMax = Math.max(yMax, node.y);
    });

    // compute total trade
    var totalTrade = {};
    data.nodes.forEach(function(node) {
      totalTrade[node.id] = 0
    });
    //update this array
    data.links.forEach(function(link) {
      totalTrade[link.node01] += link.amount
      totalTrade[link.node02] += link.amount;
    });
    //convert to key-value named
    var totalTradejs = [];
    for (var i in totalTrade) {

      totalTradejs.push({
        id: i,
        amount: totalTrade[i]
      });
    };

    totalTradejs.forEach(function(node) {
      rMin = Math.min(rMin, Math.log(node.amount));
      rMax = Math.max(rMax, Math.log(node.amount));
    });

    var scaledX = d3.scaleLinear()
      .domain([xMin, xMax])
      .range([100, width - 100]);

    var scaledY = d3.scaleLinear()
      .domain([yMin, yMax])
      .range([100, height - 100]);

    var scaledR = d3.scaleLinear()
      .domain([rMin, rMax])
      .range([10, 30]);


    var node = netWorkArea.selectAll("circle")
      .data(data.nodes)
      .enter()
      .append("circle")
      // do I need index here?
      .attr("cx", function(thisNode, index) {
        return scaledX(thisNode["x"]);
      })
      .attr("cy", function(thisNode, index) {
        return scaledY(thisNode["y"]);
      })
      .attr("r", 20)
      .attr("fill", "black")
      .on("mouseover", function(d) {
        d3.selectAll(".shots")
          .attr("opacity", 0.2);

        d3.selectAll(".shots")
          .filter(function(z) {
            // console.log(z.id == "site01");
            return ((z.id == d.id) || (z.node01 == d.id) || (z.node02 == d.id));
          })
          .attr("opacity", 1);


        div.transition()
          .duration(200)
          .style("opacity", .9);
        div.html(function(v) {
            return d.id;
          })
          .style("left", (d3.event.pageX) + "px")
          .style("top", (d3.event.pageY - 28) + "px");
      })
      .on("mouseout", function(d) {
        div.transition()
          .duration(500)
          .style("opacity", 0);
        d3.selectAll(".shots")
          .attr("opacity", 1);
      })
      .append("circle")
      .attr("r", 40)
      .attr("fill", "blue")


    node.data(totalTradejs)
      .attr("r", function(thisNode, index) {
        return scaledR(Math.log(thisNode["amount"]));
      })
      .attr("fill", "lightblue");


    var link = netWorkArea.selectAll("line")
      .data(data.links)
      .enter()
      .append("line")
      .attr("x1", function(thisLink) {
        return scaledX(
          data.nodes.filter(function(node) {
            return node.id == thisLink.node01
          })[0].x);
      })
      .attr("x2", function(thisLink) {
        return scaledX(data.nodes.filter(function(node) {
          return node.id == thisLink.node02
        })[0].x);
      })
      .attr("y1", function(thisLink) {
        return scaledY(data.nodes.filter(function(node) {
          return node.id == thisLink.node01
        })[0].y);
      })
      .attr("y2", function(thisLink) {
        return scaledY(data.nodes.filter(function(node) {
          return node.id == thisLink.node02
        })[0].y);
      })
      .attr("stroke", "black")
      .attr("stroke-width", function(thisLink) {
        return thisLink.amount / 50;
      })
      .attr("stroke-opacity", "0.5")
      .lower();



  });


}

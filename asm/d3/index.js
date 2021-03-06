window.onload = function() {
  var width = 1200;
  var height = 800;

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
      .style("opacity", .4);
    var mouseover = function(d) {
      Tooltip
        .style("opacity", .8);
      d3.select(this)
        .style("stroke", "black")
        .style("opacity", 1);
      Tooltip
        .html(d.id +
          "</br>" + "traded amount: " +
          totalTradejs.filter(function(thisNode) {
            return thisNode.id == d.id;
          })[0].amount +
          "</br>" + "traded with: " +
          totalTradejs.filter(function(thisNode) {
            return thisNode.id == d.id;
          })[0].count)
        .style("top", (event.pageY) + "px")
        .style("left", (event.pageX) + "px");

      data.links.forEach(function(link) {
        if (link.node01 == d.id || link.node02 == d.id) {
          d3.selectAll("line").filter(function(link) {
            return link.node01 == d.id || link.node02 == d.id
          }).style("opacity", 1.2);
          d3.selectAll("circle").filter(function(node) {
            return link.node01 == node.id || link.node02 == node.id;
          }).style("opacity", 1);
        }
      });
    };

    var mouseleave = function(d) {
      Tooltip
        .style("opacity", 0);
      d3.selectAll("line")
        .style("stroke", "black")
        .style("opacity", 0.3);
      d3.selectAll("circle")
        .style("stroke", "black")
        .style("opacity", 0.3);
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
      totalTrade[node.id] = [0, 0]
    });
    //update this array
    data.links.forEach(function(link) {
      totalTrade[link.node01][0] += link.amount;
      totalTrade[link.node02][0] += link.amount;
      totalTrade[link.node01][1] += 1;
      totalTrade[link.node02][1] += 1;
    });
    //convert to key-value named
    var totalTradejs = [];
    for (var i in totalTrade) {

      totalTradejs.push({
        id: i,
        amount: totalTrade[i][0],
        count: totalTrade[i][1]
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




    var node = netWorkArea.append("g").selectAll("circle")
      .data(data.nodes)
      .enter()
      .append("circle")

      .attr("transform", function(d) {
        return "translate(" + scaledX(d.x) + "," + scaledY(d.y) + ")";
      })
      .attr("r", 20)
      .attr("fill", "black")
      .style("opacity", .3)
      .on("mouseover", mouseover)
      .on("mouseleave", mouseleave);


    node.data(totalTradejs)
      .attr("r", function(d) {
        return scaledR(Math.log(d["amount"]));
      })
      .attr("fill", "lightblue");


    var link = netWorkArea.selectAll("line")
      .data(data.links)
      .enter()
      .append("line")
      .style("opacity", .6)
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
      .attr("stroke-opacity", 0.3)
      .lower();



  });


}

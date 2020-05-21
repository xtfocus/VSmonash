window.onload = function() {
  var svgCanvas = d3.select("svg")
    .attr("class", "svgCanvas") // refer to the svgCanvas class defined in second.css
    .attr("width", 960)
    .attr("height", 540);

  d3.csv("https://raw.githubusercontent.com/xtfocus/VSmonash/master/tut/tutd3/third/third.csv", function(d) //d is the whole array
  {
    console.log("hehe");
    console.log(d);
    console.log("hehe");

    // find the range of data
    var minValue = Infinity;
    var maxValue = -1;

    // this is a loop
    d.forEach(function(thisD) {
      console.log("hoho");
      console.log(thisD); //thisD is each datum (each row)
      console.log("hoho");
      var thisValue = thisD["value"];
      minValue = Math.min(minValue, thisValue);
      maxValue = Math.max(maxValue, thisValue);
    });

    console.log(minValue); // min of data = 19
    console.log(maxValue); //max = 30


    // value2range is a function that takes a value between min,max then scale it on 0.5,1
    var value2range = d3.scaleLinear()
      .domain([minValue, maxValue])
      .range([0.5, 1]);

    console.log(value2range(20)) //expect 0.75




    var range2color = d3.interpolateBlues;


    // draw a circle. a cricle has position (cs, cy) and radius (r)
    svgCanvas.selectAll("circle")
      .data(d).enter()
      .append("circle")
      .attr("cx", function(thisEle, index) {
        // compute the centres of circles
        return 150 + index * 150;
      })
      .attr("cy", 300)
      .attr("r", function(thisEle, index) {
        // use the value as radius
        return thisEle["value"];
      })
      .attr("fill", function(thisEle, index) {
        return range2color(value2range(thisEle["value"]))
      });

    svgCanvas.selectAll("text")
      .data(d).enter()
      .append("text")
      .attr("x", function(thisEle, index) {
        return 150 + index * 150;
      })
      .attr("y", 300 - 35)
      .attr("text-anchor", "middle")
      .text(function(thisEle, index) {
        return thisEle["title"] + ":" + thisEle["value"];
      });

  });
}

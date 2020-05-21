window.onload = function() {
  // Create a svg canvas
  var svgCanvas = d3.select("svg")
    .attr("class", "svgCanvas") // refer to the svgCanvas class defined in second.css
    .attr("width", 960)
    .attr("height", 540);

  svgCanvas.append("rect")
  //100,100 from top left is the location of the rectangle
  .attr("x", 100)
  .attr("y", 100)
  .attr("width", 100)
  .attr("height", 50)
  .attr("fill", "lightblue");

  svgCanvas.append("line")
  //draw a line connecting (300,400) and (300,200)
  .attr("x1", 300)
  .attr("y1", 400)
  .attr("x2", 300)
  .attr("y2", 200)
  .attr("stroke", "red")
}

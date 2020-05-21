var width = 960;
var height = 540;


var thisCanvas = d3.select("svg")
  .attr("width", width)
  .attr("height", height)
  .attr("class", "svgCanvas");

var margin = {
  top: 10,
  right: 20,
  bottom: 30,
  left: 50
};
width = width - margin.left - margin.right;
height = height - margin.top - margin.bottom;



var networkArea = thisCanvas
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

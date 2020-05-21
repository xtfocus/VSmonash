window.onload = function(){

  console.log("Content loaded")
  //Use DOM to find the FIRST title html element
  var titleElement = document.getElementsByTagName("h1")[0];

  //Change text to 5147 when mouse hovering on the h1 title
  titleElement.onmouseover = function(){
    titleElement.innerHTML = "FIT5147";
  };
  // Change it back to Mantis Shrimps when mouse leaves h1
  titleElement.onmouseout = function(){
    titleElement.innerHTML = "Mantis Shrimps"
  };
}

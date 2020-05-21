window.onload = function(){
  d3.csv("https://lms.monash.edu/pluginfile.php/10734732/mod_book/chapter/697761/third.csv", function(d){
    console.log(d);
  })
  ;
}

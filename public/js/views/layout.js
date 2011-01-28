$(document).ready(function(){
  var selected = $(".header-box").text();
  
  $("#s" + selected).show();
  $("a.icon#"+selected).addClass("selected");
  
  $("a.icon").click(function(){
    $("#s" + selected).hide('blind', 100);
    $("a.icon#"+selected).removeClass("selected");
    selected = $(this).attr('id');
    $(".header-box").text(selected);
    $("a.icon#"+selected).addClass("selected");
    $("#s" + selected).show('blind', 250);
  });
  
  $(".secondary-row").click(function(){
    $(".secondary-row").removeClass("selected");
    
    $(this).addClass("selected");
    var sidebar = $(".secondary-navigation");
    var content = $(".selected-content");
    content.html("");
    $(".spinner").show();
    $.get($(this).attr("href"), function(data){
      sidebar.height('auto');
      var page = $("<div style='display: none'>"+data+"</div>");
      content.append(page);
      $(".spinner").hide();
      
      page.fadeIn(500);
      if (content.height() > sidebar.height()) sidebar.height(content.height());
    });
  });
});
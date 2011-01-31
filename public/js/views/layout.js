$(document).ready(function(){
  var selected = $(".init-selected").text();
  var sidebar = $(".secondary-navigation");
  var content = $(".selected-content");
  if (content.height() > sidebar.height()) sidebar.height(content.height());
  
  
  $("#s" + selected).show();
  $("a.icon#"+selected).addClass("selected");
  
  $("a.icon").click(function(){
    if (selected == $(this).attr('id')) return false;
    $("#s" + selected).hide('blind', 100);
    $("a.icon#"+selected).removeClass("selected");
    selected = $(this).attr('id');
    $("a.icon#"+selected).addClass("selected");
    var sidebar = $(".secondary-navigation");
    var content = $(".selected-content");
    sidebar.height('auto');
    $("#s" + selected).show('blind', 250, function(){
      if (content.height() > sidebar.height()) sidebar.height(content.height());
    });
    
  });
  
  $(".secondary-row").click(function(){
    $(".secondary-row").removeClass("selected");
    $(".header-box").text($(this).text());
    
    $(this).addClass("selected");
    var sidebar = $(".secondary-navigation");
    var content = $(".selected-content");
    content.html("");
    $(".spinner").show();
    $.get($(this).attr("href"), function(data){
      sidebar.height('auto');
      var page = $("<div style='display: none'>"+data+"</div>");
      content.html(page);
      $(".spinner").hide();
      
      page.fadeIn(500);
      if (content.height() > sidebar.height()) sidebar.height(content.height());
    });
  });
});
var EnterKey = 13;
var thing = null;
$(document).ready(function(){
  var selected = $(".init-selected").text();
  var sidebar = $(".secondary-navigation");
  var content = $(".selected-content");
  $(".header-box").html($(".secondary-row.selected").children(".page-title").html());
  
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
    if ($(this).children(".search-field").length != 0) return true;
    $(".secondary-row").removeClass("selected");
    $(".header-box").html($(this).children(".page-title").html());
    
    $(this).addClass("selected");
    var sidebar = $(".secondary-navigation");
    var content = $(".selected-content");
    content.html("");
    $(".spinner").show();
    removeListeners();
    $.get($(this).attr("href"), function(data){
      sidebar.height('auto');
      var page = $("<div style='display: none'>"+data+"</div>");
      content.html(page);
      $(".spinner").hide();
      
      page.fadeIn(500);
      if (content.height() > sidebar.height()) sidebar.height(content.height());
      $(".scroll-bottom").attr("scrollTop",$(".scroll-bottom").attr("scrollHeight"));
    });
  });
  
  $(document).keydown(function(e){
    if ($("input.focus").length != 0) return true;
    //if currently in a text box/area, return true
    if (e.keyCode == '1'.charCodeAt(0)){
      $("a.icon#home").click();
      return false;
    }
    if (e.keyCode == '2'.charCodeAt(0)){
      $("a.icon#discussions").click();
      return false;
    }
    if (e.keyCode == '3'.charCodeAt(0)){
      $("a.icon#groups").click();
      return false;
    }
    if (e.keyCode == '4'.charCodeAt(0)){
      $("a.icon#events").click();
      return false;
    }
    if (e.keyCode == '5'.charCodeAt(0)){
      $("a.icon#messages").click();
      return false;
    }
  });
  
  $('input').live('keydown', function(e){
    if ($(this).hasClass(".search-field")){
      //instant search
    }else if (e.keyCode == EnterKey){
      //delayed content posting
      var value = $(this).val();
      $(this).val("");
      $.post($(this).attr("href"),{content: value}, function(data){
        data = JSON.parse(data);
        $(data.container).append(data.content);
        
        //this probably doesn't work with more than one div. The second scroll-bottom will always be the first match
        $(".scroll-bottom").stop(true,true).animate({ scrollTop: $(".scroll-bottom").attr("scrollHeight")}, 500, 'easeOutQuad');
        
      });
    }
  });
  
  $('input').live('blur', function(){
    $('input').removeClass("focus");
  }).live('focus', function() {
    $(this).addClass("focus");
  });
});


function removeListeners(){
  if (typeof conversationListener != 'undefined') conversationListener.disconnect();
  if (typeof discussionListener != 'undefined') discussionListener.disconnect();
  
}



$(function(){
  $.extend($.fn.disableTextSelect = function() {
    return this.each(function(){
      if($.browser.mozilla){//Firefox
        $(this).css('MozUserSelect','none');
      }else if($.browser.msie){//IE
        $(this).bind('selectstart',function(){return false;});
      }else{//Opera, etc.
        $(this).mousedown(function(){return false;});
      }
    });
  });
  $('.no-select').disableTextSelect();//No text selection on elements with a class of 'noSelect'  
});
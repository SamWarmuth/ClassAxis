// Initialize jQuery Visualise
$(function(){
	$('#stats').visualize({type: 'line', height: '300px', width: '600px'});
});

// Sidebar Toggle
var fluid = {
Toggle : function(){
	var default_hide = {"grid": true };
	$.each(
		["pagesnav", "commentsnav", "userssnav", "imagesnav"],
		function() {
			var el = $("#" + (this == 'accordon' ? 'accordion-block' : this) );
			if (default_hide[this]) {
				el.hide();
				$("[id='toggle-"+this+"']").addClass("hidden")
			}
			$("[id='toggle-"+this+"']")
			.bind("click", function(e) {
				if ($(this).hasClass('hidden')){
					$(this).removeClass('hidden').addClass('visible');
					el.slideDown();
				} else {
					$(this).removeClass('visible').addClass('hidden');
					el.slideUp();
				}
				e.preventDefault();
			});
		}
	);
}
}
jQuery(function ($) {
	if($("[id^='toggle']").length){fluid.Toggle();}
});









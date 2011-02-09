$(function() {

  $('#dynamic_search').focus().val("");

  $('#remember').buttonset();
	
	$('#dynamic_search').autocomplete({
				source: "",
				minLength: 2
			});
});


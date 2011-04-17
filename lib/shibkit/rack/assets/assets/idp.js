
if ($('#username').length) {
    $("#username").focus();
}

$(".autotyper").each( function() {
	var text = $(this).data('cred')
  $(this).bind('click', function(){
    
    $('#username').delay(400).show().autotype(text, {delay: 80});
    $('#password').delay(3000).show().autotype(text, {delay: 200});

  })
});

/* Hoi Polloi! */

$(function(){
	if ($('.load-from-server').length > 0)
	{
		$('.load-from-server').each(function(){
			var $div = $(this);

			$.post($div.attr('data-remote-url'), {}, function(data){
				$('#conversations-spinner').hide();
				$div.html(data);
				$('#conversations-table').slideDown();
			});
		});
	}
});
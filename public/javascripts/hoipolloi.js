/* Hoi Polloi! */

$(function(){

	/**
	 * Refresh the list of mentions
	 */
	function refreshDesirables()
	{
		var $div = $(this);
		
		// $('#conversations-spinner').show();

		// $.post($div.attr('data-remote-url'), {}, function(data){
		// 	$('#conversations-spinner').hide();
		// 	$div.html(data);
		// 	$('#conversations-table').slideDown();
		// });
	}

	/**
	 * Auto-update the desirables on page load
	 */
	if ($('.load-from-server').length > 0)
	{
		$('.load-from-server').each(refreshDesirables);
	}

	/**
	 * Allow users to manually refresh desirables
	 */
	$('#refresh-desirables').click(function(){
		$('.load-from-server').each(refreshDesirables);
		return false;
	});
});
/* Hoi Polloi! */

$(function(){

	/**
	 * Refresh the list of mentions
	 */
	function refreshDesirables()
	{
		var $div = $(this);
		
		$('#progress-indicator').removeClass('icon-ok-sign').addClass('icon-refresh');

		$.post($div.attr('data-remote-url'), {}, function(data){
			$('#progress-indicator').removeClass('icon-refresh').addClass('icon-ok-sign');
			$div.html(data);
			$('#conversations-table').slideDown();
		});
	}

	function autoRefreshDesirables()
	{
		setTimeout(function(){
			refreshDesirables();
			autoRefreshDesirables();
		}, 120000);
	}

	/**
	 * Auto-refresh the desirables
	 */
	if ($('body').attr('data-auto-refresh'))
	{
		autoRefreshDesirables();
	}

	/**
	 * Allow users to manually refresh desirables
	 */
	$('#refresh-desirables').click(function(){
		$('.load-from-server').each(refreshDesirables);
		return false;
	});

	/**
	 * Responsify headers
	 */
	$('header h1').fitText(0.45);

	/**
	 * Check all the checkboxes
	 */
	$('#check_all').change(function(){
		if ($(this).attr('checked') == 'checked')
		{
			var checked = 'checked';
		}
		else
		{
			var checked = false;
		}

		$(this).parents('form').find('input[type="checkbox"]').attr('checked', checked);
	});
});
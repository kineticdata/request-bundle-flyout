$(document).ready(function() {
	// Confirm if the first approver question exists, if not remove approver section
    if(!$('div[label="Approver Login ID"]').exists()) {
        $('#temp-requester-info div.approver, div#approver-tab').remove();
        $('a[href="#approver-tab"]').parent().remove();
    }
    // Load temp requester info into request text area element if it exists
    // Note: this element must have the label "Temp Requester Info"
    var requestFor = $('#temp-requester-info').html();
    $('#temp-requester-info').remove();
    $('div[label="Temp Requester Info"]').html(requestFor);
	
	// Display the "request for" information
	displayRequestForInformation();
	// Display the "approver" information
	if($('div[label="Approver Login ID"]').exists()) {
		displayApproverInformation();
	}

	function displayApproverInformation() {
        // Display the "request for" information in the selectors specified
        // This requester information comes from hidden requester info
        $('#approver-name').html($('div[label="Approver First Name"] input').val() +'&nbsp;'+ $('div[label="Approver Last Name"] input').val());
        $('#approver-site').html($('div[label="Approver Site"] input').val());
        $('#approver-email').html($('div[label="Approver Email"] input').val());
        $('#approver-phone').html($('div[label="Approver Phone"] input').val());
    }

    function displayRequestForInformation() {
        // Display the "approver" information in the selectors specified
        // This approver information comes from hidden requester info
        $('#request-for-name').html($('div[label="ReqFor First Name"] input').val() +'&nbsp;'+ $('div[label="ReqFor Last Name"] input').val());
        $('#request-for-site').html($('div[label="ReqFor Site"] input').val());
        $('#request-for-email').html($('div[label="ReqFor Email"] input').val());
        $('#request-for-phone').html($('div[label="ReqFor Phone"] input').val());
    }
});

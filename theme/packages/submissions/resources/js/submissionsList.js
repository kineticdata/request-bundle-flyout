$(function() {
    // Get query string parameters into an object
    var urlParameters = getUrlParameters();
    // Determine if type is a real type
    if(urlParameters.type !== 'requests' && urlParameters.type !== 'approvals') {
        urlParameters.type = 'requests';
    }
    // Determine if the status is a real status
    var statusCheck = true;
    $.each(tableParams, function(index) { 
        if(urlParameters.status === index) {
            statusCheck = false;
            return false;
        }
    });
    if(statusCheck) {
        if(urlParameters.type === 'requests') {
            urlParameters.status = 'Open Request';
        } else {
             urlParameters.status = 'Pending Approval';
        }
    }
    // Set active link
    $('nav.submissions-navigation ul li').each(function(index, value) {
        if(urlParameters.status == $(this).find('a').data('group-name')) {
            $(this).find('a').addClass('active');
        }
    });

    // Get table specific properties
    var table = tableParams[urlParameters.status];
    // How many entries to show on page load
    var entryOptionSelected = 5;
    // Start table
    initialize(table, urlParameters.status, entryOptionSelected);  
});

var displayFields = {
    'Closed': 'CLOSED ON',
    'Customer Survey Status': 'Customer Survey Status',
    'Display Status': 'Display Status',
    'Id': 'Id',
    'Modified': 'STARTED ON',
    'Originating Id': 'Originating Id',
    'Originating Name': 'Originating Name',
    'Originating Request Id': 'Originating Request Id',
    'Request Id': 'REQUEST ID#',
    'Request Status': 'Request Status',
    'Requested For': 'REQUESTED FOR',
    'Sent': 'SENT ON',
    'Service Item Image': 'Service Item Image',
    'Service Item Type': 'Service Item Type',
    'Submit Type': 'Submit Type',
    'Submitted': 'SUBMITTED ON',
    'Template Name': 'Template Name'
}

/**
 * Define the common table options and callbacks
 */
var tableParams = { 
    // Define table specific properties
    'Open Request': {
        displayFields: displayFields,
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        fieldCallback: defaultFieldCallback,
        completeCallback: defaultCompleteCallback
    },
    'Closed Request': {
        displayFields: displayFields,
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        fieldCallback: defaultFieldCallback,
        completeCallback: defaultCompleteCallback
    },
    'Draft Request': {
        displayFields: displayFields,
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        fieldCallback: defaultFieldCallback,
        completeCallback: defaultCompleteCallback
    },
    'Pending Approval': {
        displayFields: displayFields,
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        fieldCallback: defaultFieldCallback,
        completeCallback: defaultCompleteCallback
    },
    'Completed Approval': {
        displayFields: displayFields,
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        fieldCallback: defaultFieldCallback,
        completeCallback: defaultCompleteCallback
    }
};

/**
 * Row callback
 * Builds the li
 */
function defaultRowCallback(li, record, index, displayFields) {
    // Li styles
    li.addClass('border rounded');

    /* Start left column */
    // Left column Originating Request Id
    var leftColumn = $('<div>').addClass('left border-right')
        .append(
            $('<div>').addClass('request-id-label')
                .append(displayFields['Request Id'] + '&nbsp;')
        ).append(
            $('<div>').addClass('request-id-value')
                .append(record['Originating Request Id'])
        ).append(
            $('<div>').addClass('requested-for-label')
                .append(displayFields['Requested For'] + '&nbsp;')
        ).append(
            $('<div>').addClass('requested-for-value')
                .append(record['Requested For'])
        );

    // Draft date
    if(record['Customer Survey Status'] === 'In Progress') {
        var submissionDateLabel = $('<div>').addClass('submitted-label')
            .append(displayFields['Modified']);
        var submissionDateValue = $('<div>').addClass('submitted-value')
            .append(((record['Modified'] !== null) ? moment(record['Modified']).format('MMMM DD, YYYY') : ""));
    // Closed date including completed approvals
    } else if(record['Request Status'] === 'Closed') {
        var submissionDateLabel = $('<div>').addClass('submitted-label')
            .append(displayFields['Closed']);
        var submissionDateValue = $('<div>').addClass('submitted-value')
            .append(((record['Closed'] !== null) ? moment(record['Closed']).format('MMMM DD, YYYY') : ""));
    // Pending approval date
    } else if(record['Display Status'] === 'Awaiting Approval') {
        var submissionDateLabel = $('<div>').addClass('submitted-label')
            .append(displayFields['Sent']);
        var submissionDateValue = $('<div>').addClass('submitted-value')
            .append(((record['Sent'] !== null) ? moment(record['Sent']).format('MMMM DD, YYYY') : ""));
    // Submitted date
    } else {
        var submissionDateLabel = $('<div>').addClass('submitted-label')
            .append(displayFields['Submitted']);
        var submissionDateValue = $('<div>').addClass('submitted-value')
            .append(((record['Submitted'] !== null) ? moment(record['Submitted']).format('MMMM DD, YYYY') : ""));
    }

    var viewRequestLink = $('<div>').addClass('view-request-details')
        .append(
            $('<a>')
                .attr('href', encodeURI(BUNDLE.applicationPath + 'ReviewRequest?csrv=' + record['Originating Id'] + '&excludeByName=Review Page&reviewPage=' + BUNDLE.config.reviewJsp))
                .attr('target', '_self')
                .append('View Submitted Form')
        );

    // Cannot open auto created requests
    ((record['Service Item Type'] !== BUNDLE.config.autoCreatedRequestType && record['Customer Survey Status'] !== 'In Progress') ? leftColumn.prepend(viewRequestLink) : submissionDateValue.css({'margin':'0 0 20px 0'}));
    leftColumn.prepend(submissionDateValue).prepend(submissionDateLabel);
    li.append(leftColumn);
    /* End left column */

    /* Start middle column */
    var middleColumn = $('<div>').addClass('left middle');

    // Template name
    var contentWrap = $('<div>').addClass('content-wrap')
        .append(
            $('<div>').addClass('originating-name')
                .append(record['Originating Name'])
        );

    // Service item image
    if(record['Service Item Image'] !== null) {
        var image = $('<div>').addClass('image')
            .append(
                $('<img>').attr('width', '60px')
                    .attr('src', BUNDLE.config.serviceItemImagePath + record['Service Item Image'])
            )
        contentWrap.prepend(image);
    }

    // Validation status/display status and content wrap
    middleColumn.append(
        $('<div>').addClass('display-status')
            .append(record['Display Status'])
    ).append(contentWrap);

    li.append(middleColumn);
    /* End middle column */

    /* Start right column */
    var rightColumn = $('<div>').addClass('left');
    // Set instance id used viewing activity (deals with approvals and children requests)
    var instanceId = record['Originating Id'];
    // Complete button
    if(record['Customer Survey Status'] === 'In Progress') {
        rightColumn.append(
            $('<a>').addClass('complete-request templateButton')
                .attr('href', encodeURI(BUNDLE.applicationPath + 'DisplayPage?csrv=' + instanceId + '&return=yes'))
                .append('Complete Form')
        );
    }
    // View activity details button
    if(record['Customer Survey Status'] !== 'In Progress' && record['Submit Type'] !== 'Approval') {
        rightColumn.prepend('<br />')
            .prepend(
                $('<a>').addClass('view-activity templateButton')
                    .attr('href', encodeURI(BUNDLE.config.submissionActivityUrl + '&id=' + instanceId))
                    .attr('target', '_self')
                    .append('View Activity Details')
            );
    }
    // Complete approval button
    if(record['Customer Survey Status'] === 'Sent' && record['Submit Type'] === 'Approval') {
        rightColumn.prepend('<br />')
            .prepend(
                $('<a>').addClass('view-activity templateButton')
                    .attr('href', encodeURI(BUNDLE.applicationPath + 'DisplayPage?csrv=' + record['Id']))
                    .attr('target', '_self')
                    .append('Complete Approval')
            );
    }
    li.append(rightColumn);
    /* End right column */
}

/**
 * Field callback
 */
function defaultFieldCallback(li, value, fieldname, label) {}

/**
 * Complete callback
 */
function defaultCompleteCallback() { $('div.console-list div.header').prepend($('nav.submissions-navigation').removeClass('gradient border').show()); }


function initialize(table, status, entryOptionSelected) {
    var loader = $('div#loader');
    var responseMessage = $('div.results-message');
    // Start list
    $('div.results').consoleList({
        displayFields: table.displayFields,
        paginationPageRange: 5,
        pagination: true,
        entryOptionSelected: entryOptionSelected,
        entryOptions: [5, 10, 20, 50, 100],
        entries: true,
        info: true,
        sortOrder: 'DESC',
        serverSidePagination: true,
        sortOrderField: table.sortField,
        dataSource: function(limit, index, sortOrder, sortOrderField) {
            var widget = this;
            // Execute the ajax request.
            BUNDLE.ajax({
                dataType: 'json',
                cache: false,
                type: 'get',
                url: BUNDLE.packagePath + 'interface/callbacks/submissions.json.jsp?qualification=' + status + '&offset=' + index + '&limit=' + limit + '&orderField=' + sortOrderField + '&order=' + sortOrder,
                beforeSend: function(jqXHR, settings) {
                    widget.consoleList.hide();
                    responseMessage.empty();
                    loader.show();
                },
                success: function(data, textStatus, jqXHR) {
                    loader.hide();
                    if(data.count > 0) {
                        widget.buildResultSet(data.data, data.count);
                        $('h3').hide();
                        widget.consoleList.show();
                    } else {
                        $('section.container nav.submissions-navigation').show();
                        responseMessage.html('<h3>There Are No ' + status + 's</h3>').show();
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    loader.hide();
                    responseMessage.html(errorThrown).show();
                }
            });
        },
        rowCallback: function(li, record, index, displayFields) { table.rowCallback.call(this, li, record, index, displayFields); },
        fieldCallback: function(li, value, fieldname, label) { table.fieldCallback.call(this, li, value, fieldname, label); },
        completeCallback: function() { table.completeCallback.call(this); }
    });
}
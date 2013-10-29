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

/**
 * Define the common table options and callbacks
 */
var tableParams = { 
    // Define table specific properties
    'Open Request': {
        displayFields: {
            'Originating Request Id': 'Request ID',
            'Submitted': 'Submitted',
            'Originating Name': 'Service Item',
            'Display Status': 'Status'
        },
        sortField: 'Submitted',
        rowCallback: defaultRowCallback,
        columnCallback: defaultColumnCallback,
        completeCallback: defaultCompleteCallback
    },
    'Closed Request': {
        displayFields: {
            'Originating Request Id': 'Request ID',
            'Closed': 'Closed',
            'Originating Name': 'Service Item',
            'Display Status': 'Status'
        },
        sortField: 'Closed',
        rowCallback: defaultRowCallback,
        columnCallback: defaultColumnCallback,
        completeCallback: defaultCompleteCallback
    },
    'Draft Request': {
        displayFields: {
            'Originating Request Id': 'Request ID',
            'Modified': 'Started',
            'Originating Name': 'Service Item',
            'Display Status': 'Status'
        },
        sortField: 'Modified',
        rowCallback: defaultRowCallback,
        columnCallback: defaultColumnCallback,
        completeCallback: requestsParkedCompleteCallback
    },
    'Pending Approval': {
        displayFields: {
            'Originating Request Id': 'Request ID',
            'Sent': 'Sent',
            'Originating Name': 'Service Item',
            'Display Status': 'Status'
        },
        sortField: 'Sent',
        rowCallback: defaultRowCallback,
        columnCallback: defaultColumnCallback,
        completeCallback: approvalsPendingCompleteCallback
    },
    'Completed Approval': {
        displayFields: {
            'Originating Request Id': 'Request ID',
            'Submitted': 'Submitted',
            'Originating Name': 'Service Item',
            'Display Status': 'Status'
        },
        sortField: 'Submitted',
        rowCallback: defaultRowCallback,
        columnCallback: defaultColumnCallback,
        completeCallback: defaultCompleteCallback
    }
};

/*
 * Default row callback
 */
function defaultRowCallback(tr, value, index) {
    tr.data('Originating Id', value['Originating Id']);
    tr.data('Id', value['Id']);
}

/*
 * Default column callback
 */
function defaultColumnCallback(td, value, fieldname, label) {
    // qtip options
    var qtipOptions = {
        content: {
            attr: 'data-timestamp'
        },
        style: {
            corner: 'bottom left',
            classes: 'ui-tooltip-tipsy ui-tooltip-shadow'
        },
        position: {
            my: 'right bottom',
            at: 'top middle'
        }
    };
    // Note::jQuery data doesn't work on td
    if(fieldname === 'Sent' || fieldname === 'Submitted' || fieldname === 'Closed' || fieldname === 'Modified') {
        td.attr('data-timestamp', ((value !== null) ? moment(value).format('YYYY-MM-DD hh:mm:ss a') : ""))
        .qtip(qtipOptions)
        .text(
            moment(td.text()).fromNow()
        )
    }
    if(fieldname === 'Originating Request Id') { td.html($('<a>').addClass('review').attr('href', 'javascript:void()').append(value)); }
}

/**
 * Default Complete callback
 */
function defaultCompleteCallback() {
    // Unobstrusive live click event for view details
    this.consoleTable.on('click touchstart', 'table tbody tr', function(event) {
        // Prevent default action.
        event.preventDefault();
        event.stopImmediatePropagation();
        window.open(BUNDLE.config.submissionActivityUrl + '&id=' + $(this).data('Originating Id'));
    });

    // jQuery unobstrusive live on click event for review request
    this.consoleTable.on('click touchstart', 'table tbody tr td a.review', function(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        window.open(BUNDLE.applicationPath + 'ReviewRequest?excludeByName=Review%20Page&csrv=' + $(this).parents('tr').data('Originating Id'));
    });
}

/**
 * Complete callback for parked requests
 */
function requestsParkedCompleteCallback() {
    // Unobstrusive live click event for view details
    this.consoleTable.on('click touchstart', 'table tbody tr', function(event) {
        // Prevent default action.
        event.preventDefault();
        event.stopImmediatePropagation();
        window.open(BUNDLE.applicationPath + 'DisplayPage?csrv=' + $(this).data('Originating Id') + '&return=yes');
    });
}

/**
 * Complete callback for pending requests
 */
function approvalsPendingCompleteCallback() {
    // Unobstrusive live click event for view details
    this.consoleTable.on('click touchstart', 'table tbody tr', function(event) {
        // Prevent default action.
        event.preventDefault();
        event.stopImmediatePropagation();
        window.open(BUNDLE.applicationPath + 'DisplayPage?csrv=' + $(this).data('Id'));
    });
}

function initialize(table, status, entryOptionSelected) {
    var loader = $('div#loader');
    var responseMessage = $('div.results-message');
    // Start list
    $('div.results').consoleTable({
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
                    widget.element.hide();
                    responseMessage.empty();
                    loader.show();
                },
                success: function(data, textStatus, jqXHR) {
                    loader.hide();
                    if(data.count > 0) {
                        widget.buildResultSet(data.data, data.count);
                        $('h3').hide();
                        widget.consoleTable.show();
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
        rowCallback: function(tr, value, index) { table.rowCallback.call(this, tr, value, index); },
        columnCallback: function(td, value, fieldname, label) { table.columnCallback.call(this, td, value, fieldname, label); },
        completeCallback: function() { table.completeCallback.call(this); }
    });
}
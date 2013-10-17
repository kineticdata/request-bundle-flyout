$(function() {
    // Instantiate object
    var arsUrl = new ArsUrl();
    var loader = $('div#loader');
    var responseMessage = $('div.results-message');
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

    // Initialize datatables
    // Get table specific properties
    var table = tableParams[urlParameters.status];
    // Fluent interface to set properties and build url
    arsUrl.setForm(table.formDefinition.form)                 
            .setFields(table.formDefinition.fields)
            .setFieldIds()
            .setQualification(table.qualification)
            .setUrl(BUNDLE.packagePath + 'interface/callbacks/dataTablesSubmissions.json.jsp');
        
    // Datatable
    $(table.container).dataTable({
        'bPaginate': true,
        'bSort': true,
        'bLengthChange': true,
        'bInfo': true,
        'bDestroy': true,
        'bFilter': false,
        'iDisplayStart': 0,
        'iDisplayLength': 10,
        'bJQueryUI': true,
        'sAjaxDataProp': 'aaData',
        'bProcessing': true,
        'bServerSide': true,
        'sAjaxSource': arsUrl.getUrl(),
        'sPaginationType': 'full_numbers',
        'aaSorting': [[1, 'desc']],
        'sDom': '<"fg-toolbar ui-toolbar ui-widget-header ui-corner-tl ui-corner-tr ui-helper-clearfix" lfrp>t<"fg-toolbar ui-toolbar ui-widget-header ui-corner-bl ui-corner-br ui-helper-clearfix"ip>',
        /**
         * ColumnDefs has many options for manipulation of column specific data
         * mRender can be used to render column data from json object
         */
        'aoColumnDefs': table.columnDefinitions,
        'fnServerData': function (sSource, aoData, fnCallback, oSettings) { 
            oSettings.jqXHR = BUNDLE.ajax({
                'dataType': 'json',
                'type': 'get',
                'url': sSource,
                'data': aoData,
                'success': function(json) {
                    if(json.iTotalDisplayRecords > 0) {
                        fnCallback(json);
                        $('h3').hide();
                    } else {
                        loader.hide();
                        responseMessage.html('<h3>There Are No ' + urlParameters.status + 's</h3>').show();
                    }       
                }
            });
        },
        'fnRowCallback': function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            table.rowCallback(table, nRow, aData, iDisplayIndex, iDisplayIndexFull);
        },
        'fnInitComplete': function(oSettings, json) {
            table.completeCallback(table, oSettings, json);
            $(loader).hide();
            $('#submissions').fadeIn();
            $(table.container).show();
        }
    });
});

/**
 * Define form defintions
 */
formDefinitionDefault = {
form: 'KS_SRV_CustomerSurvey', 
fields: {
        'Request Id'   : '536870913',
        'Submitted'    : '700001285',
        'Service Item' : '700001000',
        'Status'       : '700002400',
        'Instance Id'  : '179',
        'First Name'   : '300299800',
        'Last Name'    : '700001806'
    }
};

formDefinitionDrafts = {
form: 'KS_SRV_CustomerSurvey', 
fields: {
        'Request Id'   : '536870913',
        'Modified'     : '6',
        'Service Item' : '700001000',
        'Status'       : '700002400',
        'Instance Id'  : '179',
        'First Name'   : '300299800',
        'Last Name'    : '700001806'
    }
};

formDefinitionPendingApprovals = {
form: 'KS_SRV_CustomerSurvey', 
fields: {
        'Request Id'   : '700088607',
        'Sent'         : '700001282',
        'Service Item' : '700001000',
        'Status'       : '700002400',
        'Instance Id'  : '179',
        'First Name'   : '300299800',
        'Last Name'    : '700001806'
    }
};

/**
 * Column defintions default
 */
columnDefinitionsDefault = [
    {
        'aTargets': [0],
        'sTitle': 'Request ID',
        'iDataSort': formDefinitionDefault.fields['Request Id'],
        'mRender': function (data, type, full) {
            return full[0];                        
        }                 
    },
    {
        'aTargets': [1],
        'sTitle': 'Submitted',
        'iDataSort': formDefinitionDefault.fields['Submitted'],
        'mRender': function (data, type, full) {
            return full[1];                        
        }                 
    },
    {
        'aTargets': [2],
        'sTitle': 'Service Item',
        'iDataSort': formDefinitionDefault.fields['Service Item'],
        'mRender': function (data, type, full) {
            return full[2];                   
        }                 
    },
    {
        'aTargets': [3],
        'sTitle': 'Status',
        'iDataSort': formDefinitionDefault.fields['Status'],
        'mRender': function (data, type, full) {
            return full[3];                    
        }                 
    }
];

/**
 * Column defintions draft
 */
columnDefinitionsDrafts = [
    {
        'aTargets': [0],
        'sTitle': 'Request ID',
        'iDataSort': formDefinitionDrafts.fields['Request Id'],
        'mRender': function (data, type, full) {
            return full[0];                        
        }                 
    },
    {
        'aTargets': [1],
        'sTitle': 'Modified',
        'iDataSort': formDefinitionDrafts.fields['Modified'],
        'mRender': function (data, type, full) {
            return full[1];                        
        }                 
    },
    {
        'aTargets': [2],
        'sTitle': 'Service Item',
        'iDataSort': formDefinitionDrafts.fields['Service Item'],
        'mRender': function (data, type, full) {
            return full[2];                   
        }                 
    },
    {
        'aTargets': [3],
        'sTitle': 'Status',
        'iDataSort': formDefinitionDrafts.fields['Status'],
        'mRender': function (data, type, full) {
            return full[3];                    
        }                 
    }
];

/**
 * Column defintions draft
 */
columnDefinitionsPendingApprovals = [
    {
        'aTargets': [0],
        'sTitle': 'Request ID',
        'iDataSort': formDefinitionPendingApprovals.fields['Request Id'],
        'mRender': function (data, type, full) {
            return full[0];                        
        }                 
    },
    {
        'aTargets': [1],
        'sTitle': 'Sent',
        'iDataSort': formDefinitionPendingApprovals.fields['Sent'],
        'mRender': function (data, type, full) {
            return full[1];                        
        }                 
    },
    {
        'aTargets': [2],
        'sTitle': 'Service Item',
        'iDataSort': formDefinitionPendingApprovals.fields['Service Item'],
        'mRender': function (data, type, full) {
            return full[2];                   
        }                 
    },
    {
        'aTargets': [3],
        'sTitle': 'Status',
        'iDataSort': formDefinitionPendingApprovals.fields['Status'],
        'mRender': function (data, type, full) {
            return full[3];                    
        }                 
    }
];

/**
 * Default row callback, which will add csrv as a data attribute to each row
 */
function defaultRowCallback(table, nRow, aData, iDisplayIndex, iDisplayIndexFull) {
    $(nRow).data('csrv', aData[4]);
}

/**
 * Default complete callback, which will bind a unobtrusive jQuery live on click event.
 * It uses the data attribute csrv as part of the url param in the link
 */
function defaultCompleteCallback(table, oSettings, json) {}

/**
 * Custom complete callback, which will bind a unobtrusive jQuery live on click event.
 * It uses the data attribute csrv as part of the url param in the link
 */
function requestsOpenClosedCompleteCallback(table, oSettings, json) {
    // Instantiate objects
    var msg = new Message();
    var dialogInit = new DialogInitializer();
    var dialogOptions = {
        title: 'Submission Details',
        closeText: '',
        width: 680,
        maxHeight: 400,
        position:['middle', 140],
        close: function(event, ui) {
            // Unbind click event inside details panel
            $('div.worklogs-expand').off('click', 'a');
            // Destroy wrap that is being using in dialog to release it from animate in dialog create
            $('div.submission-details-wrap').dialog('destroy');
        }
    };
    // Unobstrusive live click event for view details
    $('#submissions').on('click', 'table tbody tr', function(event) {
        // Prevent default action.
        event.preventDefault();
        // Store CSRV
        csrv = $(this).data('csrv');
        // Store submission's jsp template id
        templateId = $(this).parents('#submissions').data('template-id');
        // Execute the ajax request.
        BUNDLE.ajax({
            cache: false,
            type: 'get',
            url: BUNDLE.packagePath + 'interface/callbacks/submissionDetails.html.jsp?csrv=' + csrv + '&templateId=' + templateId,
            beforeSend: function(jqXHR, settings) {
                // Fluent interface to set properties and start dialog
                dialogInit.setDialogSelector($('<div class="submission-details-wrap">')) 
                          .setOptions(dialogOptions)
                          .startDialog();
                // Show loading message for ajax delay
                $('div.submission-details-wrap').html('<div id="loader">'+ $('div#loader').html() + '</div>');
            },
            success: function(data, textStatus, jqXHR) {
                $('div.submission-details-wrap').html(data);
                // Events for inside the submission details panel
                $('div.worklogs-expand').on('click', 'a', function(event) {
                    event.preventDefault();
                    $('div.change').slideUp();
                    $('div.worklog').not($(this).parent().nextAll()).slideUp();
                    $(this).parent().nextAll().slideToggle('slow');
                    $('div.submission-details-wrap').stop().animate({ 
                        scrollTop: $('div.submission-details-wrap')[0].scrollHeight 
                    }, 800);
                });
                $('.changeExpand').on('click', 'a', function(event) {
                    event.preventDefault();
                    $('.change').not($(this).parent().next()).slideUp();
                    $('.incident').slideUp();
                    $(this).parent().next().slideToggle('slow', function() {
                    });
                });
            },
            error: function(jqXHR, textStatus, errorThrown) {
                // Display error message
                $('div.submission-details-wrap').html(msg.setMessage(errorThrown).getErrorMessage()).show();
            }
        });
    });
}

/*
 * Define the cell callback for the parked requests table.  This function
 * inserts a link that takes the user to the parked request.
 */
function requestsParkedCompleteCallback(table, oSettings, json) {
    // Unobstrusive live click event to start service item again
    $('#submissions').on('click', 'table tbody tr', function(event) {
        // Prevent default action.
        event.preventDefault();
        window.open(BUNDLE.applicationPath + 'DisplayPage?csrv=' + $(this).data('csrv') + '&return=yes');
    });
}

/*
 * Define the cell callback for the parked requests table.  This function
 * inserts a link that takes the user to review request.
 */
function completedApprovalsCompleteCallback(table, oSettings, json) {
    // Add this class so we can disable table row hovers and cursor looks using css
    $(table.container).addClass('approvals-completed');
}

/**
 * Define the common table options and callbacks
 */
tableParams = { 
    // Define table specific properties
    'Open Request': {
        container: '#submissions table',
        qualification: 'Open Request',
        formDefinition: formDefinitionDefault,
        columnDefinitions: columnDefinitionsDefault,
        rowCallback: defaultRowCallback,
        completeCallback: requestsOpenClosedCompleteCallback
    },
    'Closed Request': {
        container: '#submissions table',
        qualification: 'Closed Request',
        formDefinition: formDefinitionDefault,
        columnDefinitions: columnDefinitionsDefault,
        rowCallback: defaultRowCallback,
        completeCallback: requestsOpenClosedCompleteCallback
    },
    'Draft Request': {
        container: '#submissions table',
        qualification: 'Draft Request',
        formDefinition: formDefinitionDrafts,
        columnDefinitions: columnDefinitionsDrafts,
        rowCallback: defaultRowCallback,
        completeCallback: requestsParkedCompleteCallback
    },
    'Pending Approval': {
        container: '#submissions table',
        qualification: 'Pending Approval',
        formDefinition: formDefinitionPendingApprovals,
        columnDefinitions: columnDefinitionsPendingApprovals,
        rowCallback: defaultRowCallback,
        completeCallback: requestsParkedCompleteCallback
    },
    'Completed Approval': {
        container: '#submissions table',
        qualification: 'Completed Approval',
        formDefinition: formDefinitionPendingApprovals,
        columnDefinitions: columnDefinitionsDefault,
        rowCallback: defaultRowCallback,
        completeCallback: completedApprovalsCompleteCallback
    }
};
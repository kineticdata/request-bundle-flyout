$(document).ready(function() {
    // This hack arranges the buttons to work with float right and show up in the right order
    // NOTE: tried to wrap these in a div but it causes the request events (validation, etc) to unbind for the submit/continue button
    // NOTE: currently there is no perfect css solution with the buttons continue and submit shown on the right until a solution comes around where the 
    // client can better control the html dom structure of these buttons through request.
    $('form#pageQuestionsForm div.previousButton').insertAfter('form#pageQuestionsForm div.submitButton');
    // Infield Label for dialog lookup searches
    $('label.infield').inFieldLabels();
    
    // Instantiate common js classes.
    var dialogInit = new DialogInitializer();
    var tabsInit = new TabsInitializer();
    var paginator = new Paginator();
    var bridges = new Bridges();
    var msg = new Message();
    // Dialog options
    var dialogOptions = {
        closeText: '',
        width: '610px',
        close: dialogClose
    }
    // Boolean check for advance search event
    var click = true;

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

    // On click event for starting tabs and dialog for request for and approver
    $('a.edit-contact').on('click', function(event) {
        event.preventDefault();
        var selectedTab = $(this).data('id');
        var tabOptions = {
            active: selectedTab,
            create: function(event, ui) {
                // ui.index is undefined, this little hax fixes that problem
                ui.index = selectedTab;
                tabsCreate(this, event, ui);
            },
            activate: function(event, ui) {
                tabsSelect(this, event, ui);
            }
        }
        // Fluent interface to set properties and start tabs
        tabsInit.setTabsSelector('#tabs')
                .setOptions(tabOptions)
                .startTabs();
        // Fluent interface to set properties and start dialog
        dialogInit.setDialogSelector('#contactSetup') 
                  .setOptions(dialogOptions)
                  .startDialog();
    });

    // On click event for starting tabs and dialog for custom lookup events
    $('a.add-contact').on('click', function(event) {
        event.preventDefault(); 
        var selectedTab = $(this).data('id');
        var tabTitle = $(this).data('tab-title');
        var linkObj = this;
        var tabOptions = {
            active: selectedTab,
            create: function(event, ui) {
                // Set tab title
                $('a[href="#request-for-tab"]').text(tabTitle);
                // ui.index is undefined, this little hax fixes that problem
                ui.index = selectedTab;
                tabsCreateRequestDriven(linkObj, event, ui);
            }
        }
        // Fluent interface to set properties and start tabs
        tabsInit.setTabsSelector('#tabs')
                .setOptions(tabOptions)
                .startTabs();
        // Fluent interface to set properties and start dialog
        dialogInit.setDialogSelector('#contactSetup') 
                  .setOptions(dialogOptions)
                  .startDialog();
    });

    /**
     * Start Events for the dom elements inside the dialog
     */
    // Unobtrusive key up event for bridged search
    $('#lookupForm p input[name="email"]').autocomplete({
        source: function(req, add) {
            // Hide response message
            $('#response-message').empty();
            // Empty dom elements
            $('#response-message, div.user-information').empty();
            // Hide Selected user information and options
            $('#autocomplete-selected, #advanced-search-selected, div.confirmation').hide();
            var connector = new KD.bridges.BridgeConnector(); 
            var parameters = new Object();
            var attributes = BUNDLE.config['bridgeAttributes'].split(',');
            parameters['Email'] = $('#lookupForm p input[name="email"]').val();
            connector.search('People', 'By Email', {
                attributes: attributes,
                parameters: parameters,
                success: function(list) {
                    // Filter current "Request by and Request for" records from results
                    var results = new Array();
                    for(var i = 0; i < list.records.length; i++) {
                        if(list.records[i].attributes['Login ID'] == $('div[label="ReqBy Login ID"] input').val() || list.records[i].attributes['Login ID'] == $('div[label="ReqFor Login ID"] input').val() || list.records[i].attributes['Login ID'] == $('div[label="Approver Login ID"] input').val() || list.records[i].attributes['Login ID'] == '') {
                           delete list.records[i];
                        }
                        if(list.records[i] !== undefined ) {
                            results.push(list.records[i])
                        }
                    }
                    if(results.length > 0) {
                        add(results);   
                     } else {
                        // Clear any previous data
                        add(new Object());
                        // add(new Object({'item':{'error':'Results Not Found'}}));
                        // Display warning message
                        $('#response-message').html(msg.setMessage('No User(s) Found').getWarningMessage()).show();
                     }
                },
                failure: function(arg) {
                    // add(new Object({'item':{'error':'Results Not Found'}}));
                    // Display error message
                    $('#response-message').html(msg.setMessage(arg.responseMessage).getErrorMessage()).show();
                }
            });
        },
        select: function(e, ui) {
            if(typeof ui.item.error == 'undefined') {
                lookupReset();
                $.each(ui.item.attributes, function(index, value) {
                    $('#autocomplete-selected div.user-information').append('<div data-id="'+index+'" data-value="'+value+'" class="userDetail">'+value+'</div>');
                    $('#autocomplete-selected').show();
                    $('#autocomplete-selected div.confirmation').show();
                });
            }
            return false;
        }
    }).data('ui-autocomplete')._renderItem = function(ul, item) {
        if(typeof item.error == 'undefined') {
            var results = $('<li>').append('<a>' + item.attributes.Email + '<br><span>' + item.attributes['First Name'] + '&nbsp;' + item.attributes['Last Name'] + '</span>' + '<span>&nbsp;*&nbsp;' + item.attributes.Phone + '</span><span>&nbsp;*&nbsp;' + item.attributes.Site + '</span></a>').appendTo(ul);
        } else {
            var results = $('<li>').append('<a>' + item.error + '</a>').appendTo(ul);
        }
        return results;
    };

    // Unobtrusive live on click event for bridged lookup search and pagination
    $('#lookupForm, ul#advanced-search-pagination-links').on('click', 'input[type="submit"], li a', function(event) {
        // Prevent default action.
        event.preventDefault();
        // clear previous data
        $('nav#pagination').html('').hide();
        $('table#advanced-search-results').html('').hide();
        // Validation
        if($('input[name="lastName"]').val().length >= 2) {
            // Show loader
            $('div#loader').show();
            // Empty dom elements
            $('#response-message, div.user-information').empty();
            // Hide
            $('#autocomplete-selected, #advanced-search-selected, div.confirmation').hide();
            // Show table
            $('table#advanced-search-results, ul#advanced-search-pagination-links').show();
            // Pagination
            if(typeof $(this).data('page') !== 'undefined') {
                page = $(this).data('page');
            } else {
                page = 1;
            }
            paginator.setPage(page).setResultsPerPage(4);
            // Start lookup
            var parameters = new Object({'First Name':$('#lookupForm p input[name="firstName"]').val(), 'Last Name':$('#lookupForm p input[name="lastName"]').val()});
            var metadata = new Object({'order': '<%=attribute["First Name"]%>:DESC,<%=attribute["Last Name"]%>:ASC', 'pageSize': paginator.getResultsPerPage(), 'offset': paginator.getIndex()})
            var attributes = BUNDLE.config['bridgeAttributes'].split(',');
            bridges.lookupSearch('People', 'By Multiple Attributes', parameters, attributes, metadata, searchSuccess, searchFailure);
        } else {
            // Display error message inside alert
            $('#response-message').html(msg.setMessage('Last name field requires a minimal of 2 characters').getErrorMessage()).show();
        }
    });

    // Advanced search
    $('a.advanced-search-link').on('click', function (event) {
        event.preventDefault();
        resetLookupInputs();
        // Empty dom elements
        $('#response-message, div.user-information').empty();
        // Hide Selected user information and options
        $('#autocomplete-selected, #advanced-search-selected, div.confirmation').hide();
        // Hide table and links
        $('table#advanced-search-results, ul#advanced-search-pagination-links').hide();
        if(click) {
            $('#lookupForm p input[name="email"]').parent().hide();
            $('div.advanced-search').show();
            $(this).text('(-) Advanced Search');
            click = false;
        } else {
            $('div.advanced-search').hide();
            $('#lookupForm p input[name="email"]').parent().show();
            $(this).text('(+) Advanced Search');
            click = true;
        }
    });

     // On click event for declining contact update
    $('#autocomplete-selected div.confirmation div.answer a.cancel').on('click', function() {
        // Reset
        lookupReset();
    });

    // On click event for declining contact update
    $('#advanced-search-selected div.confirmation div.answer a.cancel').on('click', function() {
        // Empty dom elements
        $('#response-message, div.user-information').empty();
        // Hide Selected user information and options
        $('#autocomplete-selected, #advanced-search-selected, div.confirmation').hide();
        // Show table and links
        $('table#advanced-search-results, ul#advanced-search-pagination-links').show();
    });

    // Live on click event for selecting a lookup search result from the table list
    $('table#advanced-search-results').on('click', 'tbody tr', function(event) {
        $('#response-message, div.user-information').empty();
        $('table#advanced-search-results, ul#advanced-search-pagination-links').hide();
        $.each($.data(this), function(index, value) {
            $('#advanced-search-selected div.user-information').append('<div data-id="'+index+'" data-value="'+value+'" class="userDetail">'+value+'</div>');
            $('#advanced-search-selected').show();
            $('#advanced-search-selected div.confirmation').show();
        });
    });

    // Close button dialog behavior
    $('#close').on('click', function() {
        dialogInit.closeDialog();
    });

    /**
     * End Events for the dom elements inside the dialog
     */

    /**
     * Start action functions which are used by the dialog events 
     */
    // Success function which builds a table with pagination of results from advanced search
    function searchSuccess(list) {
        // Hide loader
        $('div#loader').hide();
        var table = $('table#advanced-search-results');
        table.html('');
        // Filter current "Request by and Request for" records from results
        var results = new Array();
        for(var i = 0; i < list.records.length; i++) {
            if(list.records[i].attributes['Login ID'] == $('div[label="ReqBy Login ID"] input').val() || list.records[i].attributes['Login ID'] == $('div[label="ReqFor Login ID"] input').val() || list.records[i].attributes['Login ID'] == $('div[label="Approver Login ID"] input').val() || list.records[i].attributes['Login ID'] == '') {
               delete list.records[i];
            }
            if(list.records[i] !== undefined ) {
                results.push(list.records[i])
            }
        }
        if(results.length > 0) {
            // Build theader
            var thead = $('<thead>');
            var tr = $('<tr>');
            for(var i = 0; i < list.fields.length; i++) {
                if(list.fields[i] != 'Login ID' && list.fields[i] != 'Site' && list.fields[i] != 'Middle Name') {
                    tr.append('<th>' + list.fields[i] + '</th>');
                }
            }
            thead.append(tr);
            // Build tbody
            var tbody = $('<tbody>');
            for(var i = 0; i < results.length; i++) {
                var tr = $('<tr>');
                if(i % 2 == 0) {
                    tr.addClass('odd');
                } else {
                    tr.addClass('even');
                }
                for(var key in results[i].attributes) {
                    if(key != 'Login ID' && key != 'Site' && key != 'Middle Name') {
                        tr.append('<td>' + results[i].attributes[key] + '</td>');
                    }
                    // Create data records
                    tr.data(key, results[i].attributes[key]);
                }
                tbody.append(tr);
            }
            // Append thead and tbody
            table.append(thead).append(tbody).show();
            // Build pagination links
            paginationData = paginator.setTotal(list.metadata.count)
                                      .setRange(5)
                                      .buildPaginatationData(); 
            var paginationLinks = $('<ul>');
            paginationLinks.attr('id', 'advanced-search-pagination-links');
            paginationLinks.addClass('unstyled');
            for(var key in paginationData.pages) {
                if(key == 'pageNumbers') {
                    for(var i = 1; i < paginationData.pages[key].length; i++) {
                        // Omit Undefined
                        if(typeof paginationData.pages[key][i] !== 'undefined') {
                            // Create Active class based on page
                            if(paginationData.pages[key][i].page == paginator.getPage()) {
                                paginationLinks.append('<li><a class="active" data-page="' + paginationData.pages[key][i].page + '" href="javascript(void);">' + paginationData.pages[key][i].label + '</a>');
                            } else {
                                paginationLinks.append('<li><a data-page="' + paginationData.pages[key][i].page + '" href="JavaScript:void(0);">' + paginationData.pages[key][i].label + '</a>');
                            }
                        }
                    }
                } else {
                    paginationLinks.append('<li><a data-page="' + paginationData.pages[key].page + '" href="JavaScript:void(0);">' + paginationData.pages[key].label + '</a>');
                }
            }
            $('nav#pagination').html(paginationLinks).show();
        } else {
            $('#response-message').html(msg.setMessage('No User(s) Found').getWarningMessage()).show();
        }
    }

    // Error fuction for advanced search
    function searchFailure(arg) {
        // Display error message inside alert
        $('#response-message').html(msg.setMessage(arg.responseMessage).getErrorMessage()).show();
    }

    // Close function that fires when the dialog is closed
    function dialogClose(event, ui) {
        // Destory dialog
        $('#contactSetup').dialog('destroy');
        $('#tabs').tabs('destroy');
        // Reset
        lookupReset();
    }

    // Action functions for the TabsInitializer
    function tabsCreate(obj, event, ui) {
        tabRouter(ui.index);
    }
    function tabsSelect(obj, event, ui) {
        tabRouter(ui.newTab.index());
    }

    // Function for routing the lookup display and action based on which tab is selected
    function tabRouter(index) {
        // Remove previous delegated click handler
        $('#autocomplete-selected div.confirmation div.answer a.save, #advanced-search-selected div.confirmation div.answer a.save').off('click');
        if(index <= 1) {
            $('#lookup').show();
        } else {
            $('#lookup').hide();
        }

        // On click event for saving contact information
        $('#autocomplete-selected div.confirmation div.answer a.save, #advanced-search-selected div.confirmation div.answer a.save').on('click', function() {     
            // Validate "Request by and Request for" records from selected
            if($.trim($('div[data-id="Login ID"]').data('value')) == $('div[label="ReqBy Login ID"] input').val() || $.trim($('div[data-id="Login ID"]').data('value')) == $('div[label="ReqFor Login ID"] input').val() || $.trim($('div[data-id="Login ID"]').data('value')) == $('div[label="Approver Login ID"] input').val() || $.trim($('div[data-id="Login ID"]').data('value')) == '') {
                $('#response-message').html(msg.setMessage('Approver cannot be the same as the requester or who the request is for').getErrorMessage()).show();
            } else {
                // Set route action
                if(index == 0) {
                    // Update request for
                    // Loop through each detail and update the hidden input submission values
                    $('div.user-information > div').each(function(index, value) {
                        $('div[label="ReqFor '+$(value).data('id')+'"] input').val($.trim($(value).data('value')));
                    });
                    // Update this new information into temp requester info
                    displayRequestForInformation();
                } else if(index == 1) {
                    // Update approver
                    // Loop through each detail and update the hidden input submission values
                    $('div.user-information > div').each(function(index, value) {
                        $('div[label="Approver '+$(value).data('id')+'"] input').val($.trim($(value).data('value')));
                    });
                    // Update this new information into temp requester info
                    displayApproverInformation();
                    // Update approver "Add" link to say "Change"
                    $('div.approver div.contact a.edit-contact').text('Change');
                }
                // Hide yes no
                $('#autocomplete-selected div.confirmation, #advanced-search-selected div.confirmation').hide();
                // User selected, close dialog
                $('#contactSetup').dialog('close');
            }
        });
    }

    // Action function for request driven lookup and question answer map results
    function tabsCreateRequestDriven(obj, event, ui) {
        // Remove previous delegated click handler
        $('#autocomplete-selected div.confirmation div.answer a.save, #advanced-search-selected div.confirmation div.answer a.save').off('click');
        // On click event for saving contact information
        $('#autocomplete-selected div.confirmation div.answer a.save, #advanced-search-selected div.confirmation div.answer a.save').on('click', function() {
            // Loop through each detail and update the input submission values
            var questionNames = $(obj).data('question-map').split(',');
            var fieldMapper = new Object();
            for(var i = 0; i < questionNames.length; i++) {
                var splitted = questionNames[i].split(':');
                fieldMapper[$.trim(splitted[0])] = $.trim(splitted[1]);
            }
            $('div.user-information > div').each(function(index, value) {
                for(var key in fieldMapper) {
                    if(key == $(value).data('id')) {
                        $('div[label="'+fieldMapper[key]+'"] input').val($.trim($(value).data('value')));
                    }
                }
            });
            // Hide yes no
            $('#autocomplete-selected div.confirmation, #advanced-search-selected div.confirmation').hide();
            // User selected, close dialog
            $('#contactSetup').dialog('close');
        });
    }

    function displayApproverInformation() {
        // Display the "request for" information in the selectors specified
        // This requester information comes hidden requester info
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

    // This results all the states inside the dialog
    function lookupReset() {
        resetLookupInputs();
        $('#response-message, div.user-information, table#advanced-search-results, ul#advanced-search-pagination-links').empty();
        $('#autocomplete-selected, #advanced-search-selected, div.confirmation, div.advanced-search').hide();
        $('a.advanced-search-link').text('(+) Advanced Search').next().show();
        click = true;
    }

    function resetLookupInputs() {
        // Clear fields and reset field labels
        $('form#lookupForm input[type="text"]').val('');
        $('form#lookupForm input[type="text"]').focus();
        $('form#lookupForm input[type="text"]').blur();
    }

    /**
     * End action functions which are used by the dialog events and temp requester info
     */
});


/**
 * The KINETIC global namespace object
 * @class KINETIC
 * @static
 */
function $Obj(o){return YAHOO.util.Dom.get(o);}
function $Q(o){return KD.utils.Action.getQuestionValue(o);}
 
if (typeof KINETIC == "undefined") {
    KINETIC = {};
}
if (typeof KINETIC.serviceitems == "undefined") {
    KINETIC.serviceitems = {};
}

if (! KINETIC.serviceitems.Helper){

    KINETIC.serviceitems.Helper= new function(){
        
        this.displ_confirm = function(){
            var name=confirm("Click OK to accept transaction");
            if (name==true){
                document.pageQuestionsForm.submit();
                return true;
            }else{
                window.close();
            }
        }

        this.confirmCancel = function(validationStatus, reqStatus){
            var name=confirm("Click OK to Cancel Request");
            if (name==true){
                if (clientManager.customerSurveyId == "null" || clientManager.customerSurveyId == null){
                    window.location = BUNDLE.config['catalogUrl'];
                } else {
                    KD.utils.Action.setQuestionValue(validationStatus, "Cancelled");    
                    KD.utils.Action.setQuestionValue(reqStatus, "Closed");  
                    document.pageQuestionsForm.submit();
                    return true;
                }
            }else{
                return true;
            }
        }
        this.returnToPortal = function(){
            window.location = BUNDLE.config['catalogUrl'];
        }
        
        this.setOptional = function(validationStatus, saveSw){
            var bSave = document.getElementById("b_save");
            if (bSave) {
                bSave.disabled = true;
            }
            KD.utils.Action.setQuestionValue(saveSw, "Yes");
            KD.utils.Action.setQuestionValue(validationStatus, "Draft");
            var qstns = document.pageQuestionsForm.elements;
            for (var i = 0; i <= qstns.length; i++) {
                if (qstns[i]){
                   qstns[i].setAttribute("required", "");
                }
            }
            document.pageQuestionsForm.submit();
        }

        this.saveForLaterPage = function(catalogName){
            var returnValue = KINETIC.serviceitems.Helper.getParameter("return");
            if (returnValue == "yes") {
                var qstns = document.pageQuestionsForm.elements;
                var myButton;
                for (var i = 0; i <= qstns.length; i++){
                    if (qstns[i]){
                        if(qstns[i].getAttribute("value")=="Back"){
                            myButton=qstns[i];
                        }
                    }
                }
                if(myButton) {
                    myButton.click();
                }
            } else {
                window.location = BUNDLE.config['catalogUrl'];
            }
        }

        this.clickBackButton = function(){
            var returnValue = KINETIC.serviceitems.Helper.getParameter("return");
            if (returnValue == "yes") {
                var qstns = document.pageQuestionsForm.elements;
                var myButton;
                for (var i = 0; i <= qstns.length; i++){
                    if (qstns[i]){
                        if(qstns[i].getAttribute("value")=="Back"){
                            myButton=qstns[i];
                        }
                    }
                }
                if(myButton) {
                    myButton.click();
                }
            }
        }
        
        this.getParameter = function(param) {
            param = param.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            var regexS = "[\\?&]"+param+"=([^&]*)";
            var regex = new RegExp( regexS );
            var results = regex.exec( window.location.href );
            if ( results == null ) 
                return "";
            else
                return results[1];
        }  
      
        // Standard date validation function used to ensure that the date passed is greater than today or 
        // today + a specified number of days  
        this.dateValidation = function(questionIDMDY, numDays){      
            var nowDate = new Date();
            var nowDateArray = new Array();
            nowDateArray[0] = nowDate.getFullYear();
            nowDateArray[1] = nowDate.getMonth() + 1;
            nowDateArray[2] = nowDate.getDate();
            nowDate.setFullYear(nowDateArray[0], (nowDateArray[1] - 1), nowDateArray[2]);

            var nowDateComputed = new Date();
            nowDateComputed.setFullYear(nowDateArray[0], (nowDateArray[1] - 1), nowDateArray[2]);

            // *** do we need to exclude weekend days when adding days here ?? ***
            if (numDays > 0) {
                nowDateComputed.setDate(nowDate.getDate()+numDays);
            } 
 
            // The document.getelementById function simpley retrieves the value from the hidden date field
            // from the date questions on the template
            var dateQuestionElm = KD.utils.Util.getElementObject(questionIDMDY);
            var dateQuestionID = dateQuestionElm.id.substr(7);
            var requestStartDate=document.getElementById("SRVQSTN_" + dateQuestionID).value;

            // The hidden date field stores the date as a string, so the following steps grab the individual
            // values convert them to integers and make a date out of them.
            // This is repeated for both Start and End dates.
            requestStartDateString = requestStartDate.split("-");
            var requestStartDateInt = new Array();
            requestStartDateInt[0] = parseInt(requestStartDateString[0],10);
            requestStartDateInt[1] = parseInt(requestStartDateString[1],10);
            requestStartDateInt[2] = parseInt(requestStartDateString[2],10);
            var requestStartDateFinal = new Date();
            requestStartDateFinal.setFullYear(requestStartDateInt[0], (requestStartDateInt[1] - 1), requestStartDateInt[2]);         

            // Finally, the dates are compared  
            if (numDays == 0 && requestStartDateFinal < nowDate) {
                alert('The date entered cannot be less than today\'s date. Please click OK to return to the service request details page to correct the date.');
                return false; 
            } else {
                return true;
            }
        } // End Function
     
     
        // Standard date validation function used to compare a start date and end date for accuracy
        this.dateValidationRange = function(questionIDStart, questionIDEnd, numDays, errorMsg, errorMsgDuration){
            //Set the current date so it can be put back into the date fields if the error comes up
            var nowDate = new Date();

            var nowDateArray = new Array();
            nowDateArray[0] = nowDate.getFullYear();
            nowDateArray[1] = nowDate.getMonth() + 1;
            nowDateArray[2] = nowDate.getDate();

            // The document.getelementById function simpley retrieves the value from the specified date fields
            // from the date questions on the template
            var startDateQuestionElm = KD.utils.Util.getElementObject(questionIDStart);
            var startDateQuestionID = startDateQuestionElm.id.substr(7);
            var requestStartDate=document.getElementById("SRVQSTN_" + startDateQuestionID).value;
    
            var endDateQuestionElm = KD.utils.Util.getElementObject(questionIDEnd);
            var endDateQuestionID = endDateQuestionElm.id.substr(7);    
            var requestEndDate=document.getElementById("SRVQSTN_" + endDateQuestionID).value;

            // The date field stores the date as a string, so the following steps grab the individual
            // values convert them to integers and make a date out of them.
            // This is repeated for both Start and End dates.
            requestStartDateString = requestStartDate.split('-');
            var requestStartDateInt = new Array();
            requestStartDateInt[0] = parseInt(requestStartDateString[0],10);
            requestStartDateInt[1] = parseInt(requestStartDateString[1],10);
            requestStartDateInt[2] = parseInt(requestStartDateString[2],10);
            var requestStartDateFinal = new Date();
            requestStartDateFinal.setFullYear(requestStartDateInt[0], (requestStartDateInt[1] - 1), requestStartDateInt[2]);

            requestEndDateString = requestEndDate.split('-');
            var requestEndDateInt = new Array();
            requestEndDateInt[0] = parseInt(requestEndDateString[0],10);
            requestEndDateInt[1] = parseInt(requestEndDateString[1],10);
            requestEndDateInt[2] = parseInt(requestEndDateString[2],10);
            var requestEndDateFinal = new Date();
            requestEndDateFinal.setFullYear(requestEndDateInt[0], (requestEndDateInt[1] - 1), requestEndDateInt[2]);
    
            var one_day = 1000*60*60*24;
            var computedDays = Math.ceil((requestEndDateFinal.getTime() - requestStartDateFinal.getTime())/one_day);
    
            // Finally, the dates are compared
            if (requestStartDateFinal>requestEndDateFinal) {   //checks to make sure the end date is greater than the start date
                alert(errorMsg);
                return false;  //the return value of false stops continued processing of the submit action
            } else if (numDays > 0 && computedDays > numDays) {    //checks the number of days between the start and end date entered
                alert(errorMsgDuration);
               return false;  
            } else {
                return true;
            }   
        }        
       
       
    }
};

var siHelper= KINETIC.serviceitems.Helper;

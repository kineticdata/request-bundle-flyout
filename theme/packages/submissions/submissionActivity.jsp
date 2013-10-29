<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%-- Retrieve the Catalog --%>
<%
    // Retrieve the main catalog object
    Catalog catalog = Catalog.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc) so
    // that they are available.  Preloading all of the related objects at once
    // is more efficient than loading them individually.
    catalog.preload(context);

    // Define vairables we are working with
    String templateId = null;
    SubmissionConsole submission = null;
    CycleHelper zebraCycle = new CycleHelper(new String[]{"odd", "even"});
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        templateId =  customerSurvey.getSurveyTemplateInstanceID();
        submission = SubmissionConsole.findByInstanceId(context, customerRequest.getCatalogName(), request.getParameter("id"));
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;|&nbsp;<%= submission.getOriginatingForm()%>&nbsp;|&nbsp;Submission&nbsp;Activity
        </title>
        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/submissionActivity.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
    </head>
    <body>
        <div class="sticky-footer">
            <%@include file="../../common/interface/fragments/header.jspf"%>
            <header class="container border-top border-left border-right">
                <div class="request-status">
                    <h3>
                        <%= submission.getValiationStatus()%>
                    </h3>
                </div>
                <div class="request-information">
                    <div class="left">
                        <div class="wrap">
                            <div class="submitted-label">
                                Submitted On:&nbsp;
                            </div>
                            <div class="submitted-value">
                                <%= DateHelper.formatDate(submission.getCompletedDate(), request.getLocale())%>
                            </div>
                        </div>
                        <% if (submission.getRequestStatus().equals("Closed")) {%>
                            <div class="closed-label">
                                Closed On:&nbsp;
                            </div>
                            <div class="closed-value">
                                <%= DateHelper.formatDate(submission.getRequestClosedDate(), request.getLocale())%>
                            </div>
                        <%}%>
                        <div class="wrap">
                            <div class="request-id-label">
                                Request ID#:&nbsp;
                            </div>
                            <div class="request-id-value">
                                <%= submission.getOriginatingRequestId()%>
                            </div>
                        </div>
                        <div class="wrap">
                            <div class="requested-for-label">
                                Requested For:&nbsp;
                            </div>
                            <div class="requested-for-value">
                                <%=submission.getFirstName()%>&nbsp;<%=submission.getLastName()%>
                            </div>
                        </div>
                    </div>
                    <div class="left middle border-left">
                        <h3>
                            Service Requested
                        </h3>
                        <div class="content-wrap">
                            <% if(submission.getServiceItemImage() != null) {%>
                                <div class="image">
                                    <img width="60px" src="<%= bundle.getProperty("serviceItemImagePath")%><%= submission.getServiceItemImage()%>">
                                </div>
                            <%}%>
                            <div class="originating-name">
                                <%= submission.getOriginatingForm()%> 
                            </div>
                        </div>
                    </div>
                    <div class="left">
                        <% if(!submission.getType().equals(bundle.getProperty("autoCreatedRequestType"))) {%>
                            <a class="view-submitted-form templateButton" target="_self" href="<%= bundle.applicationPath()%>ReviewRequest?csrv=<%=submission.getId()%>&excludeByName=Review%20Page&reviewPage=<%= bundle.getProperty("reviewJsp")%>">
                                View Submitted Form
                            </a>
                        <%}%>
                    </div>
                </div>
            </header>
            <section class="container border">
                <div class="submission-activity">
                    <!-- Start Tasks -->
                    <ul class="tasks unstyled">
                        <% if(submission.getValiationStatus().equals("Cancelled")) {%>
                            <!-- Start display cancelled request notes -->
                            <li class="task cancelled">
                                <header class="clearfix">
                                    <h4>
                                        Request Cancelled
                                    </h4>
                                </header>
                                <hr class="soften" />
                                <%= submission.getNotesForCustomer()%>
                            </li>
                            <!-- End display cancelled request notes -->
                        <%}%>
                        <% for (String treeName : submission.getTaskTreeExecutions(context).keySet()) {%>
                            <% for (Task task : submission.getTaskTreeExecutions(context).get(treeName)) {%>
                            <%
                                // Define ticket related data
                                String incidentId = null;
                                Incident incident = null;
                                String changeId = null;
                                Change change = null;
                                // Define and Get ticket records if they actually exist for current task
                                if (task.getDefName().equals(bundle.getProperty("incidentHandler"))) {
                                    incidentId = task.getResult("Incident Number");
                                    incident = Incident.findById(context, templateId, incidentId);
                                } else if (task.getDefName().equals(bundle.getProperty("changeHandler"))) {
                                    changeId = task.getResult("Change Number");
                                    change = Change.findById(context, templateId, changeId);
                                }
                                String ticketId = null;
                                if (incident != null) {
                                    ticketId = incident.getId();
                                } else if(change != null) {
                                    ticketId = change.getId();
                                }
                            %>
                                <li class="task <%= zebraCycle.cycle()%>" data-task-id="<%= task.getId()%>" data-ticket-id="<%= ticketId%>">
                                    <header class="clearfix">
                                        <h4>
                                            <%= task.getName()%>
                                        </h4>
                                    </header>
                                    <hr class="soften" />
                                    <% if (incident == null && change == null) {%>
                                        <div class="wrap">
                                        <div class="label">Status:</div>
                                            <div class="value">
                                                <%= task.getStatus()%>
                                            </div>
                                        </div>
                                    <%}%>
                                    <div class="wrap">
                                        <div class="label">Initiated:</div>
                                        <div class="value"><%= DateHelper.formatDate(task.getCreateDate(), request.getLocale())%></div>
                                    </div>
                                    <% if (task.getStatus().equals("Closed")) {%>
                                        <div class="wrap">
                                            <div class="label">Completed:</div>
                                            <div class="value"><%= DateHelper.formatDate(task.getModifiedDate(), request.getLocale())%></div>
                                        </div>
                                    <%}%>

                                    <!-- Start Custom Incident and Change details -->
                                    <!-- Pending Reason -->
                                    <% if (incident != null && !incident.getStatusReason().equals("") && incident.getStatus().equals("Pending")) {%>
                                        <div class="label">Pending Reason:</div>
                                        <div class="value">
                                            <span><%= incident.getStatusReason()%></span>
                                        </div>
                                    <% } else if(change != null && !change.getStatusReason().equals("") && change.getStatus().equals("Pending")) {%>
                                        <div class="label">Pending Reason:</div>
                                        <div class="value">
                                            <span><%= change.getStatusReason()%></span>
                                        </div>
                                    <%}%>
                                    <!-- Notes -->
                                    <% if (submission.getType().equals(bundle.getProperty("autoCreatedRequestType")) && incident != null && !incident.getNotes().equals("")) {%>
                                        <div class="label">Notes:</div>
                                        <div class="value">
                                            <span><%= incident.getNotes()%></span>
                                        </div>
                                    <% } else if(submission.getType().equals(bundle.getProperty("autoCreatedRequestType")) && change != null && !change.getNotes().equals("")) {%>
                                        <div class="label">Notes:</div>
                                        <div class="value">
                                            <span><%= change.getNotes()%></span>
                                        </div>
                                    <%}%>
                                    <!-- End Custom Incident and Change details -->

                                    <% if (incident == null && change == null) {%>
                                        <% TaskMessage[] messages = task.getMessages(context); %>
                                        <% if(task.hasMessages()) {%>
                                            <div class="wrap">
                                                <div class="label">Messages:</div>
                                                <div class="value">
                                                    <% for (TaskMessage message : messages) {%>
                                                        <div class="message"><%= message.getMessage()%></div>
                                                    <% }%>
                                                </div>
                                            </div>
                                        <% }%>
                                    <%}%>
                                    <!-- Start Worklogs -->
                                    <%@include file="interface/fragments/worklogs.jspf"%>
                                    <!-- End Worklogs -->
                                </li>
                            <% }%>
                        <% }%>
                    </ul>
                </div>
            </section>
            <div class="sticky-footer-push"></div>
        </div>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>

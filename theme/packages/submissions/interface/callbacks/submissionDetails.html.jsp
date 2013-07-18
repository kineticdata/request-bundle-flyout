<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    // Define vairables we are working with
    String csrv = null;
    Submission submission = null;
    Map<String, Incident> incidentsMapByToken = new java.util.HashMap<String, Incident>();
    Map<String, Change> changesMapByToken = new java.util.HashMap<String, Change>();
    Map<String, Approval> approvalsMapByToken = new java.util.HashMap<String, Approval>();
    CycleHelper zebraCycle = new CycleHelper(new String[]{"odd", "even"});
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        csrv = request.getParameter("csrv");
        submission = Submission.findByInstanceId(context, csrv);
        // Find incidents, changes and approvals and map them by token
        incidentsMapByToken = SubmissionDetailsHelper.mapIncidentsByToken(context, csrv);
        changesMapByToken = SubmissionDetailsHelper.mapChangesByToken(context, csrv);
        approvalsMapByToken = SubmissionDetailsHelper.mapApprovalsByToken(context, csrv);
    }
%>
<% if(submission != null) {%>
    <header class="header">
        <div class="service-item-name"><%= submission.getTemplateName()%></div>
        <div class="options">
            <div class="request-id">
                <a target="_blank" href="<%= bundle.applicationPath()%>ReviewRequest?csrv=<%=submission.getId()%>&excludeByName=Review%20Page&reviewPage=<%= bundle.getProperty("reviewJsp")%>">
                    <%= submission.getRequestId()%>
                </a>
            </div>
       </div>
       <div class="clearfix"></div>
    </header>
    <div class="submission-details">
        <!-- Start Submission Information -->
        <div class="info">
            <div class="wrap">
                <div class="label">Status</div>
                <div class="value"><%= submission.getValiationStatus()%></div>
            </div>
            <div class="wrap">
                <div class="label">Initiated</div>
                <div class="value"><%= DateHelper.formatDate(submission.getCreateDate(), request.getLocale())%></div>
            </div>
            <% if (submission.getRequestStatus().equals("Closed")) {%>
                <div class="wrap">
                    <div class="label">Completed</div>
                    <div class="value"><%= DateHelper.formatDate(submission.getRequestClosedDate(), request.getLocale())%></div>
                </div>
            <%}%>
            <% if(!submission.getNotes().equals("")) {%>
                <div class="wrap">
                    <div class="label">Notes</div>
                    <div class="value"><%= submission.getNotes()%></div>
                </div>
            <%}%>
        </div>
        <!-- End Submission Information -->
        <!-- Start Tasks -->
        <div class="tasks">
            <% for (String treeName : submission.getTaskTreeExecutions(context).keySet()) {%>
                <% for (Task task : submission.getTaskTreeExecutions(context).get(treeName)) {%>
                <%
                // Define and Get incident or change record if they actually exist for current task
                // Used for workinfos and displaying status
                Incident incident = incidentsMapByToken.get(task.getToken()); 
                Change change = changesMapByToken.get(task.getToken());
                // Define and get approvals if they acutally exist for given task
                // Used for displaying approval validation status and not the task status
                Approval approval = approvalsMapByToken.get(task.getToken());
                %>
                    <div class="task <%= zebraCycle.cycle()%>">
                        <div class="wrap">
                            <div class="label">Task</div>
                            <div class="value"><%= task.getName()%></div>
                        </div>
                        <div class="wrap">
                        <div class="label">Status</div>
                            <div class="value">
                                <% if (incident != null && !incident.getStatus().equals("")) {%>
                                    <span><%= incident.getStatus()%></span>
                                <% } else if(change != null && !change.getStatus().equals("")) {%>
                                    <span><%= change.getStatus()%></span>
                                <% } else if(approval != null && !approval.getValiationStatus().equals("")) {%>
                                    <%= approval.getValiationStatus()%>
                                <%} else{%>
                                    <%= task.getStatus()%>
                                <%}%>
                            </div>
                        </div>
                        <div class="wrap">
                            <div class="label">Initiated</div>
                            <div class="value"><%= DateHelper.formatDate(task.getCreateDate(), request.getLocale())%></div>
                        </div>
                        <% if (task.getStatus().equals("Closed")) {%>
                            <div class="wrap">
                                <div class="label">Completed</div>
                                <div class="value"><%= DateHelper.formatDate(task.getModifiedDate(), request.getLocale())%></div>
                            </div>
                        <%}%>
                        <% TaskMessage[] messages = task.getMessages(context); %>
                        <% if(task.hasMessages()) {%>
                            <div class="wrap">
                                <div class="label">Messages</div>
                                <div class="value">
                                    <% for (TaskMessage message : messages) {%>
                                        <div class="message"><%= message.getMessage()%></div>
                                    <% }%>
                                </div>
                            </div>
                        <% }%>
                        <% if (incident != null) {%>
                            <!-- Start Incident Worklogs -->
                            <%
                            IncidentWorkLog[] incidentWorkLogs = IncidentWorkLog.findByIncident(context, incident.getId());
                            if (incidentWorkLogs.length > 0) {
                            %>
                                <div class="worklogs">
                                    <div class="worklogs-expand" class="link">
                                        <a href="javascript: void(0)">
                                            Activity Log(s)
                                        </a>
                                    </div>
                                    <% for (IncidentWorkLog incidentWorkLog : incidentWorkLogs) {%>
                                        <div class="worklog hidden <%= zebraCycle.cycle()%>">
                                            <% if (!incidentWorkLog.getSubmitDate().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Date &amp; Time</div>
                                                    <div class="value"><%= incidentWorkLog.getSubmitDate()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkLog.getSubmitter().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Submitter</div>
                                                    <div class="value"><%= incidentWorkLog.getSubmitter()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkLog.getSummary().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Summary</div>
                                                    <div class="value"><%= incidentWorkLog.getSummary()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkLog.getNotes().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Notes</div>
                                                    <div class="value"><%= incidentWorkLog.getNotes()%></div>
                                                </div>
                                            <% }%>
                                            <% 
                                            Attachment[] attachments = incidentWorkLog.getAttachments();
                                            if (attachments.length > 0) {
                                            %>
                                                <div class="label">Attachment(s)</div>
                                                <br />
                                                <% for (Attachment attachment : attachments) { %>
                                                    <a href="<%=bundle.applicationPath() + SubmissionDetailsHelper.buildAttachmentUrl(attachment)%>">
                                                        <%=attachment.getName()%>
                                                    </a>
                                                    <br />
                                                <% } %>
                                            <%}%>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        <% } %>
                        <!-- End Incident Worklogs -->
                        <% if (change != null) {%>
                            <!-- Start Change Worklogs -->
                            <%
                            ChangeWorkLog[] changeWorkLogs = ChangeWorkLog.findByChangeId(context, change.getId());
                            if (changeWorkLogs.length > 0) {
                            %>
                                <div class="worklogs">
                                    <div class="worklogs-expand" class="link">
                                        <a href="javascript: void(0)">
                                            Activity Log(s)
                                        </a>
                                    </div>
                                    <% for (ChangeWorkLog changeWorkLog : changeWorkLogs) {%>
                                        <div class="worklog hidden <%= zebraCycle.cycle()%>">
                                            <% if (!changeWorkLog.getSubmitDate().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Date &amp; Time</div>
                                                    <div class="value"><%= changeWorkLog.getSubmitDate()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkLog.getSubmitter().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Submitter</div>
                                                    <div class="value"><%= changeWorkLog.getSubmitter()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkLog.getSummary().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Summary</div>
                                                    <div class="value"><%= changeWorkLog.getSummary()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkLog.getNotes().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Notes</div>
                                                    <div class="value"><%= changeWorkLog.getNotes()%></div>
                                                </div>
                                            <% }%>
                                            <% 
                                            Attachment[] attachments = changeWorkLog.getAttachments();
                                            if (attachments.length > 0) {
                                            %>
                                                <div class="label">Attachment(s)</div>
                                                <br />
                                                <% for (Attachment attachment : attachments) { %>
                                                    <a href="<%=bundle.applicationPath() + SubmissionDetailsHelper.buildAttachmentUrl(attachment)%>">
                                                        <%=attachment.getName()%>
                                                    </a>
                                                    <br />
                                                <% } %>
                                            <%}%>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        <% }%>
                        <!-- End Change Worklogs -->
                    </div>
                <% }%>
            <% }%>
        </div>
    </div>
<% } else {%>
    Unable to locate record
<% }%>
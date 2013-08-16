<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    // Define vairables we are working with
    String submissionId = null;
    Submission submission = null;
    String templateId = "KSe3a8e782f9d7b5b85a0ac626042bda13e6";
    Map<String, Incident> incidentsMapByToken = new java.util.HashMap<String, Incident>();
    Map<String, Change> changesMapByToken = new java.util.HashMap<String, Change>();
    CycleHelper zebraCycle = new CycleHelper(new String[]{"odd", "even"});
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        submissionId = request.getParameter("csrv");
        submission = Submission.findByInstanceId(context, submissionId);
        // Find incidents, changes and approvals and map them by token
        incidentsMapByToken = SubmissionDetailsHelper.mapIncidentsByToken(context, templateId, submissionId);
        changesMapByToken = SubmissionDetailsHelper.mapChangesByToken(context, templateId, submissionId);
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
                        <!-- Start Incident Worklogs -->
                        <% if (incident != null) {%>
                            <%
                            BridgeList<IncidentWorkInfo> incidentWorkInfos = IncidentWorkInfo.findByIncidentId(context, templateId, incident.getId());
                            if (incidentWorkInfos.size() > 0) {
                            %>
                                <div class="worklogs">
                                    <div class="worklogs-expand" class="link">
                                        <a href="javascript: void(0)">
                                            Activity Log(s)
                                        </a>
                                    </div>
                                    <% for (IncidentWorkInfo incidentWorkInfo : incidentWorkInfos) {%>
                                        <div class="worklog hidden <%= zebraCycle.cycle()%>">
                                            <% if (!incidentWorkInfo.getSubmitDate().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Date &amp; Time</div>
                                                    <div class="value"><%= incidentWorkInfo.getSubmitDate()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkInfo.getSubmitter().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Submitter</div>
                                                    <div class="value"><%= incidentWorkInfo.getSubmitter()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkInfo.getSummary().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Summary</div>
                                                    <div class="value"><%= incidentWorkInfo.getSummary()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!incidentWorkInfo.getNotes().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Notes</div>
                                                    <div class="value"><%= incidentWorkInfo.getNotes()%></div>
                                                </div>
                                            <% }%>
                                            <%--
                                            <% 
                                            Attachment[] attachments = incidentWorkInfo.getAttachments();
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
                                            --%>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        <% } %>
                        <!-- End Incident Work Infos -->
                        <!-- Start Change Work Infos -->
                        <% if (change != null) {%>
                            <%
                            BridgeList<ChangeWorkInfo> changeWorkInfos = ChangeWorkInfo.findByChangeId(context, templateId, change.getId());
                            if (changeWorkInfos.size() > 0) {
                            %>
                                <div class="worklogs">
                                    <div class="worklogs-expand" class="link">
                                        <a href="javascript: void(0)">
                                            Activity Log(s)
                                        </a>
                                    </div>
                                    <% for (ChangeWorkInfo changeWorkInfo : changeWorkInfos) {%>
                                        <div class="worklog hidden <%= zebraCycle.cycle()%>">
                                            <% if (!changeWorkInfo.getSubmitDate().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Date &amp; Time</div>
                                                    <div class="value"><%= changeWorkInfo.getSubmitDate()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkInfo.getSubmitter().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Submitter</div>
                                                    <div class="value"><%= changeWorkInfo.getSubmitter()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkInfo.getSummary().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Summary</div>
                                                    <div class="value"><%= changeWorkInfo.getSummary()%></div>
                                                </div>
                                            <% }%>
                                            <% if (!changeWorkInfo.getNotes().equals("")) {%>
                                                <div class="wrap">
                                                    <div class="label">Notes</div>
                                                    <div class="value"><%= changeWorkInfo.getNotes()%></div>
                                                </div>
                                            <% }%>
                                            <%--
                                            <% 
                                            Attachment[] attachments = changeWorkInfo.getAttachments();
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
                                            --%>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        <% }%>
                        <!-- End Change Work Infos -->
                    </div>
                <% }%>
            <% }%>
        </div>
    </div>
<% } else {%>
    Unable to locate record
<% }%>
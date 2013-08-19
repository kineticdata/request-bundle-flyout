<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    // Define vairables we are working with
    String submissionId = null;
    Submission submission = null;
    String templateId = "KSGAA5V0FUPJHAMROO5DEB9S66EETP";
    CycleHelper zebraCycle = new CycleHelper(new String[]{"odd", "even"});
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        submission = Submission.findByInstanceId(context, request.getParameter("csrv"));
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
                <% for (Task task : submission.getTaskTreeExecutions(context).get(treeName)) { %>
                    <div class="task <%= zebraCycle.cycle()%>">
                        <div class="wrap">
                            <div class="label">Task</div>
                            <div class="value"><%= task.getName()%></div>
                        </div>
                        <div class="wrap">
                        <div class="label">Status</div>
                            <div class="value"><%= task.getStatus()%></div>
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
                        <% if (task.getDefName().equals(bundle.getProperty("incidentHandler"))) {%>
                            <%
                            String incidentId = task.getResult("Incident Number");
                            Incident incident = Incident.findById(context, templateId, incidentId);
                            BridgeList<IncidentWorkInfo> incidentWorkInfos = IncidentWorkInfo.findByIncidentId(context, templateId, incidentId);
                            %>
                            <div class="wrap">
                                <div class="label">Incident Number</div>
                                <div class="value"><%= incident.getId()%></div>
                            </div>
                            <% if (incidentWorkInfos.size() > 0) { %>
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
                                            <div class="label">Attachment(s)</div>
                                            <br />
                                            <% if (!incidentWorkInfo.getAttachment1().equals("")) {%>
                                            <a href="<%=bundle.applicationPath() + incidentWorkInfo.getAttachment1Url(bundle)%>">
                                                <%=incidentWorkInfo.getAttachment1()%>
                                            </a>
                                            <br />
                                            <% }%>
                                            <% if (!incidentWorkInfo.getAttachment2().equals("")) {%>
                                            <a href="<%=bundle.applicationPath() + incidentWorkInfo.getAttachment2Url(bundle)%>">
                                                <%=incidentWorkInfo.getAttachment2()%>
                                            </a>
                                            <br />
                                            <% }%>                                            
                                            <% if (!incidentWorkInfo.getAttachment3().equals("")) {%>
                                            <a href="<%=bundle.applicationPath() + incidentWorkInfo.getAttachment3Url(bundle)%>">
                                                <%=incidentWorkInfo.getAttachment3()%>
                                            </a>
                                            <br />
                                            <% }%>                                            
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        <% } %>
                        <!-- End Incident Work Infos -->
                        <!-- Start Change Work Infos -->
                        <% if (task.getDefName().equals(bundle.getProperty("changeHandler"))) {%>
                            <%
                            String changeId = task.getResult("Change Number");
                            Change change = Change.findById(context, templateId, changeId);
                            BridgeList<ChangeWorkInfo> changeWorkInfos = ChangeWorkInfo.findByChangeId(context, templateId, changeId);
			    %>
		            <div class="wrap">
				<div class="label">Change Number</div>
				<div class="value"><%= change.getId()%></div>
			    </div>
                            <% if (changeWorkInfos.size() > 0) { %>
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

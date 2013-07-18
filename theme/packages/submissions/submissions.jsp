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
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- 
            Specify that modern IE versions should render the page with their own 
            rendering engine (as opposed to falling back to compatibility mode.
            NOTE: THIS HAS TO BE RIGHT AFTER <head>!
        --%>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta charset="utf-8">
        <title>
            <%= bundle.getProperty("companyName")%> | My Request
        </title>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/submissions.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.dataTables.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/ArsUrl.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/submissions.js"></script>
    </head>
    <body>
        <%@include file="../../common/interface/fragments/header.jspf"%>
        <section class="container">
            <%-- LOADER --%>
            <div id="loader">
                <img alt="Please Wait." src="<%=bundle.bundlePath()%>common/resources/images/spinner.gif" />
                <br />
                Loading Results
            </div>
            <%-- SUBMISSIONS VIEW --%>
            <div id="submissions" class="hidden">
                <table class="hidden"></table>
            </div>
            <%-- SUBMISSION TABLE LINKS --%>
            <% if (context != null) { %>
                <nav class="submissions-navigation">
                    <ul>
                        <% for (String groupName : submissionGroups.keySet()) { %>
                            <%-- Count the number of submissions that match the current query --%>
                            <% Integer count = ArsBase.count(context, "KS_SRV_CustomerSurvey", submissionGroups.get(groupName)); %>
                            <%-- If there are more than 0 records matching, display a link to the table. --%>
                            <% if (count > 0) { %>
                                <li class="">
                                    <a data-group-name="<%=groupName%>" href="<%= bundle.getProperty("submissionsUrl")%>&status=<%=groupName%>">
                                        <%=count%>&nbsp;<%=groupName%>
                                    </a>
                                </li>
                            <% }%>
                        <% }%>
                    </ul>
                </nav>
            <% }%>
        </section>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>

<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file for preparing a review page. --%>
<%@include file="framework/includes/reviewRequestInitialization.jspf"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>
<%
    // Retrieve the main catalog object
    Catalog catalog = Catalog.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc) so
    // that they are available.  Preloading all of the related objects at once
    // is more efficient than loading them individually.
    catalog.preload(context);

    // Retrieve objects
    Template currentTemplate = catalog.getTemplateById(customerSurvey.getSurveyTemplateInstanceID());
    if(currentTemplate == null) {
        throw new Exception("Current template does not exist!");
    }
    Category currentCategory = null;
    if(currentTemplate.hasTemplateAttribute("DefaultCategory")) {
        currentCategory = catalog.getCategoryByName(currentTemplate.getTemplateAttributeValue("DefaultCategory"));
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the bundle common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;|&nbsp;Review&nbsp;|&nbsp;<%= customerRequest.getTemplateName()%>
        </title>
        <%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf" %>
        <%@include file="../../core/interface/fragments/reviewHeadContent.jspf"%>

        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>
        <!-- Package Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/displayPackage.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/reviewPackage.css" type="text/css" />
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/review.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/review.js"></script>

        <%-- Include the form head content, including attached css/javascript files and custom header content --%>
        <%@include file="../../core/interface/fragments/formHeadContent.jspf"%>
    </head>
    <body class="loadAllPages_<%=customerSurveyReview.getLoadAllPages()%> review">
        <%@include file="../../common/interface/fragments/header.jspf"%>
        <header class="container">
            <h2>
                Review: <%= customerRequest.getTemplateName()%>
            </h2>
            <hr class="soften">
        </header>
        <section class="container">
            <%@include file="../../core/interface/fragments/reviewBodyContent.jspf"%>
        </section>
        <!-- Start Temp Requester Information -->
        <div id="temp-requester-info">
            <div class="request-for">
                <h4>
                    This request is for:
                </h4>
                <div class="contact border-left">
                    <div id="request-for-name"></div>
                    <div id="request-for-email"></div>
                    <div id="request-for-phone"></div>
                    <div id="request-for-site"></div>
                </div>
            </div>
            <div class="approver">
                <h4>
                    Approver:
                </h4>
                <div class="contact border-left">
                    <div id="approver-name"></div>
                    <div id="approver-email"></div>
                    <div id="approver-phone"></div>
                    <div id="approver-site"></div>
                </div>
            </div>
        </div>
        <!-- End Temp Requester Information -->
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>
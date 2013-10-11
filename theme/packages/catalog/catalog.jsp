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

    // Get map of description templates
    Map<String, String> templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
    HelperContext systemContext = com.kd.kineticSurvey.impl.RemedyHandler.getDefaultHelperContext();
    List<String> globalTopTemplates = SubmissionStatisticsHelper.getMostCommonTemplateNames(systemContext, new String[] {customerRequest.getCatalogName()}, templateTypeFilterTopSubmissions, 5);
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;<%= bundle.getProperty("catalogName")%>
        </title>
        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/catalog.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/catalog.js"></script>
    </head>
    <body>
        <div class="sticky-footer">
            <%@include file="../../common/interface/fragments/header.jspf"%>
            <header class="container">
                <div class="row">
                    <h2>
                        Popular Requests
                    </h2>
                    <hr class="soften">
                </div>
            </header>
            <section class="container">
                <div class="row">
                    <ul class="templates unstyled">
                        <% for(String templateName : globalTopTemplates) { %>
                            <li class="border-top clearfix">
                                <% Template popularRequest = catalog.getTemplateByName(templateName); %>
                                <div class="content-wrap"> 
                                        <% if (popularRequest.hasTemplateAttribute("ServiceItemImage")) { %>
                                            <div class="image">
                                                <img width="120px" src="<%= bundle.getProperty("serviceItemImagePath") + popularRequest.getTemplateAttributeValue("ServiceItemImage")%>" />
                                            </div>
                                            <div class="description">
                                        <% } else {%>
                                            <div class="description-wide">
                                        <% }%>
                                        <h3>
                                            <%= popularRequest.getName()%>
                                        </h3>
                                        <p>
                                            <%= popularRequest.getDescription() %>
                                        </p>
                                        <% if (templateDescriptions.get(popularRequest.getId()) != null ) { %>
                                            <a class="" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(popularRequest.getId()) %>">
                                                Read More
                                            </a>
                                        <% }%>                                           
                                    </div>
                                    <div class="description-attributes">
                                        <!-- Load description attributes config stored in package config -->
                                        <% for (String attributeDescriptionName : attributeDescriptionNames) {%>
                                            <% if (popularRequest.hasTemplateAttribute(attributeDescriptionName)) { %>
                                                <p>
                                                    <strong><%= attributeDescriptionName%>:</strong> <%= popularRequest.getTemplateAttributeValue(attributeDescriptionName) %>
                                                </p>
                                            <% }%>
                                        <%}%>
                                        <a class="templateButton" href="<%= popularRequest.getAnonymousUrl() %>">
                                            <i class="icon-share-alt"></i>Request this Service
                                        </a>
                                    </div>
                                </div>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </section>
            <div class="sticky-footer-push"></div>
        </div>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>
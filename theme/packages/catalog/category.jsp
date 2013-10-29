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
    Category currentCategory = catalog.getCategoryByName(request.getParameter("category"));
    // Get map of description templates
    Map<String, String> templateDescriptions = new java.util.HashMap<String, String>();
    if (currentCategory != null) {
        templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>
            <% if(currentCategory != null) {%>
                |&nbsp;<%= currentCategory.getName()%>
            <% }%>
        </title>
        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>
        <!-- Package Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/category.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/category.js"></script>
    </head>
    <body>
        <%@include file="../../common/interface/fragments/header.jspf"%>
        <% if(currentCategory != null) {%>
            <header class="container">
                <% if(currentCategory.getImageTag().length() > 0) {%>
                    <div class="category-image">
                        <%= currentCategory.getImageTag()%>
                    </div>
                    <div class="wrap-float">
                <% } else { %>
                    <div class="wrap">
                <% }%>
                    <h2>
                        <%= currentCategory.getName()%>
                    </h2>
                    <div class="description">
                        <%= currentCategory.getDescription()%>
                    </div>
                </div>
                <div class="clearfix"></div>
                <hr class="soften">
            </header>
        <% }%>
        <section class="container">
            <% if(currentCategory != null) {%>
                <ul class="templates unstyled">
                    <% for (Template template : currentCategory.getTemplates()) {%>
                        <li class="border-top clearfix">
                            <div class="content-wrap">
                                    <% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
                                        <div class="image">
                                            <img width="120px" src="<%= bundle.getProperty("serviceItemImagePath") + template.getTemplateAttributeValue("ServiceItemImage")%>" />
                                        </div>
                                        <div class="description">
                                    <% } else {%>
                                        <div class="description-wide">
                                    <% }%>
                                    <h3>
                                        <%= template.getName()%>
                                    </h3>
                                    <p>
                                        <%= template.getDescription()%>
                                    </p>
                                    <% if (templateDescriptions.get(template.getId()) != null ) { %>
                                        <a class="" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(template.getId()) %>&category=<%= URLEncoder.encode(currentCategory.getFullName(), "UTF-8")%>">
                                            Read More
                                        </a>
                                    <% }%>                                           
                                </div>
                                <div class="description-attributes">
                                    <!-- Load description attributes config stored in package config -->
                                    <% for (String attributeDescriptionName : attributeDescriptionNames) {%>
                                        <% if (template.hasTemplateAttribute(attributeDescriptionName)) { %>
                                            <p>
                                                <strong><%= attributeDescriptionName%>:</strong> <%= template.getTemplateAttributeValue(attributeDescriptionName) %>
                                            </p>
                                        <% }%>
                                    <%}%>
                                    <a class="templateButton" href="<%= template.getAnonymousUrl() %>&category=<%= URLEncoder.encode(currentCategory.getFullName(), "UTF-8")%>">
                                        <i class="fa fa-share"></i>Request this Service
                                    </a>
                                </div>
                            </div>
                        </li>
                    <%}%>
                </ul>
            <% }%>
        </section>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>
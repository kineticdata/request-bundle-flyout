<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

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
        <%-- 
            Specify that modern IE versions should render the page with their own 
            rendering engine (as opposed to falling back to compatibility mode.
            NOTE: THIS HAS TO BE RIGHT AFTER <head>!
        --%>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta charset="utf-8">
        <title>
            <%= bundle.getProperty("companyName")%>
            |
            <% if(currentCategory != null) {%>
                <%= currentCategory.getName()%> |
            <% }%>
            <%= customerRequest.getTemplateName()%>
        </title>
        <%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>

        <%-- Include the bundle common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <!-- Common Javascript -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/Bridges.js"></script>
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/Paginator.js"></script>
        <!-- Package Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/displayPackage.css" type="text/css" />
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/display.css" type="text/css" />
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="themes/state/packages/base/resources/css/formLayout.css" type="text/css" />
        <!-- Package Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/package.js"></script>
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/display.js"></script>
        <%-- Include the form head content, including attached css/javascript files and custom header content --%>
        <%@include file="../../core/interface/fragments/formHeadContent.jspf"%>
    </head>
    <body>
        <%@include file="../../common/interface/fragments/header.jspf"%>
        <header class="container">
            <h2>
                <% if(currentCategory != null) {%>
                    <%= currentCategory.getName()%>:
                <% }%> Request <%= customerRequest.getTemplateName()%>
            </h2>
            <hr class="soften">
        </header>
        <section class="container">
            <%@include file="../../core/interface/fragments/displayBodyContent.jspf"%>
        </section>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
        <!-- Start Temp Requester Information -->
        <div id="temp-requester-info">
            <div class="request-for">
                <h4>
                    This request is for:
                </h4>
                <div class="contact border-left">
                    <span id="request-for-name"></span>&nbsp;<a href="JavaScript:void(0);" data-id="0" class="edit-contact">Change</a>
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
                    <span id="approver-name"></span>&nbsp;<a href="JavaScript:void(0);" data-id="1" class="edit-contact">Add</a>
                    <div id="approver-email"></div>
                    <div id="approver-phone"></div>
                    <div id="approver-site"></div>
                </div>
            </div>
        </div>
        <!-- End Temp Requester Information -->
        <!-- Start Custom Form Edit Contact Information -->
        <div id="contactSetup" class="hidden clearfix">
            <div id="tabs">
                <ul>
                    <li>
                        <a href="#request-for-tab">
                            Requested For
                        </a>
                    </li>
                    <li>
                        <a href="#approver-tab">
                            Approver
                        </a>
                    </li>
                </ul>
                <div id="lookup" class="clearfix">
                    <form id="lookupForm">
                        <a class="advanced-search-link" href="JavaScript:void(0);">(+) Advanced Search</a>
                        <p>
                            <label class="infield" for="email">
                                Type an email address to begin
                            </label>
                            <input type="text" name="email" id="email" class="input-block-level" autocomplete="off" value="" />
                        </p>
                        <div class="advanced-search hidden">
                            <p>
                                <label class="infield" for="first-name">
                                    First Name
                                </label>
                                <input type="text" name="firstName" id="first-name" class="input-block-level" autocomplete="off" value="" />
                            </p>
                            <p>
                                <label class="infield" for="last-name">
                                    Last Name
                                </label>
                                <input type="text" name="lastName" id="last-name" class="input-block-level" autocomplete="off" value="" />
                            </p>
                            <input type="submit" value="Search" class="templateButton" />
                            <%-- LOADER --%>
                            <div id="loader" class="hidden">
                                <img alt="Please Wait." src="<%=bundle.bundlePath()%>common/resources/images/spinner.gif" />
                                <br />
                                Loading Results
                            </div>
                            <table id="advanced-search-results" class="hidden">
                            </table>
                            <nav id="pagination" class="hidden">    
                            </nav>
                        </div>
                    </form>
                    <div id="autocomplete-selected" class="hidden">            
                        <div class="user-information border-top border-bottom">
                        </div>
                        <div class="confirmation">
                            Would you like to set this contact?
                            <br />
                            <div class="answer">
                                <a class="save templateButton" href="JavaScript:void(0);">Yes</a>
                                <a class="cancel templateButton" href="JavaScript:void(0);">No</a>
                            </div>
                        </div>
                   </div>
                   <div id="advanced-search-selected" class="hidden">            
                        <div class="user-information border-top border-bottom">
                        </div>
                        <div class="confirmation">
                            Would you like to set this contact?
                            <br />
                            <div class="answer">
                                <a class="save templateButton" href="JavaScript:void(0);">Yes</a>
                                <a class="cancel templateButton" href="JavaScript:void(0);">No</a>
                            </div>
                        </div>
                   </div>
                </div>
                <div id="request-for-tab" class="hidden">            
                </div>
                <div id="approver-tab" class="hidden">
                </div>
                <div id="response-message"></div>
                <div class="clearfix"></div>
                <a id="close" class="templateButton" href="JavaScript:void(0);">
                    Close
                </a>
            </div>
        </div>
        <!-- End Custom Form Edit Contact Information -->
    </body>
</html>

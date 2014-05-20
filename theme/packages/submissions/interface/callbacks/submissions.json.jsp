<%@page contentType="application/json; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        // Retrieve the main catalog object
        Catalog catalog = Catalog.findByName(context, bundle.getProperty("catalogName"));
        if(catalog == null) {
            throw new Exception("The catalog specified in your configuration is incorrect.");
        }
        // Preload the catalog
        catalog.preload(context);
        // Get qualification mapping from config
        String qualification = submissionGroups.get(request.getParameter("qualification"));
        if (qualification == null) {
            throw new Exception("The specified submission qualification ("+
                request.getParameter("qualification")+") does not match any pre-defined "+
                "submission qualifications.");
        }
        // Set size and offset
        int pageSize = 1000;
        int pageOffset = 0;
        try {
            // Try to retrieve the pageSize and convert to ints
            pageSize = Integer.parseInt(request.getParameter("limit"));
        } catch(NumberFormatException e) {
            throw new Exception("Unable to parse limit as integer.");
        }
        try {
            // Try to retrieve offset and convert to ints
            pageOffset = Integer.parseInt(request.getParameter("offset"));
        } catch(NumberFormatException e) {
            throw new Exception("Unable to parse offset as integer.");
        }
        // Set order field.  Currently only sorting for one field
        String sortOrderField = SubmissionConsole.getSortFieldId(request.getParameter("orderField"));
        String[] sortFieldIds = new String[]{sortOrderField};
        // Retrieve the sortOrder parameter to determine integer value of sort order
        // 1 is ascending order and 2 is descending order
        int sortOrder = request.getParameter("order").equals("DESC") ? 2 : 1;
        // Retrieve the entries with the parameters gathered above
        SubmissionConsole[] submissions = SubmissionConsole.find(context, catalog, qualification, sortFieldIds, pageSize, pageOffset, sortOrder);
        // Retrieve count of the total number of entries that match the qualification.
        int count = ArsBase.count(context, SubmissionConsole.FORM_NAME, qualification);
        // Build result map
        Map<String,Object> results = new LinkedHashMap<String,Object>();
        results.put("count", count);
        results.put("limit", pageSize);
        results.put("offset", pageOffset);
        // Build submission array
        List<SubmissionConsole> submissionData = new LinkedList<SubmissionConsole>();
        for (int i = 0; i < submissions.length; i++) {
            submissionData.add(submissions[i]);
        }
        // Add submission array to data
        results.put("data", submissionData);
        // Output json string
        out.print(JSONValue.toJSONString(results));
    }
%>

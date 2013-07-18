/**
 * ArsUrl
 */
function ArsUrl() {
    // Strict
    'use strict';
    
    /**
     * @var string private
     */
    var form = new String();
    
     /**
     * @var string private
     */
    var fields = {};
    
    /**
     * @var string private
     */
    var fieldIds = {};
    
    /**
     * @var string private
     */
    var qualification = new String();
    
    /**
     * @var string private
     */
    var url = new String();
    
    /**
     * @param formTemplate
     * @return Table
     */
    this.setForm = function(formTemplate) {
        form = formTemplate;
        return this;
    }
    
    /**
     * @param formFields
     * @return Table
     */
    this.setFields = function(formFields) {
        fields = formFields;
        return this;
    }
    
    /**
     * @return Table
     */
    this.setFieldIds = function() {
        fieldIds = '';
        var index = 0;
        for(var field in fields) {
            if(fields.hasOwnProperty(field)) {
                if (index > 0) {
                    fieldIds += ',';
                }
                fieldIds += fields[field];
                index++;
            }
        }  
        return this;
    }
    
    /**
     * @param tableQualification
     * @return Table
     */
    this.setQualification = function(tableQualification) {
        qualification = tableQualification;
        return this;
    }
    
    /**
     * @param webServiceUrl
     * @return Table
     */
    this.setUrl = function(webServiceUrl) {
        // Build a timestamp that will be used as an argument for the noCache paramter
        var date = new Date();
        var timestamp = date.getTime();
        url = webServiceUrl +
        '?form=' + form +
        '&qualification=' + qualification +
        '&fieldIds=' + fieldIds +
        '&noCache=' + timestamp;
        return this;
    }
    
    /**
     * @return url complete for arsys
     */
    this.getUrl = function() {
        return url;
    }
}
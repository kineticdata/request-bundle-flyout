/**
 * Paginator Class
 */
function Paginator() {
    'use strict';

    /**
     * @var int
     */
    var page;

    /**
     * @var int
     */
    var total;

    /**
     * @var int
     */
    var range;

    /**
     * @var int
     */
    var resultsPerPage;

    /**
     * @var object
     */
    var errors = new Object();

    this.setPage = function(pageNumber) {
        page = pageNumber;
        return this;
    }

    this.setResultsPerPage = function(results_per_page) {
        resultsPerPage = results_per_page;
        return this;
    }

    this.getPage = function() {
        return page;
    }

    this.getResultsPerPage = function() {
        return resultsPerPage;
    }

    this.getIndex = function() {
        return (page - 1) * resultsPerPage;
    }

    this.setTotal = function(totalResultSet) {
        total = totalResultSet;
        return this;
    }

    this.getTotal = function() {
        return total;
    }

    /**
     * Getter: errors
     * @return object
     */
    this.getErrors = function() {
        return errors;
    }

    this.setRange = function(pageRange) {
        range = pageRange;
        return this;
    }

    this.getRange = function() {
        return range;
    }

    this.getTotalPages = function() {
        return Math.ceil(total / resultsPerPage);
    }

    this.validateCurrentPage = function() {
        if(this.getTotalPages() < page) {
            errors['page'] = 'Current Page Does Not Exist';
        }
        return this;
    }

    /**
     * @return boolean
     */
    this.isValid = function() {
        var size = 0;
        for (var key in errors) {
            if (errors.hasOwnProperty(key)) size++;
        }
        if(size > 0) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @param baseUrl string
     * @param queryString string
     * @return pages object
     */
    this.buildPaginatationLinks = function(baseUrl, queryString) {
        if(typeof queryString['page'] != 'undefined') {
            delete queryString['page'];
        }

        var startPage;
        var endPage;
        // Initialize object
        var pages = new Object();
        var pageNumbers = new Array();
        if(total > 1) {
            startPage = 1;
            endPage = this.getTotalPages();
            // Setup prev
            if(page != 1) {
                pages['prev'] = new Object({
                    'link':baseUrl + '?page=' + (page - 1) + queryString,
                    'label':'Prev'
                });
            }
            // Setup link showing first page number if user is not on page 1 and on page 6 or greater
            if(page != 1 && page >= 4) {
                pages['fistPage'] = new Object({
                    'link':baseUrl + '?page=' + (startPage) + queryString,
                    'label':startPage+'...'
                });
            }
            // Create page numbers
            for(var i = (page - range); i < ((page + range) + 1); i++) {
                if ((i > 0) && (i <= endPage)) {
                    pageNumbers[i] = new Object({
                        'link':baseUrl + '?page=' + i + queryString,
                        'label':i
                    });
                }
            }
            if(pageNumbers.length > 2) {
                pages['pageNumbers'] = pageNumbers;
            }
            
            // Setup link showing last page number if user is not on end page and 5 pages or less from end page
            if(page != endPage && page <= (endPage - 3)) {
                pages['lastPage'] = new Object({
                    'link':baseUrl + '?page=' + (endPage) + queryString,
                    'label':'... ' + endPage
                });
            }
            // Setup next
            if(page != endPage) {
                pages['next'] = new Object({
                    'link':baseUrl + '?page=' + (page + 1) + queryString,
                    'label':'Next'
                });
            }
        } else {
            pages = new Array();
        }
        return new Object({'pages':pages});
    }

    /**
     * @return pages object
     */
    this.buildPaginatationData = function() {
        var startPage;
        var endPage;
        // Initialize object
        var pages = new Object();
        var pageNumbers = new Array();
        if(total > 1) {
            startPage = 1;
            endPage = this.getTotalPages();
            // Setup prev
            if(page != 1) {
                pages['prev'] = new Object({
                    'page':(page - 1),
                    'label':'Prev'
                });
            }
            // Setup link showing first page number if user is not on page 1 and on page 6 or greater
            if(page != 1 && page >= 7) {
                pages['fistPage'] = new Object({
                    'page':startPage,
                    'label':startPage + '...'
                });
            }
            // Create page numbers
            for(var i = (page - range); i < ((page + range) + 1); i++) {
                if ((i > 0) && (i <= endPage)) {
                    pageNumbers[i] = new Object({
                        'page':i,
                        'label':i
                    });
                }
            }
            if(pageNumbers.length > 2) {
                pages['pageNumbers'] = pageNumbers;
            }
            
            // Setup link showing last page number if user is not on end page and 5 pages or less from end page
            if(page != endPage && page <= (endPage - 6)) {
                pages['lastPage'] = new Object({
                    'page':endPage,
                    'label':'... ' + endPage
                });
            }
            // Setup next
            if(page != endPage) {
                pages['next'] = new Object({
                    'page':page + 1,
                    'label':'Next'
                });
            }
        } else {
            pages = new Array();
        }
        return new Object({'pages':pages});
    }
}
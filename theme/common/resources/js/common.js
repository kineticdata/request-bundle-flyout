$(document).ready(function() {
    // Set some states
    $('form#catalog-search p label.infield').inFieldLabels();
    /*
    $('form#catalog-search').on('focus', 'input[type="search"]', function(event) {
        event.preventDefault();
        $(this).animate({width:'+=100px'}, 'linear');
        $(this).css('background-color', 'white');
    });
    var submitFlag = false;
    $('form#catalog-search').on('focusout', 'input[type="search"]', function(event) {
        event.preventDefault();
        var jQueryObject = this;
        if(!submitFlag) {
            setTimeout(function(){
                $(jQueryObject).animate({width:'-=124px'}, 'linear');
                $(jQueryObject).css('background-color', 'rgb(228, 228, 228)');
            }, 200);
        } else {
            submitFlag = false;
        }
    });
    $('form#catalog-search').on('click', 'button[type="submit"]', function(event) {
        submitFlag = true;
    });
    */
});
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
// From: http://msdn.microsoft.com/en-us/library/ms537509(v=vs.85).aspx
function getInternetExplorerVersion() {
    var rv = -1; // Return value assumes failure.
    if (navigator.appName == 'Microsoft Internet Explorer') {
        var ua = navigator.userAgent;
        var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
        if (re.exec(ua) != null) {
            rv = parseFloat( RegExp.$1 );
        }
    }
    return rv;
}

// This jQuery method can be used to check the existance of dom elements
jQuery.fn.exists = function() {
    return this.length > 0;
}

/**
 * @return object url parameters
 */
function getUrlParameters() {
  var searchString = window.location.search.substring(1)
    , params = searchString.split("&")
    , hash = {}
    ;

  for (var i = 0; i < params.length; i++) {
    var val = params[i].split("=");
    hash[unescape(val[0])] = unescape(val[1]);
  }
  return hash;
}

/**
 * Live jQuery hover function used to display specific behavior when a user hovers over dhildren selector.
 * The parent slector of the children are quired for the even to be live.
 * @param parentSelector string
 * @param childSelector string
 * @param mouseEnter function
 * @param mouseLeave function
 */
function hover(parentSelector, childSelector, mouseEnter, mouseLeave) {
    $(parentSelector).on({
        mouseenter: function() {
            if(mouseEnter != null) {
                mouseEnter(this);
            }
        },
        mouseleave: function() {
            if(mouseLeave != null) {
                mouseLeave(this);
            }
        }
    }, childSelector);
}

/**
 * @param obj object
 * IE ONLY - used with the styles "preRequiredLabel
 * Example: *.preRequiredLabel { zoom: expression(setIE7PreRequired(this)); }
 */
setIE7PreRequired = function(obj) {
    if($(obj).hasClass('preRequiredLabel')) {
        if(obj.innerHTML.indexOf("*")==-1) {
            $(obj).append("*");
        }
    }
}

/**
 * Ajax Class
 */
function Ajax() {
   'use strict';

    /**
     * @var string private
     */
    var ajaxSelector = new String();

    /**
     * @var object private
     */
    var options = {};

    /**
     * @param selector
     * @return Ajax
     */
    this.setAjaxSelector = function(selector) {
        ajaxSelector = selector;
        return this;
    }

    /**
     * @param object
     * @return Ajax
     */
    this.setOptions = function(ajaxOptions) {
        options = ajaxOptions;
        return this;
    }

    /**
     * @return Ajax
     */
    this.makeRequest = function() {
        if(ajaxSelector == null) {
             $(selector).ajax(options);
         } else {
            $.ajax(options);
         }      
        return this;
    }
}

/**
 * Message class
 */
function Message() {
    'use strict';

    /**
     * @var string private
     */
    var message = new String();

    /**
     * @param msg
     * @return Message
     */
    this.setMessage = function(msg) {
        message = msg;
        return this;
    }

    /**
     * @return error message
     */
    this.getErrorMessage = function() {
        return '<div class="message alert alert-error"><a class="close" data-dismiss="alert">x</a>'+message+'</div>';
    }

    /**
     * @return success message
     */
    this.getSuccessMessage = function() {
        return '<div class="message alert alert-success"><a class="close" data-dismiss="alert">x</a>'+message+'</div>';
    }

    /**
     * @return info message
     */
    this.getWarningMessage = function() {
        return '<div class="message alert alert-info"><a class="close" data-dismiss="alert">x</a>'+message+'</div>';
    }
}

/**
 * DialogInitializer Class
 */
function DialogInitializer() {
    'use strict';

    /**
     * @var string private
     */
    var dialogSelector = new String();

    /**
     * @var object private
     */
    var options = {
        position:['middle', 240],
        resizable: false,
        draggable: false,
        modal: true,
        closeOnEscape: true,
        show: 'fade',
        hide: 'fade',
        minHeight: 0,
        zIndex: 10000
    }

    /**
     * @param element
     * @return DialogInitializer
     */
    this.setDialogSelector = function(element) {
        dialogSelector = element;
        return this;
    }

    /**
     * @param dialogOptions
     * @return DialogInitializer
     */
    this.setOptions = function(dialogOptions) {
        $.extend(options, dialogOptions);
        return this;
    }

    /**
     * @return DialogInitializer
     */
    this.closeDialog = function() {
        $(dialogSelector).dialog('close');
        return this;
    }

    /**
     * @return DialogInitializer
     */
    this.startDialog = function() {
        $(dialogSelector).dialog(options);
        return this;
    }
}

/**
 * TabsInitializer Class
 */
function TabsInitializer() {
    'use strict';

    /**
     * @var string private
     */
    var tabsSelector = new String();

    /**
     * @var object private
     */
    var options = {}

    /**
     * @param element
     * @return TabsInitializer
     */
    this.setTabsSelector = function(element) {
        tabsSelector = element;
        return this;
    }

    /**
     * @param tabOptions
     * @return TabsInitializer
     */
    this.setOptions = function(tabOptions) {
        $.extend(options, tabOptions);
        return this;
    }

    /**
     * @return TabsInitializer
     */
    this.startTabs = function() {
        $(tabsSelector).tabs(options);
        return this;
    }
}
$(document).ready(function() {
    if($('[label="Description Right"]').exists()) {
        $('[label="Description Right"]').append($('a.create-request').show('fade', 1000));
    } else {
        $('a.create-request').show('fade', 1000);
    }
});

// This jQuery method can be used to check the existance of dom elements
jQuery.fn.exists = function() {
    return this.length > 0;
}
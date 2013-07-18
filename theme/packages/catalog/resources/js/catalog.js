$(document).ready(function() {
    $('nav ul.nav li.root a.popular-requests').addClass('nav-hover');
    /* This code will display the root cats of the flyout on page load.  It has be disabled for now.
    // Show flyout table with root cats
    $('table.flyout-table').fadeIn();
    $('nav ul.nav li.dropdown').addClass('nav-hover');
    $('nav ul.nav li.dropdown').find('i.nav-sprite').css({'background-position':'-127px -22px'});
    var firstHover = true;
    $('ul.dropdown-menu').on({
        mouseenter: function() {
            if (firstHover) {
                firstHover = false;            
                $('.flyout').animate({ width: '740px' });
                $('.subcats-wrap').show();
                $('.subcats').empty().html($(this).find('ul.subcategories').html()).show();
                $('.flyout-table').removeClass('exposed-skin');
            } else {
                $('.flyout').width('740px');
                $('.subcats-wrap').show();
                $('.subcats').empty().html($(this).find('ul.subcategories').html()).show();
                $('.flyout-table').removeClass('exposed-skin');
            }
        }
    }, 'li.category');

    $('table.flyout-table').on({
        mouseleave: function() {
            firstHover = true; 
            $('.flyout').animate({ width: '250px' });
            $('.subcats-wrap').hide();
            $('.flyout-table').addClass('exposed-skin');
        }
    }); */
});
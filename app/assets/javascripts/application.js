//= require ./lib/jquery
//= require_tree ./lib
//= require menu
$(document).ready(function() {
    $('.body').fullpage({
        css3: false,
        scrollingSpeed: 700,
        easing: 'easeInQuart'
    });
});

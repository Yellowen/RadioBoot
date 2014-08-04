//= require ./lib/jquery
//= require_tree ./lib
//= require_tree ./semantic
//= require_self
//= require admin

function show_error(id) {
    $("#subscribe").find('span').transition('remove looping');
    $(id).fadeIn().delay(4000).fadeOut();
}


function show_msg(id) {
    $("#subscribe").find('span').transition('remove looping');
    $("#subscribe").hide();
    $("#email").hide();
    $(id).fadeIn();
}

$(function(){
    $(".ui.message").on('click', function(event){
        $(this).fadeOut();
    });

    $("#subscribe").on('click', function(event){
        var email = $('#email').val();
        $(this).find('span')
            .transition('set looping')
            .transition('pulse');
        $('#email').addClass('disabled');
        var that = this;
        $.ajax({url: '/subscribe',
                type: 'POST',
                data: {email: email}})
            .done(function(data){
                $('#email').removeClass('disabled');
                if(data.status == '0') {
                    show_msg("#suc");
                }
                else if (data.status == '1') {
                    show_error("#already");
                }
                else if (data.status == '2') {
                    show_error("#not_valid");
                }
                else {
                    show_error("#failed");
                }

            })
            .fail(function(data){
                $(that).removeClass('loading');
                $('#email').removeClass('disabled');

            });


    });

    var details = JSON.parse($("#tmp").html());
    $('video,audio').mediaelementplayer({
        success: function (mediaElement, domObject) {

            // add event listener
            mediaElement.addEventListener('timeupdate', function(e) {
                console.log(mediaElement.currentTime);
                console.log(typeof(mediaElement.currentTime));
            }, false);
        },
    });

    $(".ui.dropdown").dropdown();
    //$(".ui.computer.sidebar").sidebar('attach events', '.toggle.button.computer');
    $(".ui.sidebar").sidebar({overlay: true}).sidebar('attach events', '.toggle.button');
    $("#upload_file").on('click', function(event){
        $("#actual_field").click();
    });

});

$(function(){
    var details = JSON.parse($("#tmp").html());
    var lang = $("html").attr('lang');

    if ((details !== undefined) || (details != "")) {

        var topics = details.topics.reverse();
        $.each(topics, function(x){
            var obj = details.topics[x];
            $("#episode_menu").prepend("<a class='item' id='topic_" + obj.id + "' data-id='" + obj.id + "'>" + obj[lang] + "</a>");

        });


    }
});

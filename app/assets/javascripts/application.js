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

    var json_data = $("#tmp").html().trim(),
        details, lang, time_cache, timed_content;

    console.log(json_data.trim().length);
    if (json_data !== "") {
        details = JSON.parse(json_data);
        lang = $("html").attr('lang');
        time_cache = [];
        timed_content = {};

        if ((details !== undefined) || (details != "")) {

            var topics = details.topics.reverse();
            $.each(topics, function(x){
                var obj = details.topics[x];
                $("#episode_menu").prepend("<a class='item' id='topic_" + obj.id + "' data-id='" + obj.id + "'>" + obj[lang] + "</a>");
                time_cache.push(parseInt(obj.time));
                console.log(details.sections[obj.id.toString()].desc[lang]);
                timed_content["id_" + parseInt(obj.time).toString()] = [obj.id, details.sections[obj.id.toString()].desc[lang]];
            });
        }
    }
    $('video,audio').mediaelementplayer({
        success: function (mediaElement, domObject) {

            // add event listener
            mediaElement.addEventListener('timeupdate', function(e) {
                var ctime = parseInt(mediaElement.currentTime);
                if (ctime in time_cache) {
                    console.log('matched');
                    console.log(timed_content);
                    var c = timed_content["id_"+ ctime.toString()];
                    console.log(c);
                    console.log(timed_content.keys());
                    $("#desc").html(cache[1]);
                    $("#episode_menu .item").removeClass('active');
                    $("#topic_" + cache[0]).addClass('active');
                }
            }, false);
        },
    });


    $(".ui.dropdown").dropdown();
    //$(".ui.computer.sidebar").sidebar('attach events', '.toggle.button.computer');
    $(".ui.sidebar").sidebar({overlay: true}).sidebar('attach events', '.toggle.button');
    $("#upload_file").on('click', function(event){
        $("#actual_field").click();
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

});

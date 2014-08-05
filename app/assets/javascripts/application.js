//= require ./lib/jquery
//= require_tree ./lib
//= require_tree ./semantic
//= require_self
//= require admin
var author = {en: "Voices", fa: "صداها"};

var auto_rotate = true;
var last_time = 0;

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

function show_content_for(id) {
    if (auto_rotate === true) {
        $('.descriptions').hide();
        $("#desc_" + id).fadeIn();
        $("#episode_menu .item").removeClass('active');
        $("#topic_" + id).addClass('active');
    }
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
                var desc =  details.sections[obj.id.toString()].desc[lang];
                $("#episode_menu").prepend("<a class='topic item' id='topic_" + obj.id + "' data-id='" + obj.id + "'>" + obj[lang] + "</a>");
                time_cache.push(parseInt(obj.time));
                console.log(details.sections[obj.id.toString()].desc[lang]);
                timed_content["id_" + parseInt(obj.time).toString()] = obj.id;
                $("#desc").append('<div class="descriptions" style="display:none;" id="desc_' + obj.id + '">' + desc + '</div>');
            });
        }
        $("#episode_menu").prepend("<a class='topic active item' id='topic_author' data-id='author'>" + author[lang] + "</a>");

        var authors = "<div class='ui very relaxed huge divided list'>";
        _.forEach(details.authors, function(x){
            authors += "<div class='item'><img class='ui avatar image' src='" + x.avatar_link + "'><div class='content'><div class='header'>" + x.name + "</div>";
            _.each(_.keys(x.links), function(key){
                authors += "<a href='" + x.links[key] + "'>" + key + "</a> ";
            });
            authors += "</div></div>";
        });
        authors += "</div>";
        $("#desc").prepend('<div dir="ltr" style="direction: ltr; text-align: left;" class="descriptions" id="desc_author">' + authors + '</div>');
    }


    $('video,audio').mediaelementplayer({
        success: function (mediaElement, domObject) {

            // add event listener
            mediaElement.addEventListener('timeupdate', function(e) {
                var ctime = parseInt(mediaElement.currentTime);
                console.log(ctime);
                console.log(time_cache);
                if (_.indexOf(time_cache, ctime) != -1) {
                    if (last_time != ctime) {
                        console.log('matched');
                        console.log(timed_content);
                        var topic_id = timed_content["id_"+ ctime.toString()];
                        show_content_for(topic_id);
                    }

                }
                last_time = ctime;
            }, false);
        },
    });


    $(".ui.dropdown").dropdown();
    //$(".ui.computer.sidebar").sidebar('attach events', '.toggle.button.computer');
    $(".ui.sidebar").sidebar({overlay: true}).sidebar('attach events', '.toggle.button');
    $("#upload_file").on('click', function(event){
        $("#actual_field").click();
    });

    $('.topic').on('click', function(){
        auto_rotate = true;
        show_content_for($(this).data('id'));
        $("#auto_rotate").fadeIn();
        auto_rotate = false;
    });

    $("#auto_rotate").on('click', function(){
        auto_rotate = true;
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

});

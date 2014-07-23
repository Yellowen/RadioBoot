//= require ./lib/jquery
//= require_tree ./lib
//= require_tree ./semantic
//= require_self

$(function(){
    $("#subscribe").on('click', function(event){
        var email = $('#email').val();
        $(this).addClass('loading');
        $('#email').addClass('disabled');
        var that = this;
        $.ajax({url: '/subscribe',
                type: 'POST',
                data: {email: email}})
            .done(function(data){
                $(that).removeClass('loading');
                $('#email').removeClass('disabled');
                if(data.status == 200) {
                    $(that).hide();
                    $("#email").hide();
                    $(".message").removeClass('hidden');
                }

            })
            .fail(function(data){
                console.log(data);
                console.log('fail');
                $(that).removeClass('loading');
                $('#email').removeClass('disabled');

            });


    });
});

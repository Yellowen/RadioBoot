$(function(){
    $(".removebtn").on('click', function(event){
        event.preventDefault();
        var url = $(this).data('url');
        if (confirm('Are you sure about this?')) {
            window.location.href = url;
        }
    });
});

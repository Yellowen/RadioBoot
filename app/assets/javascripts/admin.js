function admin_show_msg(msg, klass){
    $("#msg .header").html(msg);
    $("#msg").addClass(klass).fadeIn().delay(4000).fadeOut().removeClass(klass);

}

function admin_show_suc(){
    admin_show_msg($("#suc").html(), "success");
}
function admin_show_err(){
    admin_show_msg($("#error").html(), "error");
}
function admin_show_format_err(data){
    admin_show_msg(data, "error");
}

$(function(){
    $(".removebtn").on('click', function(event){
        event.preventDefault();
        var url = $(this).data('url');
        if (confirm('Are you sure about this?')) {
            window.location.href = url;
        }
    });


    $(".upbutton").on('click', function(ev){
        var id = $(this).data('id');
        $("#drop_zone").attr('data-id', id);
        $("#upload_area").fadeIn();
    });

    $("#close_upload").on('click', function(ev){
        $("#upload_area").fadeOut();
    });

    function handleFileSelect(evt) {
        evt.stopPropagation();
        evt.preventDefault();

        var text = $("#drop_zone").html();
        $("#drop_zone").html("<i class='loading icon'></i>");

        var files = evt.dataTransfer.files; // FileList object.

        // files is a FileList of File objects. List some properties.
        var output = '';
        for (var i = 0, f; f = files[i]; i++) {
            var reader = new FileReader();

            console.log(f.type);
            console.log(f.type.match("json*"));
            if (!f.type.match("json*")) {
                alert("File format should be json.");
                continue;
            }
            reader.onloadend = (function(theFile) {
                output = reader.result;
                $.ajax({
                    url: '/admin/upload',
                    type: 'POST',
                    data: {json: output, id: $("#drop_zone").data('id')}
                })
                    .done(function(data){
                        data = JSON.parse(data);
                        if (data.status == "0") {
                            admin_show_suc();
                            window.location.href = "/admin/";
                        }
                        else {
                            admin_show_format_err(data.msg);
                        }
                    })
                    .fail(function(data){
                        admin_show_err();
                    })

            });
            reader.readAsText(f);
        }

    }

    function handleDragOver(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
    }

    // Setup the dnd listeners.
    var dropZone = document.getElementById("drop_zone");
    dropZone.addEventListener('dragover', handleDragOver, false);
    dropZone.addEventListener('drop', handleFileSelect, false);
});

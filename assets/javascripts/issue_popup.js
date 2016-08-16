$(function() {
    //----- OPEN
    $('[data-popup-open]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-open');
        $('[data-popup="' + targeted_popup_class + '"]').fadeIn(350);
        e.preventDefault();
    });
    //----- CLOSE
    $('[data-popup-close]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-close');
        $('[data-popup="' + targeted_popup_class + '"]').fadeOut(350);
        e.preventDefault();
    });
    $('#client_id').click(function(){
        if ($(this).val() != '') {
            var client_id = $(this).val();
            var data = 'client_id='+client_id
            $.ajax({
                url: '/get-client-projects',
                type: 'get',
                data: data
            })
        }
    });

    $('.go-to-issue').on('click', function(event) {
        event.preventDefault();
        if ($('#client_project option:selected').val() == ''){
            alert('please select project');
        }else{
            var identifier = $('#client_project option:selected').val();
            location.replace('/projects/'+identifier+'/issues');
        }
    });
});
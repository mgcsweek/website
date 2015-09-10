if(!(/Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i).test(navigator.userAgent || navigator.vendor || window.opera)){
    skrollr.init({
        forceHeight: false
    });
}

$(document).ready(function() {
    if ($(document.body).attr('id') == 'apply') {
        $('aform#application-form').submit(function(evt) {
            var data = $(this).serialize();

            $.ajax({
                type: 'POST',
                url: $(this).attr('action'),
                data: data,
                encode: true,
                dataType: 'json',
                accepts: {
                    json: 'application/json'
                }
            }).done(function(resp) {
                $('.status').hide(700, function() {
                                $(this).removeClass('error')
                                       .html(resp.response)
                                       .show(700);
                            });

                $('#applicant-submit-button').hide(700);
            }).fail(function(obj) {
                resp = obj.responseJSON;
                if (typeof resp == 'undefined') {
                    resp = {
                        response: '<p>Неочекивана грешка. Молимо вас контактирајте нас на kontakt@csnedelja.mg.edu.rs</p>',
                    };
                }
                if (typeof resp.errors == 'undefined' || typeof resp.errors[0] == 'undefined')
                    resp.errors = [];

                $('.status').hide(700, function() {
                                $(this).addClass('error')
                                       .html(resp.response + '<ul>' + resp.errors.reduce(function(prev, c) {
                                            return prev + '<li>' + c + '</li>';
                                        }, ''))
                                        .show(700)
                            });

            });

            evt.preventDefault();
        });
    }
});

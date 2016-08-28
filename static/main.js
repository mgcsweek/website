if(!(/Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i).test(navigator.userAgent || navigator.vendor || window.opera)){
    skrollr.init({
        forceHeight: false
    });
}

$(document).ready(function() {
    if ($(document.body).attr('id') == 'apply') {
        $('form#application-form').submit(function(evt) {
            var data = $(this).serialize();
            $('.spinner').show(100);

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
                $('.spinner').hide(100);
                $('.status').hide(700, function() {
                                $(this).removeClass('error')
                                       .html(resp.response)
                                       .show(700);
                            });

                $('#applicant-submit-button').hide(700);
            }).fail(function(obj) {
                $('.spinner').hide(100);
                resp = obj.responseJSON;
                if (typeof resp == 'undefined' && obj.status == 419) {
                    resp = {
                        response: '<p>Фајлови су превелики. Максимална величина једног фајла је 15MiB.</p>'
                    }
                }
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

        function updateFilename(elem) {
            $(elem).parent().parent().children('.filename').html($(elem).val());
        }

        $('a.upload input').change(function() {
            updateFilename(this);
        });

        $('a.upload input').each(function() {
            updateFilename($(this));
        });
    }

    $('#hamburger-icon').click(function() {
        if ($('header nav ul.active').length > 0) {
            $('header nav ul').removeClass('active')
                              .slideUp();
        } else {
            $('header nav ul').addClass('active')
                              .slideDown();
        }

    })
});

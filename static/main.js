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
                $('.g-recaptcha').hide(700);
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
                if (window['grecaptcha']) {
                    grecaptcha.reset();
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

    var resourceFilterState = 'all';
    var allTags = undefined;

    function loadAllTags() {
        if (allTags === undefined) {
            allTags = new Set();
            allTags.add('none');
            $('.resource-filter-tag').each(function() {
                allTags.add($(this).data('tag'))
            });
        }
    }

    function manipulateFilter(tag, toggle, elem) {
        if (resourceFilterState == 'all') {
            $('.resource-filter-tag').removeClass('active');
        }
        resourceFilterState = 'some';

        if (!elem) {
            elem = $(`.resource-filter-tag[data-tag="${tag}"]`);
        } else {
            elem = $(elem);
        }

        if (toggle) {
            elem.toggleClass('active');
        } else {
            elem.addClass('active');
        }

        applyResourceFilters();
    }

    function applyResourceFilters() {
        if (resourceFilterState == 'all') {
            $('.resources li, .resources h2, .resources h1').show();
            return;
        } else {
            $('.resources h2').hide();
        }

        loadAllTags();

        var selected = [];
        var notSelected = new Set(allTags);
        $('.resource-filter-tag.active').each(function() {
            var tag = $(this).data('tag');
            selected.push(tag);
            notSelected.delete(tag);
        });

        var notSelectedArr = Array.from(notSelected);
        var selector = selected.map(x => `.resources .tagged-${x}`).join(', ');
        var antiSelector = notSelectedArr.map(x => `.resources .tagged-${x}`).join(', ');
        $(antiSelector).hide();
        $(selector).show();
    }

    function resetResourceFilters() {
        if (resourceFilterState != 'all') {
            resourceFilterState = 'all';
            $('.resource-filter-tag').addClass('active');
            applyResourceFilters();
        }
    }

    $('.resource-filter-tag').click(function() {
        manipulateFilter($(this).data('tag'), /* toggle */ true, /* elem */ this);
        return false;
    });

    $('#resource-filter-reset').click(function() {
        resetResourceFilters();
        return false;
    });

    $('.resource-tag').click(function() {
        $('html, body').animate({scrollTop: $("#resource-filters").offset().top}, 500);
        manipulateFilter($(this).data('tag'), /* toggle */ false);
        return false;
    });

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

$(document).ready(function() {
    if ($('.error').size() > 0) {
        return false;
    }

    var username = $('#user').text(),
        employee = $('#employee-id').text(),
        password = $('#password').text();

    var narrative = [
        {
            c: "server",
            lines: [
                "--- davischat v9.5.15 on Linux 4.7.2-1-ARCH #1 SMP PREEMPT x86_64 GNU/Linux",
                "--- logging in as " + username + "...",
                2,
                "--- login successful",
                "--- server time is " + new Date().toLocaleString(),
                1
            ]
        },
        {
            c: "info",
            lines: [
                "--- channels you are in: #g0sp0d1n",
                4,
                "--- s4shasepi0lov1ch has joined #g0sp0d1n",
                3
            ]
        },
        {
            c: "msg",
            type: true,
            lines: [
                "<s4shasepi0lov1ch> pozdrav prijatelju",
                "<s4shasepi0lov1ch> potrebna nam je tvoja pomoć",
                "<s4shasepi0lov1ch> z-biotech",
                "<s4shasepi0lov1ch> korporacija koja se bavi biotehnologijom/farmacijom",
                "<s4shasepi0lov1ch> skoro su učestvovali u skandalu oko kontaminacije toksičnim materijama",
                "<s4shasepi0lov1ch> u beogradu",
                "<s4shasepi0lov1ch> nevini ljudi su poginuli",
                "<s4shasepi0lov1ch> sigurno si čuo",
                "<s4shasepi0lov1ch> na američkom sudu podignuta je velika tužba protiv njih",
                "<s4shasepi0lov1ch> ali oni pobeđuju",
                "<s4shasepi0lov1ch> imaju dobar pravni tim",
                "<s4shasepi0lov1ch> ovo ne sme proći",
                "<s4shasepi0lov1ch> nikako",
                "<s4shasepi0lov1ch> skoro smo uspeli da saznamo nešto o IT infrastrukturi",
                "<s4shasepi0lov1ch> koriste jako mator sistem za dokumente",
                "<s4shasepi0lov1ch> ne mator kao 2008",
                "<s4shasepi0lov1ch> mator kao kasne 90te",
                "<s4shasepi0lov1ch> sigurno je pun rupa",
                "<s4shasepi0lov1ch> i trenutno migriraju na novi",
                "<s4shasepi0lov1ch> to je možda dobra šansa",
                "<s4shasepi0lov1ch> uspeli smo da socijalnim inženjeringom dobijemo nalog",
                "<s4shasepi0lov1ch> jednog lika",
                "<s4shasepi0lov1ch> nebitan potpuno",
                "<s4shasepi0lov1ch> radi kao random obezbeđenje",
                1,
                "<s4shasepi0lov1ch> njegov employee id je " + employee + "",
                0.7,
                "<s4shasepi0lov1ch> pass je " + password + "",
                "<s4shasepi0lov1ch> ceo sistem je na http://zbiotech.xyz",
                "<s4shasepi0lov1ch> potrebna nam je neka insajderska informacija o tužbi",
                "<s4shasepi0lov1ch> oko beogradskog slučaja kontaminacije toksičnim otpadom",
                "<s4shasepi0lov1ch> verujem da to drže na tom sistemu negde",
                "<s4shasepi0lov1ch> bonus je ako uspeš da im načiniš neku štetu",
                "<s4shasepi0lov1ch> pride",
                "<s4shasepi0lov1ch> ali informacije su najbitnije",
                "<s4shasepi0lov1ch> moram da palim",
                "<s4shasepi0lov1ch> imam previše posla",
                "<s4shasepi0lov1ch> svi mi imamo",
                "<s4shasepi0lov1ch> probaj nešto da uradiš",
                "<s4shasepi0lov1ch> ako možeš",
                "<s4shasepi0lov1ch> pomoći će brda",
                "<s4shasepi0lov1ch> pozdrav",
                "<s4shasepi0lov1ch> srećno",
                4
            ]
        },
        {
            c: "info",
            lines: [
                "--- s4shasepi0lov1ch has left #g0sp0d1n"
            ]
        },
        {
            c: "err",
            lines: [
                "Connection to host lost."
            ]
        }
    ];

    var sequenceId = 0,
        lineId = 0;

    window.setTimeout(function showNarrative() {
        if (lineId > narrative[sequenceId].lines.length) {
            lineId = 0;
            sequenceId++;

            if (sequenceId > narrative.length) {
                return false;
            }
        }

        var cl = narrative[sequenceId].c,
            type = narrative[sequenceId].type,
            line = narrative[sequenceId].lines[lineId],
            delay = 90,
            node = $('<div class="' + cl + '"></div>').text(line);

        if (type && lineId < narrative[sequenceId].lines.length - 1 && typeof narrative[sequenceId].lines[lineId + 1] === 'string') {
            delay += (narrative[sequenceId].lines[lineId + 1].length - 15) * 40 + 600;
        }

        if (typeof line === 'number') {
            delay += line * 1000;
        } else {
            $('body').append(node);
        }

        lineId++;
        window.setTimeout(showNarrative, delay);
    }, 500);
});

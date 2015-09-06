html = require "lapis.html"

class Home extends html.Widget
    content: =>
        if @nav
            @content_for "header", render "views.nav"
        if @footer
            @content_for "footer", render "views.footer"

        if @m.banner
            with @m.banner
                section id: "banner", ->
                    p class: "duration", .duration 
                    h1 .title
                    h2 .subtitle
                    h3 .tagline

        if @m.cta
            with @m.cta
                section id: "cta", ->
                    h1 .title
                    p raw .text
                    for b in *.buttons
                        a class: "button", href: b.href, b.text

        if @m.testimonials and @m.testimonials.items
            with @m.testimonials
                section id: "testimonials", ->
                    h1 .title
                    ul ->
                        for t in *.items
                            with t
                                li ->
                                    blockquote raw .quote
                                    p class: "attribution", .by

        if @m.lecturers and @lecturers
            with @m.lecturers
                section id: "lecturers", ->
                    h1 .title
                    ul ->
                        for l in *@lecturers
                            with l
                                li ->
                                    img src: .image, title: .name
                                    h2 .name
                                    p class: "affliation", .affliation
                                    p class: "topic", .topic

                    if .button
                        with .button
                            a href: .href, .text
                                    



        


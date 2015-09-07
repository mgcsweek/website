html = require "lapis.html"
import render_html from html

class Home extends html.Widget
    content: =>
        if @nav
            @content_for "header", ->
                render "views.nav"

        if @footer
            @content_for "footer", ->
                render "views.footer"

        @content_for "scripts", ->
            script src: "https://cdnjs.cloudflare.com/ajax/libs/skrollr/0.6.30/skrollr.min.js", defer: "defer"
            script src: "/static/main.js", defer: "defer"

        if @m.banner
            with @m.banner
                section { id: "banner", ["data-0"]: "background-position:0px 0px;", 
                ["data-top-bottom"]: "background-position:0px -100px;"}, ->
                    p class: "duration", .duration 
                    h1 .title
                    h2 .subtitle
                    h3 .tagline

        if @m.cta
            with @m.cta
                section id: "cta", ->
                    h1 .title
                    raw .text
                    p ->
                        for b in *.buttons
                            a class: "button", href: b.href, b.text

        if @m.lecturers and @lecturers
            with @m.lecturers
                section id: "lecturers", ->
                    h1 .title
                    ul ->
                        for l in *[l for l in *@lecturers when l.organizer]
                            with l
                                li ->
                                    img src: .image, title: .name
                                    h2 .name
                                    p class: "affiliation", .affiliation
                                    aside ->
                                        h3 #.topics == 1 and @m.lecturers.topic_title.singular or @m.lecturers.topic_title.plural
                                        ul class: "topics", ->
                                            for t in *.topics
                                                li t
                                        
                                        a {
                                            class: "button", 
                                            href: (@url_for "lecturer", name: l.id), 
                                            @m.lecturers.more_button_text
                                        }

                    if .button
                        with .button
                            a class: "button", href: .href, .text
                                    



        


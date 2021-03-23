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

        if @m.banner
            with @m.banner
                section { id: "banner", ["data-0"]: "background-position:0px 0px;", 
                ["data-top-bottom"]: "background-position:0px -100px;"}, ->
                    h1 .title
                    if .strikethrough_subtitle
                        div class: "strikethrough-subtitle", .strikethrough_subtitle
                    h2 .subtitle
                    p class: "duration", .duration
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
                        for l in *[l for l in *@lecturers when l.featured]
                            with l
                                li ->
                                    img src: .image, title: .name
                                    h2 .name
                                    p class: "affiliation", .affiliation
                                    aside ->
                                        if .topics
                                            h3 #.topics == 1 and @m.lecturers.topic_title.singular or @m.lecturers.topic_title.plural
                                            ul class: "topics", ->
                                                for t in *.topics
                                                    li t

                                        if .special_title
                                            h3 .special_title

                    if .button
                        with .button
                            a class: "button", href: .href, .text

        if @m.video
            with @m.video
                section id: "video", ->
                    h1 .title
                    div class: "video-wrapper", ->
                        yt_allow_what = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        iframe width: "960", src: "https://www.youtube.com/embed/#{.video_id}", frameborder: "0", allow: yt_allow_what, allowfullscreen: true, ""

                    if .buttons
                        div class: "buttons", ->
                            for button in *.buttons
                                a class: "button", href: button.href, button.text








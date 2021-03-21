html = require "lapis.html"

class Materials extends html.Widget
    content: =>
        if @nav
            @content_for "header", ->
                render "views.nav"

        if @footer
            @content_for "footer", ->
                render "views.footer"

        div { class: "parallax-heading", ["data-0"]: "background-position: 50% -30px", 
            ["data-top-bottom"]: "background-position: 50% -150px" }, ->
            h1 @m.heading

        section id: "about-text", class: "content-body", ->
            for section in *@m.content
                h1 section.edition
                for day in *section.days
                    h2 day.timestamp
                    ul ->
                        for lecture in *day.lectures
                            li ->
                                if lecture.url
                                    a href: lecture.url, lecture.title
                                else
                                    span lecture.title

                                if lecture.resources ~= nil
                                    for resource in *lecture.resources
                                        span " | "
                                        a href: resource.url, resource.name

                                --if lecture.tags ~= nil
                                --    div class: "tags", ->
                                --        for tag in *lecture.tags
                                --            if @m.tags[tag] == nil
                                --                print "Invalid tag: #{tag}"
                                --                continue
                                --            span class: "tag", @m.tags[tag]





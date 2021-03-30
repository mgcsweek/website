html = require "lapis.html"

tag_classes = (tags) ->
    if tags and #tags > 0
        table.concat(["tagged-" .. t for t in *tags], " ")
    else
        "tagged-none"

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

        section id: "resource-filters", ->
            div id: "resource-filters-content", ->
                span id: "resource-filter-label", @m.filtering.label
                div class: "resource-filter-tags", ->
                    for tag, c in pairs @m.tags
                        a href: "#", class: "tag resource-filter-tag active", ["data-tag"]: tag, c.title
                a id: "resource-filter-reset", href: "#", @m.filtering['reset-button']

        section class: "content-body", ->
            div class: "resources", ->
                for edition in *@m.content
                    edition_tags = {}
                    for section in *edition.sections
                        for lecture in *section.lectures
                            if not lecture.tags
                                continue
                            for tag in *lecture.tags
                                edition_tags[tag] = true

                    edition_class = tag_classes [t for t, _ in pairs edition_tags]
                    h1 class: edition_class, edition.edition, ->
                        div class: "edition-info-container", ->
                            if edition.date
                                span class: "edition-info edition-date", edition.date
                            if edition.youtube
                                a class: "edition-info edition-yt-link", href: edition.youtube, @m['yt-link-text']

                    for i, section in ipairs edition.sections
                        h2 section.name
                        ul ->
                            for lecture in *section.lectures
                                cls = tag_classes lecture.tags
                                li class: cls, ->
                                    if lecture.url
                                        a href: lecture.url, lecture.title
                                    else
                                        span lecture.title

                                    if lecture.tags
                                        span class: "tags", ->
                                            for tag in *lecture.tags
                                                if @m.tags[tag] == nil
                                                    print "Invalid tag: #{tag}"
                                                    continue
                                                a href: "#", ['data-tag']: tag, class: "resource-tag tag", title: @m.tags[tag].title, @m.tags[tag].slug

                                    if lecture.resources
                                        for resource in *lecture.resources
                                            span " | "
                                            a href: resource.url, resource.name


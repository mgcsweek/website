html = require "lapis.html"
import render_and_pass from require "utils"

class Lecturer extends html.Widget
    content: =>
        @m.title = "#{@lecturers_page.title} - #{@m.name}"
        @m.heading = @lecturers_page.heading

        lecturers_content = capture ->
            article ->
                h1 @m.name
                details class: "email", ->
                    a href: "mailto:#{@m.email}", @m.email

                img src: @m.image
                raw @m.about

        render_and_pass widget, "views.lecturers-base", { :lecturers_content }


html = require "lapis.html"
import render_html from html
import render_and_pass from require "utils"

class Lecturers extends html.Widget
    content: =>
        lecturers_content = capture ->
            ul ->
                for l in *@lecturers
                    if l.hide_on_lecturers_page
                        continue
                        
                    li ->
                        if l.organizer
                            a href: (@url_for "lecturer", name: l.id), ->
                                img src: l.image
                        else
                            img src: l.image

                        div class: "info", ->
                            if l.organizer
                                h1 ->
                                    a href: (@url_for "lecturer", name: l.id), l.name
                            else
                                h1 l.name
                            p class: "affiliation", l.affiliation


                        aside class: "topics", ->
                            h2 (#l.topics == 1 and @m.topics.singular or @m.topics.plural)
                            ul ->
                                for t in *l.topics 
                                    li t


        render_and_pass widget, "views.lecturers-base", { :lecturers_content }
       

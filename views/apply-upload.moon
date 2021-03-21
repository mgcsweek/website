html = require "lapis.html"
import render_and_pass from require "utils"

class ApplyResult extends html.Widget
    content: =>
        chosen_tasks = @application\get_chosen_tasks!
        apply_content = capture ->
            h1 @m.subheading
            raw @m.text
            details ->
                div class: "left", @m.info_label
                div class: "right", ->
                    strong "#{@application.first_name} #{@application.last_name}"
                    if type(@application.school) == 'number'
                        raw ", #{@a.form.schools[@application.school]}, #{@a.form.classes[@application.class]} #{@a.form.class_suffix} ("
                    else
                        raw ", #{html.escape @application.school}, #{@a.form.classes[@application.class]} #{@a.form.class_suffix} ("

                    a href: "mailto:#{@application.email}", 
                         @application.email
                    raw ")"

                div class: "left", @m.chosen_tasks_label
                div class: "right", ->
                    ul ->
                        for t in *chosen_tasks
                            t = @a.tasks[t.task]
                            li t.name

            form enctype: "multipart/form-data", method: "POST", ->
                with @m.form
                    input type: "hidden", name: "csrf-token", value: @csrf_token
                    label for: "pitch", id: "pitch-label", .pitch_label
                    textarea required: "required", id: "pitch", name: "pitch", placeholder: .pitch_placeholder
                    for task in *chosen_tasks
                        t = @a.tasks[task.task]
                        h2 t.name
                        raw t.prompt
                        p ->
                            a class: "upload", ->
                                span .select_files
                                input
                                    required: "required", type: "file", name: "tasks[#{task.task}]",
                                    accept: table.concat [".#{x}" for x in *t.filetypes], ','
                            span class: "filename"

                    div class: "status"

                    button type: "submit", id: "submit-button", .submit_text
                    div class: "spinner", style: "display: none", .please_wait

        render_and_pass widget, "views.apply-base", { :apply_content }


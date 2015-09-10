html = require "lapis.html"
import render_and_pass from require "utils"

class Apply extends html.Widget
    content: =>
        apply_content = capture ->
            raw @m.intro
            with @m.form
                h1 .heading
                form method: "POST", id: "application-form", ->
                    label for: "applicant-name", .name_label
                    input class: "text", required: "required", type: "text", id: "applicant-name", name: "name"
                    label for: "applicant-email", .email_label
                    input class: "text", required: "required", type: "email", id: "applicant-email", name: "email"
                    label for: "applicant-class", .class_label
                    element "select", required: "required", name: "class", ->
                        for c in *.classes
                            option value: c, c

                    label id: "tasks-label", for: "applicant-tasks", .tasks_label
                    ol id: "applicant-tasks", ->
                        for i = 1, #@m.tasks
                            li ->
                                input id: "applicant-task-#{i}", type: "checkbox", name: "tasks[#{i}]"
                                label for: "applicant-task-#{i}", ->
                                    span @m.tasks[i].name

                    div class: "status" 
                    
                    button type: "submit", id: "applicant-submit-button", .next_step_text

        render_and_pass widget, "views.apply-base", { :apply_content }


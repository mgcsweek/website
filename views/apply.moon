html = require "lapis.html"
moon = require 'moon'
import render_and_pass from require "utils"

class Apply extends html.Widget
    content: =>
        apply_content = capture ->
            intro = @m.intro\gsub '%%1', @last_updated or 'непознато'
            raw intro
            with @m.form
                h1 .heading
                form method: "POST", id: "application-form", ->
                    input type: "hidden", name: "csrf_token", value: @csrf_token
                    label for: "applicant-name", .name_label
                    input class: "text", required: "required", type: "text", placeholder: .first_name_placeholder, id: "applicant-first-name", name: "firstname"
                    input class: "text", required: "required", type: "text", placeholder: .last_name_placeholder, id: "applicant-last-name", name: "lastname"
                    label for: "applicant-email", .email_label
                    input class: "text", required: "required", type: "email", placeholder: .email_placeholder, id: "applicant-email", name: "email"
                    label for: "applicant-school", .school_label
                    if not .all_schools
                        element "select", required: "required", name: "school", ->
                            for c in *.schools
                                option value: c, c
                    else
                        input class: "text", required: "required", type: "text", placeholder: .school_placeholder, id: "applicant-school", name: "school"
                        
                    label for: "applicant-class", .class_label
                    element "select", required: "required", name: "class", ->
                        for c in *.classes
                            option value: c, c

                    if #@m.tasks > 0
                        label id: "tasks-label", for: "applicant-tasks", .tasks_label
                        ol id: "applicant-tasks", ->
                            for i = 1, #@m.tasks
                                li ->
                                    input id: "applicant-task-#{i}", type: "checkbox", name: "tasks[#{i}]"
                                    label for: "applicant-task-#{i}", ->
                                        span @m.tasks[i].name

                    div class: "status"

                    button type: "submit", id: "applicant-submit-button", .next_step_text
                    div class: "spinner", style: "display: none", .please_wait

        render_and_pass widget, "views.apply-base", { :apply_content }


html = require "lapis.html"

class Apply extends html.Widget
    content: =>
        if @nav
            @content_for "header", ->
                render "views.nav"

        if @footer
            @content_for "footer", ->
                render "views.footer"

        div { class: "parallax-heading", ["data-0"]: "background-position: 0px -440px",
            ["data-top-bottom"]: "background-position: 0px -150px" }, ->
            h1 @m.heading

        section class: "content-body", ->
            raw @m.intro
            with @m.form
                h1 .heading
                form method: "POST", id: "application-form", ->
                    label for: "applicant-name", .name_label
                    input required: "required", type: "text", id: "applicant-name", name: "name"
                    label for: "applicant-email", .email_label
                    input required: "required", type: "text", id: "applicant-email", name: "email"
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

                    button type: "submit", id: "applicant-submit-button", .next_step_text






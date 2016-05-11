html = require "lapis.html"
import render_and_pass from require "utils"

class ApplyNewsletter extends html.Widget
    content: =>
        apply_content = capture ->
            intro = @m.intro
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

                    div class: "status newsletter-application-status"

                    button type: "submit", id: "applicant-submit-button", .submit_text
                    div class: "spinner", style: "display: none", .please_wait

        render_and_pass widget, "views.apply-base", { :apply_content }


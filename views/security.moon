html = require "lapis.html"

class Security extends html.Widget
    content: =>
        html_5 ->
            head ->
                meta charset: "UTF-8"
                link href: "/static/security.css", rel: "stylesheet", type: "text/css"
                link href: "https://fonts.googleapis.com/css?family=Inconsolata&subset=latin-ext", rel: "stylesheet"
                title @m.title

            body id: "security", ->
                if @error
                    div class: "error", ->
                        raw @error
                else
                    i id: "user", @user
                    i id: "employee-id", style: "display: none", @employee_id
                    i id: "password", style: "display: none", @password

                    script src: "https://code.jquery.com/jquery-2.1.4.min.js", defer: "defer"
                    script src: "/static/security.js", defer: "defer"

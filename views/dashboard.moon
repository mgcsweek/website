html = require "lapis.html"
import to_json from require "lapis.util"

class Dashboard extends html.Widget
    content: =>
        h1 "dashb0ard v0.1 by d4v1s / home"

        element "table", id: "applications", ->
            tr ->
                th rowspan: 3, "Info"
                th rowspan: 3, "School/Class"
                th colspan: #@dashboard.tasks + 3, "Tasks"
                th rowspan: 3, "Applied"
                th rowspan: 3, "Uploaded"

            tr ->
                for i, t in ipairs @dashboard.tasks
                    if i == 2
                        -- security task
                        th colspan: 4, class: "task-col", t.name
                    else
                        th rowspan: "2", class: "task-col", t.name

            tr ->
                th "Chosen"
                th "SQLi"
                th "Admin"
                th "Doc"

            for app in *@dashboard.apps
                tr ->
                    td ->
                        p class: "name", app.name
                        p class: "email", app.email

                    td "#{app.school} / #{app.class}"

                    actions = {
                        'sqli'
                        'admin'
                        'doc'
                    }
                    for i, t in ipairs app.tasks
                        if t
                            if i == 2
                                -- security task
                                td class: "task-col task check security"
                                for action in *actions
                                    classname = "task-col task security"
                                    if app.security_data and app.security_data.actions[action]
                                        classname ..= " check"
                                    td class: classname
                            else
                                td class: "task-col task check", ""
                        else
                            if i == 2
                                for i=1,4
                                    td class: "task-col task security"
                            else
                                td class: "task-col task", ""

                    td app.applied_timestamp
                    td app.uploaded_timestamp


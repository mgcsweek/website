html = require "lapis.html"
import to_json from require "lapis.util"

class Dashboard extends html.Widget
    content: =>
        h1 "dashb0ard v0.1 by d4v1s / home"

        element "table", id: "applications", ->
            tr ->
                th class: "id-col", rowspan: 2, "ID"
                th rowspan: 2, "Info"
                th rowspan: 2, "School/Class"
                th colspan: #@dashboard.tasks, "Tasks"
                th rowspan: 2, "Applied"
                th rowspan: 2, "Uploaded"

            tr ->
                for i, t in ipairs @dashboard.tasks
                    th class: "task-col", t.name

            for app in *@dashboard.apps
                tr ->
                    td "#{app.id}"

                    td ->
                        p class: "name", ->
                            raw app.name
                        p class: "email", app.email

                    td "#{app.school} / #{app.class}"

                    if #app.tasks > 0
                        for i, t in ipairs app.tasks
                            if t
                                td class: "task-col task check", ""
                            else
                                td class: "task-col task", ""
                    else
                        td class: "task-col", "None"

                    td app.applied_timestamp
                    td app.uploaded_timestamp


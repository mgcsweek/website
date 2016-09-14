import Applications, ChosenTasks, Uploads from require 'models'
import insert from table
bridge = require "zbt-bridge"

class Dashboard
    fetch_data: (apply_model) =>
        return nil, "Invalid model." unless apply_model and
                                            apply_model.form and
                                            apply_model.form.classes and
                                            apply_model.form.schools and
                                            apply_model.tasks

        applications = Applications\select "order by email_sent desc"
        return nil, "Could not fetch the applications." unless applications

        model = {}
        for a in *applications
            model_app =
                name: "#{a.last_name} #{a.first_name}"
                email: a.email
                class: apply_model.form.classes[a.class]
                school: apply_model.form.schools[a.school]
                applied_timestamp: os.date "%d.%m.%Y %H:%M", a.email_sent
                uploaded_timestamp: a.submitted > 0 and (os.date "%d.%m.%Y %H:%M", a.submitted) or "No"

            tasks = a\get_chosen_tasks!
            model_app.tasks = if tasks
                app_tasks = {}
                for i = 1,#apply_model.tasks
                    app_tasks[i] = false

                for t in *tasks
                    app_tasks[t.task] = true

                app_tasks
            else
                {}

            if model_app.tasks[2]
                -- security task
                security_participant = bridge\map_application_id a.id
                if security_participant
                    model_app.security_data = security_participant

            insert model, model_app

        {
            apps: model
            tasks: apply_model.tasks
        }



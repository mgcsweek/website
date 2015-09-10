content = require 'content'
csrf = require 'lapis.csrf'
import to_json from require 'lapis.util'

class SubmitApplication
    submit: (params, model) =>
        errors = { }
    
        tasks = { }
        tasklen = #model.tasks
        local tid
        for k, v in pairs params
            if tid = k\match "^tasks%[(%d+)%]$"
                tid = tonumber tid
                if tid >= 1 and tid <= tasklen
                    table.insert tasks, tid 
                else 
                    errors.bad_request = true
        if not errors.bad_request
            errors.bad_request = true
            for c in *model.form.classes
                if c == params.class
                    errors.bad_request = nil
                    break

        with errors
            .missing_name = true if not params.name
            .missing_email = true if not params.email
            .invalid_email = true if (type params.email) != 'string' or not params.email\match "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?"
            .invalid_name = true if (type params.name) != 'string' or not params.name\find ' '
            .task_number_mismatch = true if #tasks < 2

        err_array = { }
        for k, _ in pairs errors
            table.insert err_array, k

        return nil, err_array if #err_array > 0
        true


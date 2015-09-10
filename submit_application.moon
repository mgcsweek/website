content = require 'content'
import to_json from require 'lapis.util'

class SubmitApplication
    submit: (params, model) =>
        errors = { }
    
        print to_json params
        tasks = { }
        tasklen = #model.tasks
        for k, v in pairs params
            if tid = k\match "^tasks%[(%d+)%]$"
                tid = tonumber tid
                table.insert tasks, tid if tid >= 1 and tid <= tasklen else table.insert errors, 'bad_request'

        table.insert errors, 'missing_name' if not params.name
        table.insert errors, 'missing_email' if not params.email
        table.insert errors, 'invalid_email' if (type params.email) != 'string' or not params.email\match "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?"
        table.insert errors, 'invalid_name' if (type params.name) != 'string' or not params.name\find ' '
        table.insert errors, 'task_number_mismatch' if #tasks < 2

        nil, errors if #errors > 0 else true


http = require "lapis.nginx.http"
config = (require "lapis.config").get!
import encode_with_secret from require "lapis.util.encoding"
import from_json from require "lapis.util"
import SecurityCredentials from require "models"

class ZbtBridge
    new_security_credentials: (application_id) =>
        url = config.security_new_user_url
        data = encode_with_secret application_id
        res = http.simple {
            :url
            method: "POST"
            body: {
                id: data
            }
        }

        return nil unless res

        if res and not res.error
            ok, res = pcall ->
                from_json res

            if ok and res.employee_id and res.password
                res
            else
                nil
        else
            nil

    get_security_credentials: (application_id) =>
        credentials = SecurityCredentials\find application_id
        unless credentials
            credentials = @new_security_credentials application_id
            return nil unless credentials

            SecurityCredentials\create {
                :application_id
                employee_id: credentials.employee_id
                password: credentials.password
            }

        credentials

    map_application_id: (application_id) =>
        url = config.security_map_app_id_url
        data = encode_with_secret application_id

        res = http.simple {
            :url
            method: "POST"
            body: {
                id: data
            }
        }

        return nil unless res

        if res and not res.error
            ok, res = pcall ->
                from_json res

            if ok and res.user_id and res.actions
                {
                    user_id: res.user_id
                    actions: {k, true for k in *res.actions}
                }
            else
                nil

        else
            nil

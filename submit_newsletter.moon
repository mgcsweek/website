config = (require 'lapis.config').get!
smtp = require 'resty.smtp'
mime = require 'resty.smtp.mime'
validation = require 'validation'
http = require "lapis.nginx.http"
secrets = require 'secrets'
import from_json from require "lapis.util"
import to_json from require 'lapis.util'
import decode_with_secret, encode_with_secret from require 'lapis.util.encoding'
import validate_functions, validate from require 'lapis.validate'

for i in *{ 'is_email' }
    validate_functions[i] = validation[i]

import NewsletterApplications from require 'models'

class SubmitApplication
    submit: (params, model, url_builder) =>
        errors = { }

        ret = validate params, {
            { 'firstname', exists: true, max_length: 255, 'invalid_name' },
            { 'lastname', exists: true, max_length: 255, 'invalid_name' },
            { 'email', exists: true, max_length: 255, is_email: true, 'invalid_email' }
        }

        -- check recaptcha
        res = http.simple {
            url: "https://www.google.com/recaptcha/api/siteverify"
            method: 'POST'
            body: {
                secret: secrets.recaptcha_secret
                response: params['g-recaptcha-response']
            }
        }

        if res and not res.error
            ok, res = pcall ->
                from_json res

            if not ok
                print "Failed to parse reCAPTCHA reply as JSON: " .. res
                return nil, { 'internal_error' }

            if not res.success
                print "reCAPTCHA failed: " .. table.concat(res['error-codes'], ', ')
                return nil, { 'bad_captcha' }
        else
            print "Failed to send reCAPTCHA verify request: " .. res.error
            return nil, { 'internal_error' }

        if ret
            errors[e] = true for e in *ret

        err_array = { }
        for k, _ in pairs errors
            table.insert err_array, k
        return nil, err_array if #err_array > 0

        prev_app, err = NewsletterApplications\find email: params.email
        if prev_app
            return nil, { 'duplicate_application' }

        if err
            return nil, { 'internal_error' }

        local application, err
        with params
            application, err = NewsletterApplications\create {
                first_name: .firstname,
                last_name: .lastname,
                email: .email
            }

        if not application
            return nil, { 'internal_error' }

        local msg
        with model.email
            txt = mime.wrp 0, mime.b64 .text
            msg =
                headers:
                    to: params.email
                    from: config.smtp_from_newsletter
                    ['message-id']: 'MID-newsletter-confirmation.' .. os.time! .. '@csnedelja.mg.edu.rs'
                    subject: mime.ew .subject, nil, { charset: 'utf-8' }
                    ['content-transfer-encoding']: 'BASE64'
                    ['content-type']: 'text/plain; charset=utf-8'

                body: txt

        ret, err = smtp.send
            from: config.smtp_username
            rcpt: params.email
            user: config.smtp_username
            password: config.smtp_password
            server: config.smtp_server
            port: config.smtp_port
            source: smtp.message(msg)

        if not ret
            print err
            return nil, { 'internal_error' }
        else true


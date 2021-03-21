config = (require 'lapis.config').get!
mail = require 'resty.mail'
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

        mailer, err = mail.new
            host: config.smtp_server,
            port: config.smtp_port,
            starttls: true,
            username: config.smtp_username,
            password: config.smtp_password

        if not mailer
            print err
            return nil, { 'internal_error' }

        local msg
        with model.email
            msg =
                to: { params.email }
                from: config.smtp_from_newsletter
                subject: .subject
                text: .text

        ret, err = mailer\send msg

        if not ret
            print err
            application\delete!
            return nil, { 'internal_error' }
        else true


config = (require 'lapis.config').get!
smtp = require 'resty.smtp'
mime = require 'resty.smtp.mime'
validation = require 'validation'
import to_json from require 'lapis.util'
import decode_with_secret, encode_with_secret from require 'lapis.util.encoding'
import validate_functions, validate from require 'lapis.validate'

for i in *{ 'is_email' }
    validate_functions[i] = validation[i]

import NewsletterApplications from require 'models'

class SubmitApplication
    submit: (params, model, url_builder) =>
        print 'shitters gonna shit'
        errors = { }

        ret = validate params, {
            { 'firstname', exists: true, max_length: 255, 'invalid_name' },
            { 'lastname', exists: true, max_length: 255, 'invalid_name' },
            { 'email', exists: true, max_length: 255, is_email: true, 'invalid_email' }
        }

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


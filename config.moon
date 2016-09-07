config = require 'lapis.config'
secrets = require 'secrets'

config {'development', 'development-perftest'}, ->
    mysql ->
        host '127.0.0.1'
        user 'csweek'
        password 'csweek'
        database 'csweek'

    smtp_server 'mail.csnedelja.mg.edu.rs'
    smtp_port 587
    smtp_username secrets.mail_user
    smtp_password secrets.mail_password
    smtp_from 'MG Nedelja informatike - prijave <prijave@csnedelja.mg.edu.rs>'
    smtp_from_newsletter 'MG Nedelja informatike - newsletter <newsletter@csnedelja.mg.edu.rs>'

    port 8080
    num_workers 1
    code_cache 'off'
    pid_file 'nginx.pid'
    log_file 'logs/error.log'
    log_level 'debug'
    listen_address '127.0.0.1'
    secret 'this is not so secret!'
    content_prefix '../content/'
    filesize_limit 6 * 15 * 1024 * 1024 + 1024
    single_file_limit 15 * 1024 * 1024

    disable_email_confirmation true
    security_new_user_url 'http://127.0.0.1:19222/new_user'

    email_cooldown 20
    uploads_dir 'uploads'
    applications_enabled true

config {'production', 'production-perftest' }, ->
    mysql ->
        host '127.0.0.1'
        user secrets.mysql_user
        password secrets.mysql_password
        database secrets.mysql_db

    smtp_server 'mail.csnedelja.mg.edu.rs'
    smtp_port 587
    smtp_username secrets.mail_user
    smtp_password secrets.mail_password
    smtp_from 'MG Nedelja informatike - prijave <prijave@csnedelja.mg.edu.rs>'
    smtp_from_newsletter 'MG Nedelja informatike - newsletter <newsletter@csnedelja.mg.edu.rs>'

    port 8989
    num_workers 1
    code_cache 'on'
    pid_file '/var/run/nginx/nginx.pid'
    log_file '/var/log/nginx/error.log'
    log_level 'info'
    listen_address '127.0.0.1'
    secret secrets.app_secret
    content_prefix 'content/'
    filesize_limit 6 * 15 * 1024 * 1024 + 1024
    single_file_limit 15 * 1024 * 1024

    disable_email_confirmation true
    security_new_user_url 'http://10.131.29.36:19222/new_user'

    email_cooldown 30 * 60
    uploads_dir 'uploads'
    applications_enabled true

config {'development-perftest', 'production-perftest'}, ->
    code_cache 'on'
    measure_performance -> true

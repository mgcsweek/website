config = require 'lapis.config'

config 'development', ->
    port 8080
    num_workers 1
    code_cache 'off'
    pid_file 'nginx.pid'
    log_file 'log/error.log'
    log_level 'notice'

config 'production', ->
    port 80
    num_workers 1
    code_cache 'on'
    pid_file '/var/run/nginx.pid'
    log_file '/var/log/nginx/error.log'
    log_level 'warning'

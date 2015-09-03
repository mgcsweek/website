config = require 'lapis.config'

config {'development', 'development-perftest'}, ->
    port 8080
    num_workers 1
    code_cache 'off'
    pid_file 'nginx.pid'
    log_file 'logs/error.log'
    log_level 'debug'
    listen_address '127.0.0.1'

config {'production', 'production-perftest' }, ->
    port 8989
    num_workers 1
    code_cache 'on'
    pid_file '/var/run/nginx.pid'
    log_file '/var/log/nginx/error.log'
    log_level 'warn'
    listen_address '127.0.0.1'

config {'development-perftest', 'production-perftest'}, ->
    measure_performance -> true

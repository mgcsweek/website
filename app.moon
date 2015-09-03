lapis = require "lapis"
config = (require "lapis.config").get!

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"

class CSWeek extends lapis.Application
  @before_filter =>
    if #[n for n in *{'production-perftest', 'development-perftest'} when n == config._name] > 0
      after_dispatch ->
        print to_json(ngx.ctx.performance)

  "/": =>
    "Welcome to Lapis #{require "lapis.version"}!"
  
CSWeek

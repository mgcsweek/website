lyaml = require "lyaml"
discount = require "discount"
rex = require "rex_pcre"
config = (require "lapis.config").get!
io = require "io"

class Content
    markdown: (obj) =>
        if type(obj) == "boolean"
            obj
        elseif type(obj) != "table"
            obj = (tostring obj)\gsub "^%s+", ""
            if obj\len() > 0 and obj\sub(1,1) == '$'
                discount ((obj\sub 2)\gsub "^%s+", "")
            else
                obj\gsub "^\\\\$", "$"
        else
            {k, @markdown v for k, v in pairs obj}

    get: (name) =>
        ret, match = pcall -> rex.match name, "^[-0-9a-zA-Z_]+$"
        if not ret 
            nil, "PCRE regex matching failed: #{err}"
        else if not match
            nil, "Invalid name: `#{name}`"
        else
            path = "#{config.content_prefix .. name}.yaml"
            file = io.open(path, "r")
            if file
                contents = file\read("*a")
                if contents
                    ret, yaml = pcall -> lyaml.load(contents)
                    if ret then
                        @markdown yaml
                    else
                        nil, "YAML reading failed in `#{path}`: #{yaml}"
                else
                    nil, "Error reading file `#{path}`"
            else
                nil, "File `#{path}` not found or could not be opened"


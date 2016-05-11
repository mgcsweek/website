config = (require 'lapis.config').get!

is_email = (input, tru) ->
        r = input\match "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?"
        r, "not a valid email: %s"

has_filetype = (input, ...) ->
    ftypes = {...}

    return nil, "doesn't look like a file" if not input or not input.filename

    for t in *ftypes
        ft = t\gsub '%.', '%%.'
        return t if input.filename\match "%.#{ft}$"

    nil, "#{input.filename} must be one of types #{table.concat ftypes, ', '}"

smaller_than = (input, size) ->
    size = config.single_file_limit if type size != 'number'
    input and input.content and #input.content <= size, "file must be less than #{size} bytes"

{ :is_email, :has_filetype, :smaller_than }


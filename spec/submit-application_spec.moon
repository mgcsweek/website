fsmock = require "filesystem-mock"
package.path = "../?.lua;#{package.path}"

describe "application submission module", ->
    with_mock_fs = (obj, vfs, openerr, writeerr, fn) ->
        fs = fsmock.new vfs
        fs.err_on_read = {}
        fs.err_on_write = {}

        if readerr
            for f in *writeerr
                fs.err_on_write[f] = true 

        if openerr
            for f in *openerr
                fs.err_on_open[f] = true 

        fs\inject obj
        fn fs
        fs\restore obj

    setup ->
        export _real_io = require "io"
        package.loaded.io = fsmock.io
        package.loaded["lapis.config"] = {

        }



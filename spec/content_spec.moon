fsmock = require "filesystem-mock"
package.path = "../?.lua;#{package.path}"

inject_fsmock = (fsmock, obj) ->
    fsmock\inject obj

restore_fsmock = (fsmock, obj) ->
    fsmock\restore obj

describe "content module", ->
    with_mock_fs = (obj, vfs, openerr, readerr, fn) ->
        fs = fsmock.new vfs
        fs.err_on_read = {}
        fs.err_on_open = {}

        if readerr
            for f in *readerr
                fs.err_on_read[f] = true 

        if openerr
            for f in *openerr
                fs.err_on_open[f] = true 

        inject_fsmock fs, obj
        fn fs
        restore_fsmock fs, obj

    setup ->
        export _real_io = require "io"
        package.loaded.io = fsmock.io
        package.loaded["lapis.config"] = {
            get: ->
                content_prefix: "content/"
        }

        export content = require "content"

    teardown ->
        content = nil
        package.loaded.io = _real_io

    it "denies invalid names", ->
        with_mock_fs content, {
            -- empty
        }, nil, nil, ->
            badnames = {
                "../../../../../../etc/passwd"
                "ŠČĆĐunicodes"
                "$$%%_specialChars"
                "()()()()()"
            }

            for name in *badnames
                ret, err = content\get name
                assert.falsy ret
                assert.equals "Invalid name: `#{name}`", err

    it "fails with nonexistent files", ->
        with_mock_fs content, {
            -- empty
        }, nil, nil, ->
            ret, err = content\get "nonexistent"
            assert.falsy ret
            assert.equals "File `content/nonexistent.yaml` not found or could not be opened", err

    it "gracefully handles an open error", ->
        with_mock_fs content, {
            "content": 
                "dummy.yaml": "Should not open"
        }, { "content/dummy.yaml" }, nil, ->
            ret, err = content\get "dummy"
            assert.falsy ret
            assert.equals "File `content/dummy.yaml` not found or could not be opened", err

    it "gracefully handles a read error", ->
        with_mock_fs content, {
            "content":
                "dummy.yaml": "Should not read"
        }, nil, { "content/dummy.yaml" }, ->
            ret, err = content\get "dummy"
            assert.falsy ret
            assert.equals "Error reading file `content/dummy.yaml`", err

    it "can parse a basic YAML file", ->
        with_mock_fs content, {
            "content":
                "dummy.yaml": [[
---
test: string
nested:
    - one
    - two
    - three

hey:
    you: are
    my: kind
    of: guy
                ]]
        }, nil, nil, ->
            ret, err = content\get "dummy"
            assert.falsy err
            assert.are.same {
                test: "string"
                nested:  {
                    "one"
                    "two"
                    "three"
                }

                hey:
                    you: "are"
                    my: "kind"
                    of: "guy"
            }, ret

    it "can parse YAML files and use Markdown to parse them", ->
        with_mock_fs content, {
            "content":
                "dummy.yaml": [[
---
nomarkdown: yaay
somemarkdown: |
    $
    # Heading 1

    A paragraph

nested:
    markdown: $ Paragraph
    nomarkdown: happy
                ]]
        }, nil, nil, ->
            ret, err = content\get "dummy"
            assert.falsy err
            assert.are.same {
                nomarkdown: "yaay",
                somemarkdown: [[<h1>Heading 1</h1>

<p>A paragraph</p>
]],
                nested: 
                    markdown: [[<p>Paragraph</p>
]],
                    nomarkdown: 'happy'
            }, ret

    it "correctly coerces numbers to strings", ->
        with_mock_fs content, {
            "content":
                "dummy.yaml": [[
---
anumber: 1234
mdnumber: $ 1234
                ]]
        }, nil, nil, ->
            ret, err = content\get "dummy"
            assert.falsy err
            assert.are.same {
                anumber: "1234",
                mdnumber: [[<p>1234</p>
]],
            }, ret



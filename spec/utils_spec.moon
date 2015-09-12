package.path = '../?.lua;#{package.path}'
package.loaded['lapis.html'] = {}

describe 'utilsities module', ->
    setup ->
        export utils = require 'utils'

    teardown ->
        utils = nil

    describe 'split function', ->
        it 'fails with invalid separators', ->
            assert.falsy utils.split 'this is a string', nil
            assert.falsy utils.split 'this is a string', ''

        it 'fails with a nil string', ->
            assert.falsy utils.split nil, 'separator'

        it 'can split a basic string', ->
            r, n = utils.split 'this is a string', ' '
            assert.equals 4, n
            assert.are.same { 'this', 'is', 'a', 'string' }, r

        it 'handles a separator at the end of the string', ->
            r, n = utils.split 'sep end ', ' '
            assert.equals 3, n
            assert.are.same { 'sep', 'end', '' }, r

        it 'handles a separator at the beginning of the string', ->
            r, n = utils.split ' sep start', ' '
            assert.equals 3, n
            assert.are.same { '', 'sep', 'start' }, r

        it 'handles successive separators', ->
            r, n = utils.split 'sep  successive', ' '
            assert.equals 3, n
            assert.are.same { 'sep', '', 'successive' }, r

        it 'can split using multi-character separators', ->
            r, n = utils.split 'multicharSEPisSEPhere', 'SEP'
            assert.equals 3, n
            assert.are.same { 'multichar', 'is', 'here' }, r

        it 'handles a multichar separator at the end of the string', ->
            r, n = utils.split 'multisep{sep}sep{sep}', '{sep}'
            assert.equals 3, n
            assert.are.same { 'multisep', 'sep', '' }, r

        it 'handles a multichar separator at the beginning of the string', ->
            r, n = utils.split '{sep}multisep{sep}sep', '{sep}'
            assert.equals 3, n
            assert.are.same { '', 'multisep', 'sep' }, r

        it 'handles successive multichar separators', ->
            r, n = utils.split 'multisep{sep}{sep}successive', '{sep}'
            assert.equals 3, n
            assert.are.same { 'multisep', '', 'successive' }, r

        it 'handles a string consisting only of separators', ->
            r, n = utils.split ',,,', ','
            assert.equals 4, n
            assert.are.same { '', '', '', '' }, r

    describe 'json_requested function', ->
        calljr = (hdr) ->
            utils.json_requested { res: { req: { headers: { accept: hdr } } } }

        it 'handles nil requests', ->
            assert.falsy utils.json_requested nil

        it 'handles invalid requests', ->
            assert.falsy utils.json_requested { }
            assert.falsy utils.json_requested { res: { } } 
            assert.falsy utils.json_requested { res: { req: { } } }

        it 'handles when the Accepts header is not present', -> 
            assert.falsy utils.json_requested { res: { req: { headers: { } } } } 

        testcases = 
            ['application/json']: true
            ['application/json, */*']: true
            ['application/json; q=0.05']: true
            ['application/json, */*; q =0.05']: true
            ['application/json, text/html']: true
            ['application/json, text/html; q=0.05']: true
            ['application/json  ']: true
            ['application/json ; q=0.05']: true
            ['application/json ,text/html; q=0.05']: true
            ['text/html, application/json; q=0.05']: false
            ['text/html, application/json']: false
            
        for h, r in pairs testcases
            it "works with `#{h}`", ->
                assert.equals r, calljr h








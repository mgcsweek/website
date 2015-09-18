import insert from table

class SmtpMock
    calls: { }

    message: (msg) ->
        message: msg
        smtp_mock_message: true

    send: (tbl) ->
        insert SmtpMock.calls, tbl
        if SmtpMock.err
            nil, 'smtpmock: Required orchestrated error on email sending'
        else
            true


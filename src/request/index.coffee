###
Copyright (c) 2013, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

{parse: parseUrl} = require 'url'

{request} = require 'http-sync'
debug = require('debug')('webdriver-http-sync:request')

TIMEOUT = 10000
CONNECT_TIMEOUT = 6000

makeResponse = ({headers, body, statusCode}) ->
  lcHeaders = {}
  for name, value of headers
    lcHeaders[name.toLowerCase()] = value
  { headers: lcHeaders, body: body.toString('utf8'), statusCode }

module.exports = ({timeout, connectTimeout} = {}) ->
  timeout ?= TIMEOUT
  connectTimeout ?= CONNECT_TIMEOUT

  (url, method='GET', data=null) ->
    debug '%s %s', method, url, data

    body =
      if data? then new Buffer JSON.stringify(data), 'utf8'
      else new Buffer ''

    options = parseUrl url
    options.host = options.hostname
    options.method = method
    options.headers =
      'Content-Type': 'application/json'
      'Content-Length': body.length
      'X-Foo': 'bar'

    req = request options
    req.write body
    # req.setTimeout timeout
    # req.setConnectTimeout connectTimeout
    result = req.end()
    makeResponse result

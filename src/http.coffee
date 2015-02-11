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

json = require './json'
parseResponseData = require './parse_response'
{EventEmitter} = require 'events'

clone = (object) ->
  json.tryParse JSON.stringify object

normalizeUrl = (serverUrl, sessionRoot, url) ->
  if url.indexOf('http') == 0
    url
  else
    serverUrl + sessionRoot + url

emitter = new EventEmitter

log = (message) ->
  emitter.emit 'request', message

verbose = (response) ->
  parsed = parseResponseData(response)
  message = clone response
  message.body = JSON.stringify parsed
  emitter.emit 'response', message

registerEventHandler = (event, callback) ->
  if event not in ['request', 'response']
    throw new Error "Invalid event name '#{event}'. The WebDriver http module only emits 'request' and 'response' events."
  emitter.on event, callback

module.exports = (request, serverUrl, sessionId) ->
  sessionRoot = "/session/#{sessionId}"

  get = (url) ->
    url = normalizeUrl(serverUrl, sessionRoot, url)
    log "[WEB] GET #{url}"
    response = request(url)
    verbose response
    response

  post = (url, data={}) ->
    url = normalizeUrl(serverUrl, sessionRoot, url)
    method = 'POST'
    log "[WEB] POST #{url} : #{data}"
    response = request(url, method, data)
    verbose response
    response

  del = (url) ->
    url = normalizeUrl(serverUrl, sessionRoot, url)
    method = 'DELETE'
    log "[WEB] DELETE #{url}"
    response = request(url, method)
    verbose response
    response

  http = {
    get
    post
    delete: del
    on: registerEventHandler
  }

  return http


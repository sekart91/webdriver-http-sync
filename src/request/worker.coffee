'use strict'
{request} = require 'http'
{parse: parseUrl} = require 'url'

concat = require 'concat-stream'

process.stdin.setEncoding 'utf8'
process.stdin.pipe concat (rawInput) ->
  {method, url, json, headers} = JSON.parse rawInput
  options = parseUrl url
  options.method = method
  options.headers = headers || {}
  options.agent = false
  if json
    data = new Buffer JSON.stringify json
    options.headers['Content-Type'] = 'application/json'
    options.headers['Content-Length'] = data.length

  req = request options

  req.on 'response', (res) ->
    res.setEncoding 'utf8'
    res.pipe concat (body) ->
      result = JSON.stringify({
        statusCode: res.statusCode
        headers: res.headers
        body: body
      }) + '\n'
      process.stdout.write result, ->
        process.exit 0

  if data then req.end data
  else req.end()

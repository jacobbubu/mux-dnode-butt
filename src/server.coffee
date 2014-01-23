http = require 'http'
ecstatic = require('ecstatic') root: __dirname + '/../static'
dnode = require 'dnode'
MuxDemux = require 'mux-demux'
WebsocketServer = require('ws').Server
websocket = require 'websocket-stream'
Model = require('scuttlebutt/model')

httpServer = http.createServer ecstatic
wsServer = new WebsocketServer server: httpServer

rpcSpecs =
  transform: (s, next) ->
    next s.replace(/[aeiou]{2,}/, 'oo').toUpperCase()

wsServer.on 'connection', (ws) ->
  timerModel = new Model()

  #  change the model value periodically
  iv = setInterval ->
    timerModel.set 'timer', new Date
  , 1e3

  #  wrap a incoming websocket as a stream
  conn = websocket ws
  mx = MuxDemux (_stream) ->
    switch _stream.meta
      when 'rpc'
        _stream.pipe(dnode rpcSpecs).pipe _stream
      when 'timer'
        _stream.pipe(timerModel.createStream()).pipe _stream

  conn.on 'close', ->
    (clearInterval iv; iv = null) if iv?
    mx.destroy()

  # bullet proof
  mx.on 'error', (err) ->
    conn.destroy()
  conn.on 'error', (err) ->
    mx.destroy()

  conn.pipe(mx).pipe conn

  #  watch the in-out messages
  conn.pipe process.stdout, end: false

httpServer.listen 9999
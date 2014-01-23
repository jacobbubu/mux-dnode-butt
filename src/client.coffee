domready = require 'domready'
websocket = require 'websocket-stream'
dnode = require 'dnode'
MuxDemux = require 'mux-demux'
Model = require('scuttlebutt/model')

domready ->
  resultNode = document.getElementById 'result'
  timerNode = document.getElementById 'timer'
  conn = websocket 'ws://localhost:9999'
  d = dnode()
  mx = MuxDemux()

  d.on 'remote', (remote) ->
    remote.transform 'beep', (s) ->
      resultNode.textContent = 'beep => ' + s

  timerModel = new Model()

  # bind rpc stream and scuttlebutt stream to mx
  mxStreamForRpc = mx.createStream 'rpc'
  mxStreamForRpc.pipe(d).pipe mxStreamForRpc
  mxStreamForTimer = mx.createStream 'timer'
  mxStreamForTimer.pipe(timerStream = timerModel.createStream wrapper:'raw').pipe mxStreamForTimer

  #  bind mx to conn
  conn.pipe(mx).pipe conn

  #  just use the 'data' event as a triggle to fetch model data
  timerStream.on 'data', (data) ->
    timerNode.textContent = timerModel.get 'timer'

var Model, MuxDemux, dnode, domready, websocket;

domready = require('domready');

websocket = require('websocket-stream');

dnode = require('dnode');

MuxDemux = require('mux-demux');

Model = require('scuttlebutt/model');

domready(function() {
  var conn, d, mx, mxStreamForRpc, mxStreamForTimer, resultNode, timerModel, timerNode, timerStream;
  resultNode = document.getElementById('result');
  timerNode = document.getElementById('timer');
  conn = websocket('ws://localhost:9999');
  d = dnode();
  mx = MuxDemux();
  d.on('remote', function(remote) {
    return remote.transform('beep', function(s) {
      return resultNode.textContent = 'beep => ' + s;
    });
  });
  timerModel = new Model();
  mxStreamForRpc = mx.createStream('rpc');
  mxStreamForRpc.pipe(d).pipe(mxStreamForRpc);
  mxStreamForTimer = mx.createStream('timer');
  mxStreamForTimer.pipe(timerStream = timerModel.createStream()).pipe(mxStreamForTimer);
  conn.pipe(mx).pipe(conn);
  return timerStream.on('data', function(data) {
    return timerNode.textContent = timerModel.get('timer');
  });
});

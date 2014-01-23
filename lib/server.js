var Model, MuxDemux, WebsocketServer, dnode, ecstatic, http, httpServer, rpcSpecs, websocket, wsServer;

http = require('http');

ecstatic = require('ecstatic')({
  root: __dirname + '/../static'
});

dnode = require('dnode');

MuxDemux = require('mux-demux');

WebsocketServer = require('ws').Server;

websocket = require('websocket-stream');

Model = require('scuttlebutt/model');

httpServer = http.createServer(ecstatic);

wsServer = new WebsocketServer({
  server: httpServer
});

rpcSpecs = {
  transform: function(s, next) {
    return next(s.replace(/[aeiou]{2,}/, 'oo').toUpperCase());
  }
};

wsServer.on('connection', function(ws) {
  var conn, iv, mx, timerModel;
  timerModel = new Model();
  iv = setInterval(function() {
    return timerModel.set('timer', new Date);
  }, 1e3);
  conn = websocket(ws);
  mx = MuxDemux(function(_stream) {
    switch (_stream.meta) {
      case 'rpc':
        return _stream.pipe(dnode(rpcSpecs)).pipe(_stream);
      case 'timer':
        return _stream.pipe(timerModel.createStream()).pipe(_stream);
    }
  });
  conn.on('close', function() {
    if (iv != null) {
      clearInterval(iv);
      iv = null;
    }
    return mx.destroy();
  });
  mx.on('error', function(err) {
    return conn.destroy();
  });
  conn.on('error', function(err) {
    return mx.destroy();
  });
  conn.pipe(mx).pipe(conn);
  return conn.pipe(process.stdout, {
    end: false
  });
});

httpServer.listen(9999);

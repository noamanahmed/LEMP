const express = require('express')
const http = require('http');
const app = express()
const port = {{port}}

var server = http.createServer(app);

app.get('/', (req, res) => {
    res.send('A starter app.js has been setup for you on node version:!' + process.versions.node)
})

server.listen(port, '127.0.0.1');

server.on('listening', function() {
    console.log(`Example app listening on port http:\/\/${server.address().address}:${port}`)
})
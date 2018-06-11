const express = require('express');

const server = express();

server.get('/', (req, res) => {
  console.log('-----------incoming connection-------------');
  console.log(req.ip);
  res.sendFile(__dirname + '/script.rb');
});

server.listen(9000, () => {
  require('child_process').exec('ipconfig getifaddr en0', (error, stdout, stderr) => {
    console.log(`YOUR LOCAL IP: http://${stdout.replace('\n', '')}:9000`);
  });
});

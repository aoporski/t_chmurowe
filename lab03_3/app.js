const http = require('http');
const port = 3000;
const server = http.createServer((req, res) => {
    res.end('Hello from Node.js');
});
server.listen(port, () => {
    console.log(`Node.js running on port ${port}`);
});

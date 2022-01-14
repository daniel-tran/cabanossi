const http = require('http');
const url = require('url');
const { extract } = require('article-parser');

// Example: http://localhost:277/?url=https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/
const requestListener = function (req, res) {  
  extract(url.parse(req.url, true).query.url).then((article) => {
    console.log(article);
    res.writeHead(200).end(JSON.stringify(article));
  }).catch((err) => {
    console.trace(err);
    res.writeHead(500).end('ERROR');
  });
}

const server = http.createServer(requestListener);
server.listen(277);

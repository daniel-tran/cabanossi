const http = require('http');
const url = require('url');
const { extract } = require('article-parser');

const requestListener = function (req, res) {  
  const targetUrl = url.parse(req.url, true).query.url ?? '';
  extract(targetUrl).then((article) => {
    console.log(article);
    res.writeHead(200).end(JSON.stringify(article));
  }).catch((err) => {
    console.trace(err);
    res.writeHead(500).end(`ERROR: ${err.message}`);
  });
}

const server = http.createServer(requestListener);
server.listen(277);

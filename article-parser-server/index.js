const http = require('http');
const url = require('url');
const { extract } = require('article-parser');
const { read } = require('feed-reader');

const requestListener = function (req, res) {
  const params = url.parse(req.url, true).query;
  const targetUrl = params.url ?? '';
  const process = params.isRssFeed ? read : extract;
  process(targetUrl).then((article) => {
    console.log(article);
    res.writeHead(200).end(JSON.stringify(article));
  }).catch((err) => {
    console.trace(err);
    res.writeHead(500).end(`ERROR: ${err.message}`);
  });
}

const server = http.createServer(requestListener);
server.listen(277);

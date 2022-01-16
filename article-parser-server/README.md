# article-parser-server

A simple web server with a single GET endpoint that returns data about a given webpage.

## Valid URL

Specify a target URL to parse using the `url` parameter. Its protocol must be either HTTP or HTTPS.

### Example request

`curl http://localhost:277/?url=https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/`

### Example response

```
{
  url: 'https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/',
  title: 'How do I create a HTTP server? | Node.js',
  description: "Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine.",
  links: [
    'https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/'
  ],
  image: 'https://nodejs.org/static/images/logo-hexagon-card.png',
  content: "<div><div><article><p>Making a simple HTTP server in Node.js has become the de facto 'hello world' for the platform. On the one hand, Node.js provides extremely easy-to-use HTTP APIs; on the other hand, a simple web server also serves as an excellent demonstration of the asynchronous strengths of Node.js.</p><p>Let's take a look at a very simple example:</p><pre><code><span>const</span> http <span>=</span> <span>require</span><span>(</span><span>'http'</span><span>)</span><span>;</span>\n" +
    '\n' +
    '<span>const</span> <span>requestListener</span> <span>=</span> <span>function</span> <span>(</span><span>req<span>,</span> res</span><span>)</span> <span>{</span>\n' +
    '  res<span>.</span><span>writeHead</span><span>(</span><span>200</span><span>)</span><span>;</span>\n' +
    "  res<span>.</span><span>end</span><span>(</span><span>'Hello, World!'</span><span>)</span><span>;</span>\n" +
    '<span>}</span>\n' +
    '\n' +
    '<span>const</span> server <span>=</span> http<span>.</span><span>createServer</span><span>(</span>requestListener<span>)</span><span>;</span>\n' +
    'server<span>.</span><span>listen</span><span>(</span><span>8080</span><span>)</span><span>;</span>\n' +
    "</code></pre><p>Save this in a file called <code>server.js</code> - run <code>node server.js</code>, and your program will hang there... it's waiting for connections to respond to, so you'll have to give it one if you want to see it do anything. Try opening up a browser, and typing <code>localhost:8080</code> into the location bar. If everything has been set up correctly, you should see your server saying hello!</p><p>Also, from your terminal you should be able to get the response using curl:</p><pre><code>curl localhost:8080\n" +
    `</code></pre><p>Let's take a more in-depth look at what the above code is doing. First, a function is defined called <code>requestListener</code> that takes a request object and a response object as parameters.</p><p>The request object contains things such as the requested URL, but in this example we ignore it and always return "Hello World".</p><p>The response object is how we send the headers and contents of the response back to the user making the request. Here we return a 200 response code (signaling a successful response) with the body "Hello World". Other headers, such as <code>Content-type</code>, would also be set here.</p><p>Next, the <code>http.createServer</code> method creates a server that calls <code>requestListener</code> whenever a request comes in. The next line, <code>server.listen(8080)</code>, calls the <code>listen</code> method, which causes the server to wait for incoming requests on the specified port - 8080, in this case.</p><p>There you have it - your most basic Node.js HTTP server.</p></article></div></div>`,
  author: 'Node.js',
  source: '@nodejs',
  published: '',
  ttr: 69
}
```

## Valid RSS feed

To process a URL of an RSS feed, simply include the `isRssFeed` parameter and assign it any non-empty value.

### Example request

`curl http://localhost:277/?url=https://stackoverflow.com/feeds&isRssFeed=true`

### Example response

```
{
  title: 'Recent Questions - Stack Overflow',
  link: 'https://stackoverflow.com/feeds',
  description: 'most recent 30 from stackoverflow.com',
  generator: '',
  language: '',
  published: '2022-01-16T03:55:00.000Z',
  entries: [
    {
    ...
    }
  ]
}
```

## Valid URL with abnormal page layout

Some pages may use a layout which is incompatible with the article-parser library, such as RSS feeds (without the `isRssFeed` flag) or URL's that don't exist. These register as an invalid URL in the server console output.

### Example request

`curl http://localhost:277/?url=https://stackoverflow.com/feeds`

`curl http://localhost:277/?url=http://localhost:277/fakeEndpoint`

### Example response

```
null
```

## Invalid or unspecified URL

### Example request

`curl http://localhost:277/?url=`

`curl http://localhost:277/`

`curl http://localhost:277/?url=ftp://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/`

### Example response

```
ERROR: Input must be a valid URL
```

## Invalid RSS feed

You will get an error when attempting to process a regular web page as an RSS feed.

### Example request

`curl http://localhost:277/?url=https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/&isRssFeed=true`

### Example response

```
ERROR: Could not fetch XML content from "https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTP-server/"
```

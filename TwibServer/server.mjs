import { createServer } from "node:http";

const hostname = "127.0.0.1";
const port = 3000;

const gitHub = "https://github.com/ohhh25/Twib-Music";

const server = createServer((req, res) => {
  res.setHeader('Content-Type', 'text/html');
  if (req.url === "/") {
    res.statusCode = 200;
    res.end("<h1>Hello and Welcome to Twib Server!</h1>" +
      "<p>Click <a href='/Twib-Music'>here</a> to visit Twib Music</p>"
    );
  } else if (req.url === "/Twib-Music") {
    res.statusCode = 200;
    // hyper-link to the github repo
    res.end("<h1>Welcome to Twib Music!</h1>Check out the GitHub repo " +
      `<a href="${gitHub}">here</a>`);
  }
  else {
    res.statusCode = 404;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Page Not Found!\n');
  }
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});

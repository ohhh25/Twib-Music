import express from "express";
import apiLogger from "./apiLogger.mjs";
import yts from "yt-search";

const hostname = "127.0.0.1";
const port = 3000;

const homepage = `http://${hostname}:${port}`;
const gitHub = "https://github.com/ohhh25/Twib-Music";

var app = express();
app.set("json spaces", 2);

app.use("/Twib-Music", express.static("public"));
app.use("/api/Twib-Music", apiLogger);

app.get("/", (req, res) => {
  res.status(200).send("<h1>Hello and Welcome to Twib Server!</h1>" +
    "<p>Click <a href='/Twib-Music'>here</a> to visit Twib Music</p>"
  );
});

app.get("/Twib-Music", (req, res) => {
  res.status(200).send("<h1>Welcome to Twib Music!</h1>Check out the GitHub repo " +
    `<a href="${gitHub}">here</a>`);
});

app.get("/api/Twib-Music", (req, res) => {
  const { isrc } = req.query;
  if (!isrc) {
    res.status(400).send("<h1>Twib Music API</h1><h2>Usage</h2>" +
      "<p><b>ISRC:</b> Enter an ISRC code to get more information about a song. " +
      `Example: <a href="${homepage}/api/Twib-Music?isrc=usug12301406">/api/Twib-Music?isrc=usug12301406</a></p>`);
  } else {
    res.status(200).json({"isrc": isrc, 
        "youtube": `https://www.youtube.com/results?search_query=${isrc}`
    });
  }
});

app.post("/api/Twib-Music", express.json(), async (req, res) => {
  const { metadata } = req.body;
  const ytLinks = await Promise.all(metadata.map( async (song) => {
    const { isrc } = song;
    if (!isrc) {
      console.log("No ISRC code found. Performing a manual search...");
      const  { query } = `${song.title} ${song.artist}`;
      const { videos } = await yts(query);
      return videos[0].url;
    } else {
      const { videos } = await yts(isrc);
      return videos[0].url;
    }
  }));
  res.status(200).json({"youtube": ytLinks});
});

app.get("*", (req, res) => {
  res.status(404).send('Page Not Found!\n');
});

app.listen(port, hostname, () => {
  console.log(`Server running at ${homepage}/\n`);
  console.log(`${homepage}/api/Twib-Music/`);
});

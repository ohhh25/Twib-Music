import express from "express";
import apiLogger from "./apiLogger.mjs";
import yts from "yt-search";
import fs from "fs";
import ytdl from "@distube/ytdl-core";
import { url } from "inspector";

const hostname = "127.0.0.1";
const port = 3000;

const homepage = `http://${hostname}:${port}`;
const gitHub = "https://github.com/ohhh25/Twib-Music";

if (!fs.existsSync('./downloads')) {
  fs.mkdirSync('./downloads');
}

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

const getQuery = (song) => {
  const { isrc, title, artist } = song;
  if (isrc) {
    return isrc;
  }
  console.log("No ISRC code found. Performing a manual search...");
  return `${title} ${artist}`;
}

const search = async (song) => {
  const { sID } = song;
  const filePath = `./downloads/${sID}.m4a`;
  const query = getQuery(song);
  const { videos } = await yts(query);
  return {
    url: videos[0].url,
    filePath: filePath
  };
}

const downloadList = async (req, res, next) => {
  const { metadata } = req.body;
  try {
    const ytLinks = await Promise.all(metadata.map( async (song) => {
      const { url, filePath } = await search(song);
      const audioStream = ytdl(url, { quality: '140' });

      const download = new Promise((resolve, reject) => {
        audioStream.pipe(fs.createWriteStream(filePath));

        audioStream.on('error', (err) => {
          console.error(`Error in audio stream: ${err.message}`);
          fs.unlink(filePath, () => {}); // Clean up empty file
          reject(err);
        });

        audioStream.on('end', () => {
          console.log(`Downloaded ${song.name} by ${song.artist}`);
          resolve();
        });
      });

      await download;
      return url;
    }));

    req.ytLinks = ytLinks;
    next();
  } catch (err) {
    console.error(`Error in download: ${err.message}`);
    res.status(500).send("Error downloading songs");
  }
}

app.post("/api/Twib-Music", express.json(), async (req, res) => {
  await downloadList(req, res, () => {
    console.log("Downloaded all songs!");
    res.status(200).json({"youtube": req.ytLinks});
  });
});

app.get("*", (req, res) => {
  res.status(404).send('Page Not Found!\n');
});

app.listen(port, hostname, () => {
  console.log(`Server running at ${homepage}/\n`);
  console.log(`${homepage}/api/Twib-Music/`);
});

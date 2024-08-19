import express from "express";
import fs from "fs";
import yts from "yt-search";
import ytdl from "@distube/ytdl-core";

import apiLogger from "./logger.mjs";

const router = express.Router();
router.use(apiLogger);
router.use(express.json());

// Search for a song and return its URL and file path
const search = async (song) => {
  const { isrc, sID, title, artist } = song;    // extract song metadata
  const query = isrc ? isrc : `${title} ${artist}`;    // search query
  const { videos } = await yts(query);    // search for videos
  return {url: videos[0].url, filePath: `./downloads/${sID}.m4a`};
}

const singleDownload = async (song) => {
  const { url, filePath } = await search(song);    // get URL and file path
  const audioStream = ytdl(url, { quality: '140' });    // get audio stream

  const download = new Promise((resolve, reject) => {
    audioStream.pipe(fs.createWriteStream(filePath));    // pipe stream to file
    
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
  return filePath;
}

const downloadList = async (req, res, next) => {
  const { metadata } = req.body;    // extract metadata from request body
  try {
    const ytLinks = await Promise.all(metadata.map( async (song) => {
      const url = await singleDownload(song);
      return url;
    }));

    req.ytLinks = ytLinks;
    next();

  } catch (err) {
    console.error(`Error in download: ${err.message}`);
    res.status(500).send("Error downloading songs");
  }
}

router.post("/", async (req, res) => {
  await downloadList(req, res, () => {
    console.log("Downloaded all songs!");
    res.status(200).json({"youtube": req.ytLinks});
  });
});

export default router;

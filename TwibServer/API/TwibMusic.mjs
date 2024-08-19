import express from "express";
import fs from "fs";
import path from "path";

import yts from "yt-search";
import ytdl from "@distube/ytdl-core";
import archiver from "archiver";

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

const singleDownload = async (song, zipStream) => {
  const { url, filePath } = await search(song);    // get URL and file path
  const audioStream = ytdl(url, { quality: '140' });    // get audio stream
  const fileName = path.basename(filePath);

  zipStream.append(audioStream, { name: fileName });   // append stream to zip

  return new Promise((resolve, reject) => {
    audioStream.on('error', (err) => {
      console.error(`Error in audio stream: ${err.message}`);
      reject(err);
    });

    audioStream.on('end', () => {
      console.log(`Downloaded ${song.name} by ${song.artist}`);
      resolve();
    });
  });
}

router.post("/", async (req, res) => {
  const { metadata } = req.body;    // extract metadata from request body
  try {
    const zipStream = archiver('zip', { zlib: { level: 9 } });
    res.attachment('songs.zip');
    zipStream.pipe(res);    // pipe zip stream to response

    await Promise.all(metadata.map(song => singleDownload(song, zipStream)));
    zipStream.finalize();    // finalize zip stream
  }
  catch (err) {
    console.error(`Error in POST /api/Twib-Music: ${err.message}`);
    res.status(500).send("Error processing request");
  }
});

export default router;

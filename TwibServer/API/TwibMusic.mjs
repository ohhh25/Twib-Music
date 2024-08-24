import express from "express";

import yts from "yt-search";
import ytdl from "@distube/ytdl-core";
import archiver from "archiver";

import apiLogger from "./logger.mjs";

const router = express.Router();
router.use(apiLogger);
router.use(express.json());


const chunkArray = (array, size) => {
  const result = [];
  for (let i = 0; i < array.length; i += size) {
    result.push(array.slice(i, i + size));
  }
  return result;
};

// Search for a song and return its URL
const search = async (song) => {
  const { isrc, sID, title, artist } = song;    // extract song metadata
  const query = isrc ? isrc : `${title} ${artist}`;    // search query
  const { videos } = await yts(query);    // search for videos
  if (!videos.length && query === isrc) {
    console.warn(`No results found for ${query} Retrying search with different query`);
    const { videos } = await yts(`${title}`);   // retry search with title
    if (!videos.length) {
      throw new Error(`No results found for ${title}`);
    }
    return videos[0].url;
  }
  return videos[0].url;
};

// Download a single song
const singleDownload = async (song, zipStream) => {
  const url = await search(song);    // get URL
  const audioStream = ytdl(url, { quality: '140' });    // get audio stream

  return new Promise((resolve, reject) => {
    audioStream.on('error', (err) => {
      console.error(`Error in audio stream: ${err.message}`);
      reject(err);
    });

    zipStream.append(audioStream, { name: `${song.sID}.m4a` });   // append stream to zip

    audioStream.on('end', () => {
      console.log(`Downloaded ${song.name} by ${song.artist}`);
      resolve();
    });
  });
}

router.post("/", async (req, res) => {
  const { metadata } = req.body;    // extract metadata from request body
  const batchSize = 10;    // number of songs to download in each batch

  try {
    const zipStream = archiver('zip', { zlib: { level: 9 } });
    res.attachment('songs.zip');
    zipStream.pipe(res);    // pipe zip stream to response

    const batches = chunkArray(metadata, batchSize);

    for (const batch of batches) {
      const downloadPromises = batch.map(song => singleDownload(song, zipStream));
      await Promise.all(downloadPromises);    // wait for all downloads to complete
    }

    console.log("Request processed successfully");
    zipStream.finalize();    // finalize zip stream
  }
  catch (err) {
    console.error(`Error in POST /api/Twib-Music: ${err.message}`);
    res.status(500).send("Error processing request");
  }
});

export default router;

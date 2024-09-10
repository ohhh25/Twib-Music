import express from "express";
import fs from "fs";

import yts from "yt-search";
import ytdl from "@distube/ytdl-core";
import archiver from "archiver";

import apiLogger from "./logger.mjs";

const router = express.Router();
router.use(apiLogger);
router.use(express.json());

const globalQueue = [];
let processingBatch = false;

const agent = ytdl.createAgent(JSON.parse(fs.readFileSync("cookies.json")));

const chunkArray = (array, size) => {
  const result = [];
  console.log(`Received metadata for ${array.length} songs`);
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
  const audioStream = ytdl(url, { quality: '140' }, { agent });    // get audio stream

  const timeout = new Promise((_, reject) => 
    setTimeout(() => reject(new Error(`Download timed out for ${song.name}`)), 10000)
  );

  const downloadTask = new Promise((resolve, reject) => {
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

  return Promise.race([downloadTask, timeout]);
};

// Process a batch of songs
const processBatch = async (batch, zipStream) => {
  try {
    const downloadPromises = batch.map(song => singleDownload(song, zipStream));
    await Promise.all(downloadPromises);    // wait for all downloads to complete
    await new Promise((resolve) => setTimeout(resolve, 2000));    // wait for 2 seconds
  } catch (err) {
    console.error(`Error processing batch: ${err.message}`);
    throw err;
  }
};

// Process the global queue in an alternating fashion
const processQueue = async () => {
  if (processingBatch) {
    return;
  }

  processingBatch = true;

  try {
    // Keep processing as long as there are requests in the queue
    while (globalQueue.length) {
      const currentRequest = globalQueue.shift();  // Get the first request
      const { batches, zipStream } = currentRequest;

      const currentBatch = batches.shift();  // Get the next batch for this request

      try {
        await processBatch(currentBatch, zipStream);  // Process this batch
      } catch (err) {
        console.error(`Error processing batch: ${err.message}`);
        throw err;
      }

      // If there are more batches left, move the request to the back of the queue
      if (batches.length) {
        globalQueue.push(currentRequest);
      } else {
        // Finalize the zip stream when all batches are done
        zipStream.finalize();
        console.log("Request processed successfully");
      }

      // Wait a short time before processing the next batch (optional)
      await new Promise((resolve) => setTimeout(resolve, 100));  // Add a slight delay
    }
  } finally {
    processingBatch = false;  // Reset flag once all requests are processed
  }
};

router.post("/", async (req, res) => {
  const { metadata } = req.body;    // extract metadata from request body
  const batchSize = 1;    // number of songs to download in each batch

  // Create a new request object
  const request = {
    "batches": chunkArray(metadata, batchSize),
    "zipStream": archiver('zip', { zlib: { level: 9 } })
  };

  res.attachment(`${Date.now()}.zip`);    // set response headers

  request.zipStream.on('error', (err) => {
    console.error(`Error in zip stream: ${err.message}`);
    res.end();
  });

  request.zipStream.pipe(res);    // pipe zip stream to response

  // Add the request to the global queue
  globalQueue.push(request);

  try {
    await processQueue();    // process the queue
  } catch (err) {
    console.error(`Error processing queue: ${err.message}`);
    res.end();
  }
});

export default router;

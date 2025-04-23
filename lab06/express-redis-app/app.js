const express = require("express");
const { createClient } = require("redis");

const app = express();
const port = 3000;
const redisClient = createClient({ url: "redis://redis:6379" });

app.use(express.json());

redisClient.connect().catch(console.error);

app.post("/message", async (req, res) => {
  const { key, message } = req.body;
  if (!key || !message) {
    return res.status(400).json({ error: "Key and message are required." });
  }
  await redisClient.set(key, message);
  res.json({ status: "Message saved", key, message });
});

app.get("/message/:key", async (req, res) => {
  const message = await redisClient.get(req.params.key);
  if (!message) return res.status(404).json({ error: "Message not found." });
  res.json({ key: req.params.key, message });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3003;

const url = 'mongodb://db:27017';
const dbName = 'mydb'; 

app.get('/users', async (req, res) => {
  const client = new MongoClient(url);
  try {
    await client.connect();
    const db = client.db(dbName);
    const users = await db.collection('users').find().toArray();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  } finally {
    await client.close();
  }
});

app.listen(port, () => {
  console.log(`API server listening on port ${port}`);
});
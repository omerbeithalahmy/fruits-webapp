const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;

const mongoUrl = 'mongodb://db:27017';
const dbName = 'appdb';

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/', async (req, res) => {
  let client;
  try {
    client = await MongoClient.connect(mongoUrl);
    const db = client.db(dbName);
    
    const appleData = await db.collection('fruits').findOne({ name: 'apples' });
    
    const appleCount = appleData ? appleData.qty : 0;

    const htmlResponse = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Hello World - Apples</title>
        </head>
        <body>
          <h1>Hello World!</h1>
          <h2>Number of apples in DB: ${appleCount}</h2>
        </body>
      </html>
    `;
    
    res.send(htmlResponse);
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).send('<h1>Error connecting to database!</h1>');
  } finally {
    if (client) {
      await client.close(); 
    }
  }
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
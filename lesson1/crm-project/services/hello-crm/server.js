const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello CRM! This is your first microservice running. Welcome to the future of customer relations.');
});

app.listen(port, () => {
  console.log();
});

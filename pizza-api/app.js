const express = require('express');
const generatePizza = require('./pizza');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    const { isBianca } = req.query;
    res.send(generatePizza({ isBianca: !!isBianca }));
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
});

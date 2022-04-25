const express = require('express')
const app = express()
const port = {{port}}

app.get('/', (req, res) => {
    res.send('A starter app.js has been setup for you.!')
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})
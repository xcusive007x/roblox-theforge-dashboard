const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000; 

app.use(cors());
app.use(bodyParser.json());


let lastUpdateTime = 0;

let playerData = {
    username: "Waiting...",
    userId: 0,
    level: "N/A",
    gold: "N/A",
    capacity: "N/A",
    items: [],
    avatarUrl: "https://tr.rbxcdn.com/53eb9b17fe1432a809c73a13889b5006/150/150/Image/Png"
};

async function fetchRobloxAvatar(uid) {
    if (!uid || uid <= 0) return null;
    try {
        console.log(`[Server] Fetching avatar for UserID: ${uid}...`);
        const url = `https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${uid}&size=420x420&format=Png&isCircular=false`;
        const response = await axios.get(url);
        if (response.data && response.data.data && response.data.data.length > 0) {
            return response.data.data[0].imageUrl;
        }
    } catch (error) {
        console.error(`[Server] Failed to fetch avatar: ${error.message}`);
    }
    return null;
}

app.post('/update-data', async (req, res) => {
    const newData = req.body;
    lastUpdateTime = Date.now();

    if (newData.userId && newData.userId !== playerData.userId) {
        const newImg = await fetchRobloxAvatar(newData.userId);
        if (newImg) playerData.avatarUrl = newImg;
    }

    playerData = {
        ...playerData,
        ...newData,
        avatarUrl: playerData.avatarUrl
    };
    res.send({ status: 'success' });
});

app.get('/get-data', (req, res) => {
    const timeDiff = Date.now() - lastUpdateTime;
    const isOnline = timeDiff < 5000;
    res.json({ ...playerData, status: isOnline ? "Online" : "Offline" });
});


app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
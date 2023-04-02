const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const socket = require('socket.io');
const cors = require('cors');

const app = express();
var server = http.createServer(app);
const io = socket(server);

const PORT = process.env.PORT | 3011;

const DB = "mongodb+srv://test:test123@cluster0.isf6mhn.mongodb.net/?retryWrites=true&w=majority";

// Routes
const adminRoutes = require('./routes/auth.js');
const documentRoutes = require('./routes/document.js');


mongoose.connect(DB).then(() => {
    console.log('Database connected');
}).catch((err) => {
    console.log(err);
});

// Middleware
app.use(express.json());
app.use(cors());
app.use(adminRoutes);
app.use(documentRoutes);


io.on('connection', (socket) => {
    console.log(`socket @ ${socket.id}`);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Connected at ${PORT}`);
});
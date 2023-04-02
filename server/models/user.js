const mongoose = require('mongoose');

// Defined Structure
const userSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    profilePic: {
        type: String,
        required: true,
    },
});

// Storage
const User = mongoose.model("User", userSchema);

module.exports = User;
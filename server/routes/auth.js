const express = require('express');
const jwt = require('jsonwebtoken');

// Relative imports
const User = require('../models/user.js');
const auth = require('../middlewares/auth.js');

// Initializations
const router = express.Router();

// router.get('/', (req, res) => {
//     console.log('Get Method');
// });

router.post('/api/signup', async (req, res) => {
    try {
        const { name, email, profilePic } = req.body;

        // Check if User already exists in Database
        let user = await User.findOne({ email: email }); // model: destructured

        // user == null
        if (!user) {
            user = new User({
                email: email,
                name: name,
                profilePic: profilePic,
            });

            user = await user.save();
        }

        const token = jwt.sign({ id: user._id }, "passwordKey");

        // If the user already exists, do nothing

        res.json({ user: user, token: token });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get("/", auth, async (req, res) => {
    const user = await User.findById(req.user);
    res.json({ user, token: req.token });
});

// Exports
module.exports = router;
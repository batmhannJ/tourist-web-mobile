const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../model/user");
const authRouter = express.Router();
const jwt = require('jsonwebtoken');

// Sign up
authRouter.post("/api/signup", async (req, res) => {
    try {
        const { name, email, password } = req.body;

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ msg: "Email already exists!" });
        }

        const hashedPassword = await bcryptjs.hash(password, 8);
        let user = new User({ email, password: hashedPassword, name });
        user = await user.save();
        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Login
authRouter.post("/api/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ msg: "Email does not exist!" });
        }

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: "Incorrect password." });
        }

        const token = jwt.sign({ id: user._id }, "passwordKey");
        res.json({ token, ...user._doc });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Update user details
authRouter.put("/api/update-user", async (req, res) => {
    const { name, email, password } = req.body;

    try {
        const token = req.headers.authorization.split(" ")[1]; // Extract token from headers
        const decoded = jwt.verify(token, "passwordKey"); // Verify token
        const userId = decoded.id; // Get user ID from token

        // Find user by ID and update
        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { 
                name, 
                email, 
                password: password ? await bcryptjs.hash(password, 8) : undefined 
            },
            { new: true } // Return the updated user
        );

        if (!updatedUser) {
            return res.status(404).json({ msg: "User not found!" });
        }

        res.json(updatedUser);
    } catch (error) {
        console.error("Error updating user:", error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = authRouter;
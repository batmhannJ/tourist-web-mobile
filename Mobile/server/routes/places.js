const express = require("express");
const collection2 = require("../model/place"); // Import your collection model
const router = express.Router();

// GET endpoint to retrieve all places
router.get("/places", async (req, res) => {
    try {
        const places = await collection2.find(); // Fetch all places from MongoDB
        res.json(places); // Send the places as a JSON response
    } catch (error) {
        console.error("Error fetching places:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

module.exports = router;

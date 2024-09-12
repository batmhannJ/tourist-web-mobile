// routes/markers.js

const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");

// Replace this with your schema or the format of your data
const markerSchema = new mongoose.Schema({
  destinationName: String,
  latitude: Number,
  longitude: Number,
  description: String,
  destinationType: String
});

const Marker = mongoose.model("locationcollections", markerSchema);

// Route to get markers
router.get("/markers", async (req, res) => {
  try {
    const markers = await Marker.find({});
    res.json(markers);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;

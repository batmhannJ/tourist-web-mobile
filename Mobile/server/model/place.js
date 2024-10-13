const mongoose = require("mongoose")
mongoose.connect("mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test")
.then(()=>{
    console.log("mongodb connected")
})
.catch(()=>{
    console.log("failed")
})

const placeSchema = new mongoose.Schema({
  city: {
    type: String,
    required: true,
  },
  destinationName: {
    type: String,
    required: true,
  },
  latitude: {
    type: Number,
    required: true,
  },
  longitude: {
    type: Number,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  destinationType: {
    type: String,
    default: 'local',
  },
  image: {
    type: String,
  }
});

// Check if the model already exists before creating it
const collection2 = mongoose.models.locationcollections || mongoose.model('locationcollections', placeSchema);

module.exports = collection2;
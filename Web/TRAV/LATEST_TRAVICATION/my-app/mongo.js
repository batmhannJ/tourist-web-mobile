const mongoose = require("mongoose")
mongoose.connect("mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test")
.then(()=>{
    console.log("mongodb connected")
})
.catch(()=>{
    console.log("failed")
})


const newSchema = new mongoose.Schema({
    name: {
        type: String, 
        required: true
    },
    email:{
        type: String,
        required: true,
        unique: true
    },
    password:{
        type: String,
        required: true
    },
    role:{
        type: String,
        default: 'manager'
    }
    ,
    status:{
        type: String,
        required: true,
        default: 'pending'
    }
})

const collection = mongoose.model("accounts", newSchema)

const locationSchema = new mongoose.Schema({
    city: {
        type: String, 
        required: true
    },
    destinationName: {
        type: String, 
        required: true
    },
    latitude:{
        type: Number,
        required: true
    },
    longitude:{
        type: Number,
        required: true
    },
    description:{
        type: String,
        required: true,
    },
    destinationType:{
        type: String,
        required: true,
        default: 'local'
    },
    image: {
        type: String,  // Stores the file path or URL of the image
        required: false
    },
    dateAdded: { type: Date, default: Date.now } // Add this field
});

const collection2 = mongoose.model("locationcollection", locationSchema)

const searchSchema = new mongoose.Schema({
    destinationName: String,
    count: { type: Number, default: 0 }
});

const Search = mongoose.model('Search', searchSchema);

const otpSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    otp: { type: String, required: true },
    createdAt: { type: Date, default: Date.now, expires: '10m' } // OTP expires in 10 minutes
  });
  

const Otp = mongoose.model('Otp', otpSchema);

const markerSchema = new mongoose.Schema({
    destinationName: String,
    latitude: Number,
    longitude: Number,
    description: String,
    destinationType: String
  });
  
  const Marker = mongoose.model("locationcollections", markerSchema);

module.exports = { collection, collection2, Search, Otp, Marker};

const express = require("express");
const mongoose = require("mongoose");
const cors = require('cors');
const bodyParser = require('body-parser');
const authRouter = require("./routes/auth");
const markersRouter = require("./routes/markers");
const placesRouter = require("./routes/places"); // Import the places router
const Otp = require('./model/otp');
const collection2 = require('./model/place');
const nodemailer = require('nodemailer');
const User = require('./model/user');
const bcryptjs = require('bcryptjs');
const saltRounds = 10;
const PORT = process.env.PORT || 3000;
const app = express();
const axios = require('axios');
const corsAnywhere = require('cors-anywhere');
const { prototype } = require("jsonwebtoken/lib/NotBeforeError");
const port = 8080;
const path = require('path');



app.use(cors());
app.use(bodyParser.json());
app.use(cors({ origin: true, credentials: true }));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(authRouter);
app.use("/api", markersRouter);
app.use("/api", placesRouter);
app.use('/uploads', (req, res, next) => {
    console.log(`Requesting: ${req.path}`);
    next();
  }, express.static(path.join(__dirname, 'uploads')));
  
  app.use(express.static('uploads')); 

mongoose.connect("mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test")
    .then(() => console.log("MongoDB connected"))
    .catch(err => console.log(err));

// Nodemailer transporter setup
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'travications@gmail.com',
        pass: 'gkvd dcii empd ekzr' 
    },
    tls: {
        rejectUnauthorized: false
    }
});
corsAnywhere.createServer({
    originWhitelist: [],
  }).listen(port, () => {
    console.log(`CORS Anywhere running on port ${port}`);
  });

  app.get('/proxy-image', async (req, res) => {
    const imageUrl = req.query.url;
    try {
      const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
      res.set('Content-Type', 'image/png');
      res.send(response.data);
    } catch (error) {
      res.status(500).send('Error fetching the image');
    }
  });
  
app.post('/send-email', async (req, res) => {
    const { to } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    await Otp.findOneAndUpdate(
        { email: to },
        { otp, createdAt: new Date() },
        { upsert: true }
    );

    const mailOptions = {
        from: 'travications@gmail.com',
        to: to,
        subject: 'Your OTP Code',
        text: `Your OTP is ${otp}. It is valid for 5 minutes.`
    };

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            return res.status(500).send('Error sending email: ' + error.toString());
        }
        res.status(200).send('OTP sent successfully');
    });
});

app.post('/api/verify-otp', async (req, res) => {
    const { email, otp } = req.body;

    try {
        const otpRecord = await Otp.findOne({ email });

        if (!otpRecord) {
            return res.status(400).json({ success: false, message: 'OTP not found' });
        }

        if (otpRecord.otp !== otp) {
            return res.status(400).json({ success: false, message: 'Invalid OTP' });
        }

        const now = new Date();
        if (now - otpRecord.createdAt > 5 * 60 * 1000) { // 5 minutes expiration
            return res.status(400).json({ success: false, message: 'OTP expired' });
        }

        res.json({ success: true });
    } catch (error) {
        console.error('Error verifying OTP:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

app.post('/api/reset-password', async (req, res) => {
    const { email, newPassword } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }


        user.password = await bcryptjs.hash(newPassword, saltRounds);
        await user.save();

        res.status(200).json({ message: 'Password reset successful' });
    } catch (error) {
        console.error('Failed to reset password:', error);
        res.status(500).json({ message: 'Failed to reset password' });
    }
});

const API_KEY = 'AIzaSyBEcu_p865o6zGHCcA9oDlKl04xeFCBaIs';
app.get('/directions', async (req, res) => {
    const { origin, destination } = req.query;
    const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=driving&key=${API_KEY}`;

    try {
        const response = await axios.get(url);
        res.json(response.data);
    } catch (error) {
        console.error(error);
        res.status(500).send('Error fetching directions');
    }
});

async function fetchThumbnailFromDBpedia(searchTerm) {
    const query = encodeURIComponent(searchTerm);
    const dbpediaUrl = `http://dbpedia.org/sparql?query=SELECT%20?thumbnail%20WHERE%20{?s%20rdfs:label%20"${query}"@en.%20?s%20dbo:thumbnail%20?thumbnail.}`;

    try {
        const response = await axios.get(dbpediaUrl);
        const results = response.data.results.bindings;

        if (results.length > 0) {
            return results[0].thumbnail.value; 
        }
    } catch (error) {
        console.error('Error fetching thumbnail from DBpedia:', error);
    }

    return null;
}

app.get('/searchTouristSpots', async (req, res) => {
    try {
      const query = req.query.query.toLowerCase(); // Get the query parameter
  
      // Fetch tourist spots that match the search query
      const spots = await collection2.find({
        destionationName: { $regex: query, $options: 'i' }, // Case-insensitive search
        city: { $regex: query, $options: 'i' }, // Case-insensitive search
      });
  
      // Respond with the found spots
      res.json(spots);
    } catch (error) {
      console.error('Error fetching tourist spots:', error);
      res.status(500).json({ error: 'Failed to load tourist spots' });
    }
  });

app.post('/logSearch', async (req, res) => {
    const { searchTerm } = req.body;

    try {
        const thumbnailUrl = await fetchThumbnailFromDBpedia(searchTerm);
        let searchEntry = await Search.findOne({ title: searchTerm });

        if (searchEntry) {
            searchEntry.count += 1;
        } else {
            searchEntry = new Search({
                title: searchTerm,
                image: thumbnailUrl || '/images/tagtay.jpg',
                count: 1
            });
        }

        await searchEntry.save();

        res.status(200).json({ message: 'Search term logged successfully.' });
    } catch (error) {
        console.error('Error logging search term:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

const searchSchema = new mongoose.Schema({
    title: String,
    image: String,
    count: { type: Number, default: 0 }
});

const Search = mongoose.model('Search', searchSchema);

app.get('/mostSearched', async (req, res) => {
    try {
        const mostSearched = await Search.find().sort({ count: -1 }).limit(10);
        res.status(200).json(mostSearched);
    } catch (error) {
        console.error('Error fetching most searched categories:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

//app.use('/uploads', express.static('uploads'));

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});

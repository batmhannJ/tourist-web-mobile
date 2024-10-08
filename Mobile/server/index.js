const express = require("express");
const mongoose = require("mongoose");
const cors = require('cors');
const bodyParser = require('body-parser');
const authRouter = require("./routes/auth");
const markersRouter = require("./routes/markers");
const Otp = require('./model/otp');
const nodemailer = require('nodemailer');
const User = require('./model/user'); // Adjust the path as necessary
const bcrypt = require('bcrypt');
const saltRounds = 10; // para sa bcrypt encryption
const PORT = process.env.PORT || 3000;
const app = express();
const axios = require('axios'); // I-import ang axios dito\
const corsAnywhere = require('cors-anywhere');
const { prototype } = require("jsonwebtoken/lib/NotBeforeError");
const port = 8080; // o anumang ibang port na hindi ginagamit


app.use(cors());
app.use(bodyParser.json());
app.use(cors({ origin: true, credentials: true }));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(authRouter);
app.use("/api", markersRouter);

mongoose.connect("mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test")
    .then(() => console.log("MongoDB connected"))
    .catch(err => console.log(err));

// Nodemailer transporter setup
const transporter = nodemailer.createTransport({
    service: 'gmail', // or another email service provider
    auth: {
        user: 'reyeshannahjoy82@gmail.com',
        pass: 'cnoy eucq dvka vrlt' // Use environment variables for sensitive data
    },
    tls: {
        rejectUnauthorized: false
    }
});
corsAnywhere.createServer({
    // Pinapayagan ang lahat ng origin
    originWhitelist: [], // ['http://localhost:57191'] kung nais mong limitahan
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
  
// Route para mag-send ng OTP
app.post('/send-email', async (req, res) => {
    const { to } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Save OTP sa database
    await Otp.findOneAndUpdate(
        { email: to },
        { otp, createdAt: new Date() },
        { upsert: true }
    );

    // Setup ng email options
    const mailOptions = {
        from: 'reyeshannahjoy82@gmail.com',
        to: to,
        subject: 'Your OTP Code',
        text: `Your OTP is ${otp}. It is valid for 5 minutes.`
    };

    // Send ng OTP email
    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            return res.status(500).send('Error sending email: ' + error.toString());
        }
        res.status(200).send('OTP sent successfully');
    });
});

// Route para i-verify ang OTP
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

        // Check kung expired na ang OTP
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

// Route para i-reset ang password
app.post('/api/reset-password', async (req, res) => {
    const { email, newPassword } = req.body;

    try {
        // Hanapin ang user gamit ang email
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // I-encrypt ang bagong password
        user.password = await bcrypt.hash(newPassword, saltRounds);
        await user.save();

        res.status(200).json({ message: 'Password reset successful' });
    } catch (error) {
        console.error('Failed to reset password:', error);
        res.status(500).json({ message: 'Failed to reset password' });
    }
});

// In-memory storage for simplicity
async function fetchThumbnailFromDBpedia(searchTerm) {
    const query = encodeURIComponent(searchTerm);
    const dbpediaUrl = `http://dbpedia.org/sparql?query=SELECT%20?thumbnail%20WHERE%20{?s%20rdfs:label%20"${query}"@en.%20?s%20dbo:thumbnail%20?thumbnail.}`;

    try {
        const response = await axios.get(dbpediaUrl);
        const results = response.data.results.bindings;

        if (results.length > 0) {
            return results[0].thumbnail.value;  // Return the first thumbnail URL found
        }
    } catch (error) {
        console.error('Error fetching thumbnail from DBpedia:', error);
    }

    return null;  // Return null if no thumbnail found
}

app.post('/logSearch', async (req, res) => {
    const { searchTerm } = req.body;

    try {
        // Find the search term in the database
        const thumbnailUrl = await fetchThumbnailFromDBpedia(searchTerm);
        let searchEntry = await Search.findOne({ title: searchTerm });

        if (searchEntry) {
            // If it exists, increment the count
            searchEntry.count += 1;
        } else {
            // If it doesn't exist, create a new entry
            searchEntry = new Search({
                title: searchTerm,
                image: thumbnailUrl || '/images/tagtay.jpg', // Set a default image URL or customize it
                count: 1
            });
        }

        // Save the updated or new entry
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

// Endpoint to fetch most searched categories
app.get('/mostSearched', async (req, res) => {
    try {
        const mostSearched = await Search.find().sort({ count: -1 }).limit(10); // Fetch top 10 most searched
        res.status(200).json(mostSearched);
    } catch (error) {
        console.error('Error fetching most searched categories:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});

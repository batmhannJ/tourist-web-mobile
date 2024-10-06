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

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});

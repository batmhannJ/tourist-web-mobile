const express = require("express");
const mongoose = require("mongoose");
const cors = require('cors');
const bodyParser = require('body-parser');
const Otp = require('./models/otp');

const PORT = process.env.PORT || 3000;
const app = express();

app.use(cors());
app.use(bodyParser.json());

mongoose.connect("mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test")
    .then(() => console.log("MongoDB connected"))
    .catch(err => console.log(err));

app.post('/send-email', async (req, res) => {
    const { to } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Save OTP to database
    await Otp.findOneAndUpdate(
        { email: to },
        { otp, createdAt: new Date() },
        { upsert: true }
    );

    // Setup email options
    const mailOptions = {
        from: 'reyeshannahjoy82@gmail.com',
        to: to,
        subject: 'Your OTP Code',
        text: `Your OTP is ${otp}. It is valid for 5 minutes.`
    };

    // Send the email with OTP
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

        // Check if OTP is expired
        const now = new Date();
        if (now - otpRecord.createdAt > 10 * 60 * 1000) { // 10 minutes
            return res.status(400).json({ success: false, message: 'OTP expired' });
        }

        res.json({ success: true });
    } catch (error) {
        console.error('Error verifying OTP:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});

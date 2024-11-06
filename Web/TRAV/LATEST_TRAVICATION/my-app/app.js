const express = require("express")
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
const jwtSecret = 'pC4l7f9H2a7Y1dC9Uk1ZjX6D8ErO23Dk5FxR7e0vF0O=';
const session = require('express-session')
const MongoStore = require('connect-mongo')
const { collection, collection2, Search, Otp, Marker, User } = require("./mongo");
const nodemailer = require('nodemailer');
const multer = require('multer'); // Import multer
const path = require('path');


const cors = require("cors");
const { Collection } = require("mongoose");
const allowedOrigins = ['http://localhost:3000', 'http://localhost:42284', 'http://localhost:43264', 'http://localhost:43264','https://travication.vercel.app', 'https://travications.onrender.com', 'https://travication.vercel.app/api/check-session']; // Add all allowed origins
require('dotenv').config();
const app = express()
const PORT = process.env.PORT || 4000

app.use(express.json())
app.use(express.urlencoded({extended: true}))
app.use(cors({
    origin: function (origin, callback) {
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true // Allow credentials to be included in the request
}));

app.use(session({
    secret: 'yourSecretKey',
    resave: false,
    saveUninitialized: true,
    store: MongoStore.create({
        mongoUrl: 'mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test'
    }),
    cookie: {
        //secure: process.env.NODE_ENV === 'production', // Gawing true kapag sa production
        //httpOnly: true, // Tinatanggal ang access sa cookie mula sa JavaScript
        //secure: false,
        //sameSite: 'lax',  // Consider using 'lax' or 'none' in cross-origin scenarios
        maxAge: 1000 * 60 * 60 // 1 oras, baguhin ayon sa iyong pangangailangan
    } // 3 hours
}));


app.get('/check-session', (req, res) => {
    console.log(req.session); // Log session details

    if (req.session.user) {
        return res.json({ user: req.session.user });
    }
    res.status(401).json({ message: 'Not authenticated' });
});

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'travications@gmail.com', 
        pass: 'gkvd dcii empd ekzr', 
    },
    tls: {
        rejectUnauthorized: false, // Disables strict SSL, bypassing self-signed certificates
    },
});

const sendVerificationEmail = (email, token) => {
    const mailOptions = {
        from: 'travications@gmail.com',
        to: email,
        subject: 'Password Reset Verification Token',
        text: `Your password reset token is: ${token}`,
    };

    return new Promise((resolve, reject) => {
        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Error sending email: ', error.message);
                reject(error);
            } else {
                console.log('Email sent: ' + info.response);
                resolve(info);
            }
        });
    });
};

const generateToken = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

app.post('/forgotpassword', async (req, res) => {
    const { email } = req.body;

    try {
        const user = await collection.findOne({ email: email });
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const token = generateToken(); 
        await sendVerificationEmail(email, token); 

        res.status(200).send('Reset token sent successfully');
    } catch (error) {
        console.error('Error sending reset token:', error);
        res.status(500).send('Error sending reset token.');
    }
});

app.patch("/forgotpassword", async (req, res) => {
    const { email, password } = req.body;

    try {
        const hashedPassword = await bcryptjs.hash(password, 10);
        const updatedPassword = await collection.findOneAndUpdate(
            { email: email },
            { password: hashedPassword },
            { new: true }
        );

        if (!updatedPassword) {
            return res.status(404).json({ error: "User not found" });
        }

        res.status(200).json(updatedPassword);
    } catch (e) {
        console.error("Password update error:", e);
        res.status(500).json({ error: "Password update error" });
    }
});

app.get("/login", cors(), (req, res)=>{

})

app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    try {
        let user = await collection.findOne({ email: email });

        if (!user) {
            return res.status(400).json({ error: 'The specified user cannot be found.' });
        }

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'The entered username or password does not match our records.' });
        }

        if (user.role === 'admin') {
            req.session.userId = user._id;
            req.session.role = user.role;
            req.session.user = user;
            return res.json("admin exist");
        } else {
            if (user.status === 'decline') {
                return res.status(403).json({ error: 'Access has been declined for this user login attempt.' });
            } else if (user.status === 'approved') {
                req.session.userId = user._id;
                req.session.role = user.role;
                req.session.user = user;
                return res.json("exist");
            } else {
                return res.status(403).json({ error: 'The user account has not been activated pending approval.' });
            }
        }
    } catch (e) {
        console.error("Login error:", e);
        res.status(500).json({ error: "Server error" });
    }
});



app.post('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) {
            return res.status(500).json({ message: 'Logout error' })
        }
        res.status(200).json({ message: 'Logout successful' })
    })
})

app.post("/signupdata", async(req, res)=>{
    const{name, email, password} = req.body


    try {
        const salt = await bcryptjs.genSalt(10);
        const hashedPassword = await bcryptjs.hash(password, salt);
            const data = {
                name: name,
                email:email,
                password:hashedPassword
    }
        const check = await collection.findOne({email:email})

        if (check){
            res.json("exist")
        } else{
            res.json("not exist")
            await collection.insertMany([data])
        }
    }
    catch(e){
        res.json("not exist")
    }

})

app.post("/addmanager", async(req, res)=>{
    const{name, email, password, role} = req.body

    try{ 
        const salt = await bcryptjs.genSalt(10);
        const hashedPassword = await bcryptjs.hash(password, salt);
            const data = {
                name: name,
                email: email,
                password: hashedPassword,
                role: role
    };
        await collection.insertMany([data])
    }
    catch(e){
        res.json("manager insert error")
    }
})

app.get("/getmanagers", async(req, res) => {
    try {
        const managers = await collection.find({role: 'manager'});
        res.json(managers);
    } catch (e) {
        res.status(500).json({ error: "Manager retrieval error" });
    }
});

app.delete("/deletemanager/:id", async(req, res) => {

    

    const {id} = req.params;
    try {
        await collection.findByIdAndDelete(id);
        
        res.status(200).json({ message: "Manager deleted successfully" });
   
    } catch (e) {
        res.status(500).json({ error: "Manager deletion error" });
    }
});

app.patch("/editmanager/:id", async(req, res) => {
    const {id} = req.params;
    const { name, email, password } = req.body;

    try {
        // Create the data object with updated fields
        const data = { 
            name: name,
            email: email,
            password: password
        };

        // Find the manager by ID and update it with the new data
        const updatedManager = await collection.findByIdAndUpdate(id, data);

        // Send the updated manager data in the response
        res.status(200).json(updatedManager);
    }
    
    catch (e) {
        res.status(500).json({ error: "Manager edit error" });
    }
});

app.patch("/approvemanager/:id",  async (req, res) => {
    const { id } = req.params;

    try {
        const data = {
            status: 'approved' 
        };

        const updatedManager = await collection.findByIdAndUpdate(id, data, { new: true });


        res.status(200).json(updatedManager);
    } catch (e) {
        console.error("Manager approval error:", e);
        res.status(500).json({ error: "Manager approval error" });
    }
});

app.patch("/declinemanager/:id",  async (req, res) => {
    const { id } = req.params;

    try {
        const data = {
            status: 'decline' 
        };

        const updatedManager = await collection.findByIdAndUpdate(id, data, { new: true });


        res.status(200).json(updatedManager);
    } catch (e) {
        console.error("Manager approval error:", e);
        res.status(500).json({ error: "Manager approval error" });
    }
}); 

const storage = multer.diskStorage({
    destination: './uploads/', // Folder where uploaded files will be saved
    filename: (req, file, cb) => {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});

// Create the upload instance with the storage configuration
const upload = multer({
    storage: storage,
    limits: { fileSize: 1000000 }, // Limit file size to 1MB
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png|gif/; // Allowed file types
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb('Error: Images only!'); // Callback with error if file type is invalid
        }
    }
});
// Route to handle image upload and save location data
app.post('/locations', (req, res) => {
    upload(req, res, (err) => {
        if (err) {
            res.status(400).send(err);
        } else {
            const { city, destinationName, latitude, longitude, description, destinationType } = req.body;
            const newLocation = new collection2({
                city,
                destinationName,
                latitude,
                longitude,
                description,
                destinationType,
                image: req.file ? `/uploads/${req.file.filename}` : ''  // Store the image file path
            });

            newLocation.save()
                .then(() => res.status(200).json({ message: 'Location added successfully', newLocation }))
                .catch(error => res.status(400).json({ error }));
        }
    });
});

// Serve uploaded images
app.use('/uploads', express.static('uploads'));

// Add location route with image upload
app.post('/addlocation', upload.single('image'), (req, res) => {
    const { city, destinationName, latitude, longitude, description } = req.body;
    const imagePath = req.file ? req.file.path.replace(/\\/g, '/') : ''; // Normalize path

    // Save the location and image path to the database
    // Example: save to MongoDB with mongoose
    const newLocation = new collection2({
        city,
        destinationName,
        latitude,
        longitude,
        description,
        image: imagePath// Store image path
    });

    newLocation.save()
        .then(() => res.json({ message: 'Location added successfully' }))
        .catch(err => res.status(500).json({ error: 'Error adding location' }));
});

app.get("/getlocation", async(req, res) => {
    try {
        const locations = await collection2.find({destinationType: 'local'});
        res.json(locations);
    } catch (e) {
        res.status(500).json({ error: "Manager retrieval error" });
    }
});

app.delete("/deletelocation/:id", async (req, res) => { // Correct route
    const { id } = req.params;

    try {
        await collection2.findByIdAndDelete(id);
        res.status(200).json({ message: "Location deleted successfully" });
    } catch (error) {
        console.error("Error deleting location:", error);
        // Send an error response
        res.status(500).json({ error: "Location delete error" });
    }
});

app.patch("/editlocation/:id", upload.single('image'), async (req, res) => {
    const { id } = req.params;
    const { city, destinationName, latitude, longitude, description } = req.body;

    // Create the data object with updated fields
    const data = { 
        city,
        destinationName,
        latitude,
        longitude,
        description,
        image: req.file ? req.file.path : undefined // Only include image if it's uploaded
    };

    try {
        // Find the location by ID and update it with the new data
        const updatedLocation = await collection2.findByIdAndUpdate(id, data, { new: true });
        res.status(200).json(updatedLocation);
    } catch (e) {
        console.error("Error updating location:", e);
        res.status(500).json({ error: "Manager edit error" });
    }
});

app.get('/getMostSearchedDestinations', async (req, res) => {
    try {
        // Fetch the top 5 most searched destinations, sorted by the `count` field in descending order
        const mostSearchedDestinations = await Search.find().sort({ count: -1 }).limit(5);
        console.log(mostSearchedDestinations); // Debugging the data
        res.status(200).json(mostSearchedDestinations);
    } catch (error) {
        console.error('Error fetching most searched destinations:', error);
        res.status(500).json({ message: 'Failed to fetch most searched destinations.' });
    }
});

const otpStore = {};

// Function to send the OTP email
const sendOTPEmail = async (email, otp) => {
    const mailOptions = {
        from: 'travications@gmail.com',
        to: email,
        subject: 'Your OTP for Login',
        text: `Your OTP is: ${otp}. It is valid for 5 minutes.`,
    };

    return new Promise((resolve, reject) => {
        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Error sending email: ', error.message);
                reject(error);
            } else {
                console.log('Email sent: ' + info.response);
                resolve(info);
            }
        });
    });
};

// Endpoint to request OTP
app.post("/send-otp", async (req, res) => {
    const { email } = req.body;

    try {
        const user = await collection.findOne({ email: email });
        if (!user) {
            return res.status(400).json({ error: 'User does not exist' });
        }

        const otp = generateToken(); // Assuming generateToken() generates a valid OTP
        otpStore[email] = { otp, expires: Date.now() + 300000 }; // Store OTP with expiration time (5 mins)

        await sendOTPEmail(email, otp); // Send the OTP to user's email
        return res.status(200).json({ success: true, message: 'OTP sent to your email.' }); // Return success response
    } catch (e) {
        console.error("OTP request error:", e);
        return res.status(500).json({ success: false, error: "Server error" }); // Improved error handling
    }
});

// Endpoint to verify OTP and log in the user
app.post("/verify-otp", async (req, res) => {
    const { email, otp } = req.body;

    const otpData = otpStore[email];
    if (!otpData || otpData.otp !== otp) {
        return res.status(400).json({ success: false, error: 'Invalid OTP or OTP expired' });
    }

    if (Date.now() > otpData.expires) {
        delete otpStore[email]; // Remove OTP if expired
        return res.status(400).json({ success: false, error: 'OTP expired' });
    }

    delete otpStore[email]; // Remove OTP after successful verification

    try {
        let user = await collection.findOne({ email: email });

        if (!user) {
            return res.status(400).json({ success: false, error: 'User does not exist' });
        }

        // Log in the user
        req.session.userId = user._id;
        req.session.role = user.role;
        req.session.user = user;

        return res.json({ success: true, message: "Logged in successfully." }); // Return success response
    } catch (e) {
        console.error("Login error:", e);
        return res.status(500).json({ success: false, error: "Server error" }); // Improved error handling
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
        const user = await collection.findOne({ email });

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


  
app.post("/api/signup", async (req, res) => {
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
app.post("/api/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await collection.findOne({ email });
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
app.put("/api/update-user", async (req, res) => {
    const { name, email, password } = req.body;

    try {
        const token = req.headers.authorization.split(" ")[1]; // Extract token from headers
        const decoded = jwt.verify(token, "passwordKey"); // Verify token
        const userId = decoded.id; // Get user ID from token

        // Find user by ID and update
        const updatedUser = await collection.findByIdAndUpdate(
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

app.get("/markers", async (req, res) => {
    try {
      const markers = await Marker.find({});
      res.json(markers);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  });

  app.get("/places", async (req, res) => {
    try {
        const places = await collection2.find(); // Fetch all places from MongoDB
        res.json(places); // Send the places as a JSON response
    } catch (error) {
        console.error("Error fetching places:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

app.listen(4000, ()=>{
    console.log("port connected")
})
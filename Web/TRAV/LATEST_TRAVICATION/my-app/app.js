const express = require("express");
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const jwtSecret = 'pC4l7f9H2a7Y1dC9Uk1ZjX6D8ErO23Dk5FxR7e0vF0O=';
const session = require('express-session');
const MongoStore = require('connect-mongo');
const { collection, collection2 } = require("./mongo");
const nodemailer = require('nodemailer');
const cors = require("cors");
const app = express();
const PORT = process.env.PORT || 4000;
const maxAttempts = 5;
const lockoutDuration = 2 * 60 * 1000;

let loginAttempts = {};

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
    origin: 'http://localhost:4000',
    credentials: true
}));

app.use(session({
    secret: 'yourSecretKey',
    resave: false,
    saveUninitialized: true,
    store: MongoStore.create({
        mongoUrl: 'mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test'
    }),
    cookie: { maxAge: 180 * 60 * 1000 }
}));

app.get('/check-session', (req, res) => {
    if (req.session.user) {
        return res.json({ user: req.session.user });
    }
    res.status(401).json({ message: 'Not authenticated' });
});

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'olshco.electionupdates@gmail.com',
        pass: 'nxgb fqoh qkxk svjs',
    },
});

const sendVerificationEmail = (email, token) => {
    const mailOptions = {
        from: 'olshco.electionupdates@gmail.com',
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
        const hashedPassword = await bcrypt.hash(password, 10);
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

app.get("/login", cors(), (req, res) => {});

app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    // Check if the user is locked out
    if (loginAttempts[email] && loginAttempts[email].attempts >= maxAttempts) {
        const timeElapsed = Date.now() - loginAttempts[email].time;
        if (timeElapsed < lockoutDuration) {
            return res.status(403).json({ error: "Too many login attempts. Please try again later.", lockout: true });
        } else {
            // Reset attempts if lockout period has passed
            loginAttempts[email] = { attempts: 0, time: null };
        }
    }

    try {
        let user = await collection.findOne({ email: email });

        if (!user) {
            return res.status(400).json({ error: 'User does not exist' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            // Increment login attempts if the password is incorrect
            if (!loginAttempts[email]) {
                loginAttempts[email] = { attempts: 1, time: Date.now() };
            } else {
                loginAttempts[email].attempts++;
            }

            return res.status(400).json({ error: 'Invalid username or password', attemptsLeft: maxAttempts - loginAttempts[email].attempts });
        }

        // On successful login, reset attempts
        delete loginAttempts[email];

        if (user.role === 'admin') {
            req.session.userId = user._id;
            req.session.role = user.role;
            req.session.user = user;
            return res.json("admin exist");
        } else {
            if (user.status === 'decline') {
                return res.status(403).json({ error: 'User login declined' });
            } else if (user.status === 'approved') {
                req.session.userId = user._id;
                req.session.role = user.role;
                req.session.user = user;
                return res.json("exist");
            } else {
                return res.status(403).json({ error: 'User not approved yet' });
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
            return res.status(500).json({ message: 'Logout error' });
        }
        res.status(200).json({ message: 'Logout successful' });
    });
});

app.post("/signupdata", async (req, res) => {
    const { name, email, password } = req.body;

    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        const data = {
            name: name,
            email: email,
            password: hashedPassword
        };
        const check = await collection.findOne({ email: email });

        if (check) {
            res.json("exist");
        } else {
            res.json("not exist");
            await collection.insertMany([data]);
        }
    } catch (e) {
        res.json("not exist");
    }
});

app.post("/addmanager", async (req, res) => {
    const { name, email, password, role } = req.body;

    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        const data = {
            name: name,
            email: email,
            password: hashedPassword,
            role: role
        };
        await collection.insertMany([data]);
    } catch (e) {
        res.json("manager insert error");
    }
});

app.get("/getmanagers", async (req, res) => {
    try {
        const managers = await collection.find({ role: 'manager' });
        res.json(managers);
    } catch (e) {
        res.status(500).json({ error: "Manager retrieval error" });
    }
});

app.delete("/deletemanager/:id", async (req, res) => {
    const { id } = req.params;
    try {
        await collection.findByIdAndDelete(id);
        res.status(200).json({ message: "Manager deleted successfully" });
    } catch (e) {
        res.status(500).json({ error: "Manager deletion error" });
    }
});

app.patch("/editmanager/:id", async (req, res) => {
    const { id } = req.params;
    const { name, email, password } = req.body;

    try {
        const data = {
            name: name,
            email: email,
            password: password
        };

        const updatedManager = await collection.findByIdAndUpdate(id, data);
        res.status(200).json(updatedManager);
    } catch (e) {
        res.status(500).json({ error: "Manager edit error" });
    }
});

app.patch("/approvemanager/:id", async (req, res) => {
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

app.patch("/declinemanager/:id", async (req, res) => {
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

app.post("/addlocation", async (req, res) => {
    const { destinationName, latitude, longitude, description, destinationType } = req.body;

    const data = {
        destinationName: destinationName,
        latitude: latitude,
        longitude: longitude,
        description: description,
        destinationType: destinationType
    };
    try {
        await collection2.insertMany([data]);
    } catch (e) {
        res.json("location insert error");
    }
});

app.get("/getlocation", async (req, res) => {
    try {
        const locations = await collection2.find();
        res.json(locations);
    } catch (e) {
        res.status(500).json({ error: "Location retrieval error" });
    }
});

app.delete("/deletelocation/:id", async (req, res) => {
    const { id } = req.params;
    try {
        await collection2.findByIdAndDelete(id);
        res.status(200).json({ message: "Location deleted successfully" });
    } catch (e) {
        res.status(500).json({ error: "Location deletion error" });
    }
});

app.patch("/editlocation/:id", async (req, res) => {
    const { id } = req.params;
    const { destinationName, latitude, longitude, description, destinationType } = req.body;

    try {
        const data = {
            destinationName: destinationName,
            latitude: latitude,
            longitude: longitude,
            description: description,
            destinationType: destinationType
        };

        const updatedLocation = await collection2.findByIdAndUpdate(id, data);
        res.status(200).json(updatedLocation);
    } catch (e) {
        res.status(500).json({ error: "Location edit error" });
    }
});

app.get("/landing", (req, res) => {
    res.send("Welcome to the Landing Page!");
});

app.get("/edit-profile", (req, res) => {
    if (req.session.user) {
        res.json({ user: req.session.user });
    } else {
        res.status(401).json({ message: 'Not authenticated' });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

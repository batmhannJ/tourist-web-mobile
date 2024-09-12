const express = require("express")
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const jwtSecret = 'pC4l7f9H2a7Y1dC9Uk1ZjX6D8ErO23Dk5FxR7e0vF0O=';
const session = require('express-session')
const MongoStore = require('connect-mongo')
const { collection, collection2 } = require("./mongo");

const cors = require("cors")
const app = express()
const PORT = process.env.PORT || 4000

app.use(express.json())
app.use(express.urlencoded({extended: true}))
app.use(cors({
    origin: 'http://localhost:3000', // React app's origin
    credentials: true
}));

app.use(session({
    secret: 'yourSecretKey',
    resave: false,
    saveUninitialized: true,
    store: MongoStore.create({
        mongoUrl: 'mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test'
    }),
    cookie: { maxAge: 180 * 60 * 1000 } // 3 hours
}));

app.get('/check-session', (req, res) => {
    if (req.session.user) {
        return res.json({ user: req.session.user });
    }
    res.status(401).json({ message: 'Not authenticated' });
});


app.get("/login", cors(), (req, res)=>{

})

// app.post("/login", async (req, res) => {
//     const { email, password } = req.body;
//     console.log("Received login request:", { email, password });

//     try {
//         if (!email || !password) {
//             console.log("Missing email or password");
//             return res.status(400).json({ error: 'Email and password are required' });
//         }

//         let role;
//         if (email.includes('admin')) {
//             role = 'admin';
//         } /*else if (email.includes('manager')) {
//             role = 'manager';
//         } */else {
//             role = 'manager';
//         }

//         let user = await collection.findOne({ email: email, role: role });

//         if (!user) {
//             console.log("User not found");
//             return res.status(400).json({ error: 'User does not exist' });
//         }

//         if (role === 'admin') {
//             const isMatch = await bcrypt.compare(password, user.password);
//                 if (!isMatch) {
//                     return res.status(400).json({ error: 'Invalid Admin username or password' });
//                 }
//             req.session.userId = user._id;
//             req.session.role = user.role;
//             req.session.user = user;
//             return res.json("admin exist");
//         } else {
//             if (user.status === 'decline') {
//                 return res.status(403).json({ error: 'User login declined' });
//             }

//             if (user.status === 'approved') {
//                 const isMatch = await bcrypt.compare(password, user.password);
//                 if (!isMatch) {
//                     return res.status(400).json({ error: 'Invalid username or password' });
//                 }

//                 req.session.userId = user._id;
//                 req.session.role = user.role;
//                 req.session.user = user;
//                 return res.json("exist");
//             }
//         }
//     } catch (e) {
//         console.error("Login error:", e);
//         res.status(500).json({ error: "Internal server error" });
//     }
// });


// app.post("/login", async (req, res) => {
//     const { email, password, role } = req.body;

//     try {
//         let user = await collection.findOne({ email: email });

//         if (!user) {
//             return res.status(400).json({ error: 'User not exist' });
//         }

//         if (role === 'admin') {
//             const isMatch = await bcrypt.compare(password, user.password);
//             if (!isMatch) {
//                 return res.status(400).json({ error: 'Invalid username or password' });
//             }
//             req.session.userId = user._id;
//             req.session.role = user.role;
//             req.session.user = user;
//             return res.json("admin exist");
            
//         } else {
//             if (user.status === 'decline') {
//                 return res.status(403).json({ error: 'User login declined' });
//             }

//             if (user.status === 'approved') {
//                 const isMatch = await bcrypt.compare(password, user.password);
//                 if (!isMatch) {
//                     return res.status(400).json({ error: 'Invalid username or password' });
//                 }

//                 req.session.userId = user._id;
//                 req.session.role = user.role;
//                 req.session.user = user;
//                 return res.json("exist");
//             }
//         }
//     } catch (e) {
//         console.error("Login error:", e);
//         res.status(500).json({ error: "Please wait for status" });
//     }
// });

app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    try {
        let user = await collection.findOne({ email: email });

        if (!user) {
            return res.status(400).json({ error: 'User does not exist' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid username or password' });
        }

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
            return res.status(500).json({ message: 'Logout error' })
        }
        res.status(200).json({ message: 'Logout successful' })
    })
})

app.post("/signupdata", async(req, res)=>{
    const{name, email, password} = req.body


    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
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
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
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

app.patch("/forgotpassword", async (req, res) => {
    const { email, password } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);

        // Find the user by email and update the password
        const updatedPassword = await collection.findOneAndUpdate(
            { email: email }, // Query object to find the user by email
            { password: hashedPassword }, // Update object with the new hashed password
            { new: true } // Options object to return the updated document
        );

        if (!updatedPassword) {
            return res.status(404).json({ error: "User not found" });
        }

        // Send the updated user data in the response
        res.status(200).json(updatedPassword);
    } catch (e) {
        console.error("Password update error:", e);
        res.status(500).json({ error: "Password update error" });
    }
});


app.post("/addlocation", async(req, res)=>{

   
    const{destinationName, latitude, longitude, description, destionationType} = req.body

    const data = {
        destinationName: destinationName,
        latitude: latitude,
        longitude: longitude,
        description: description,
        destionationType: destionationType
    };
    try{ 
        await collection2.insertMany([data])
        

    }
    catch(e){
        res.json("location insert error")
    }
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


app.patch("/editlocation/:id", async(req, res) => {
    const {id} = req.params;
    const { destinationName, latitude, longitude, description } = req.body;

    try {
        // Create the data object with updated fields
        const data = { 
            destinationName: destinationName,  
            latitude: latitude,
            longitude: longitude,
            description: description
        };

        // Find the manager by ID and update it with the new data
        const updatedLocation = await collection2.findByIdAndUpdate(id, data);

        // Send the updated manager data in the response
        res.status(200).json(updatedLocation);
    }
    
    catch (e) {
        res.status(500).json({ error: "Manager edit error" });
    }
});

app.listen(4000, ()=>{
    console.log("port connected")
})
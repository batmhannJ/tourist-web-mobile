const express = require ("express");
const mongoose = require("mongoose");
const cors = require('cors');
const authRouter = require("./routes/auth");
const markersRouter = require("./routes/markers");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(cors());
app.use(cors({origin:true, credentials:true}))

app.use(express.json());
app.use(express.urlencoded({extended: true}))
app.use(authRouter);
app.use("/api", markersRouter);

const DB = "mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test";

mongoose
    .connect(DB)
    .then(() =>{
        console.log("Connection Successful")
    })
    .catch((e) =>{
        console.log(e);
    });

app.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`);
});
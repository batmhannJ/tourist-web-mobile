const mongoose = require("mongoose");

const userSchema = mongoose.Schema({
    name: {
        type: String, 
        required: true,
        trim: true,
    },
    email:{
        type: String,
        required: true,
        trim: true,
        validate: {
            validator: (value) => {
                const re =
                /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
                return value.match(re);
            },
            message: "Please enter a valid email address", 
        },
    },
    password:{
        type: String,
        required: true
    },
    role:{
        type: String,
        required: true,
        default: 'tourist'
    }
});

const User = mongoose.model("accounts", userSchema);
module.exports = User;
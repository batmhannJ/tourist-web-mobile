import React, { useState } from "react";
import logo from '../assets/logo.png';
import user_icon from '../assets/person.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import "./SignUpData.css"; // Import the CSS file
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import Carousel from './Carousel';

function SignUpData() {
    const [action, setAction] = useState("Signup");
    const history = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [name, setName] = useState('');

    // Validate email
    const isEmailValid = (email) => {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Check for "@" and "."
        return regex.test(email);
    };

    // Validate password
    const isPasswordValid = (password) => {
        const regex = /^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/; // At least 8 chars, 1 uppercase, 1 number, 1 special char
        return regex.test(password);
    };

    async function submit(e) {
        e.preventDefault();

        // Validate inputs
        if (!isEmailValid(email)) {
            alert("Please ensure that you enter a valid email address.");
            return;
        }

        if (!isPasswordValid(password)) {
            alert("Password must be at least 8 characters long and include uppercase letter, number, and special character.");
            return;
        }

        try {
            await axios.post("https://travication-backend.onrender.com/signupdata", {
                name, email, password
            })
            .then(res => {
                if (res.data === "exist") {
                    alert("The account associated with this user already exists.");
                } else if (res.data === "not exist") {
                    alert("The account has been created successfully.");
                    history("/login", { state: { id: email } });
                }
            })
            .catch(e => {
                alert("Incorrect information provided. Please try again.");
                console.log(e);
            });
        } catch (e) {
            console.log(e);
        }
    }

    return (
        <div className="sign-page">
        <Carousel />
        <div className="header-container">
        <img src={logo} alt="Logo" className="logo" />
        <div className="header-text">
            <div className="main-title">First Choice</div>
            <div className="sub-title">Travel Hub INC</div>
        </div>
        </div>
            <div className="    login-container">
                <div className="header">
                    <div className="text">{action}</div>
                    <div className="underline"></div>
                </div>
                
                <form onSubmit={submit}>

                <div className="input">
                        
                <img src={user_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="text"
                            onChange={(e) => setName(e.target.value)}
                            placeholder="Name"
                            required
                        />
                    </div>
                    <br />
                    <div className="input">
                        
                    <img src={email_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="email"
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Email Address"
                            required
                        />
                    </div>
                    <br />
                    <div className="input">
                    <img src={password_icon} alt="Email icon" className="email-icon" />

                        <input
                            type="password"
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Password"
                            required
                        />
                    </div>
                    <br />
                    <input className = {"submit"} type="submit" onClick={submit}/>
                </form>

                <br />
                <p>Already have an account?</p>

                <Link to="/login">Login Page</Link>
                
            </div>
        </div>

    );
}

export default SignUpData;

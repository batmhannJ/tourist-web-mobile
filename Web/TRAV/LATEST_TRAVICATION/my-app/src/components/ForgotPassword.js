import React, { useState, useEffect } from "react";
import user_icon from '../assets/person.png';
import logo from '../assets/logo.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import "./SignUpData.css"; // Import the CSS file
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import Carousel from './Carousel';

function ForgotPassword() {
    const [email, setEmail] = useState('');
    const [verificationCode, setVerificationCode] = useState(''); // Verification code for email
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState(''); // Confirmation password
    const [isCodeSent, setIsCodeSent] = useState(false); // Track if verification code was sent
    const [passwordError, setPasswordError] = useState(''); // For password validation error
    const [otpSentTime, setOtpSentTime] = useState(null); // Track when the OTP was sent

    const navigate = useNavigate();

    // Function to request a reset verification code
    async function requestResetVerificationCode(e) {
        e.preventDefault();
        try {
            const response = await axios.post("http://localhost:4000/forgotpassword", { email });
            if (response.status === 200) {
                alert("A verification code has been sent to your email.");
                setIsCodeSent(true); 
                setOtpSentTime(Date.now()); // Store the time when OTP was sent
            } else {
                alert("Error sending verification code.");
            }
        } catch (error) {
            alert("Error sending verification code.");
            console.error(error);
        }
    }

    const validatePassword = (password) => {
        const minLength = 6;
        const hasUpperCase = /[A-Z]/.test(password);
        const hasLowerCase = /[a-z]/.test(password);
        const hasNumbers = /\d/.test(password);
        const hasSpecialChars = /[!@#$%^&*(),.?":{}|<>]/.test(password);

        return (
            password.length >= minLength &&
            hasUpperCase &&
            hasLowerCase &&
            hasNumbers &&
            hasSpecialChars
        );
    };

    const isOtpExpired = () => {
        if (!otpSentTime) return false;
        const currentTime = Date.now();
        const expiryTime = 2 * 60 * 1000;
        return currentTime - otpSentTime > expiryTime;
    };

    async function submitNewPassword(e) {
        e.preventDefault();

        if (!validatePassword(password)) {
            setPasswordError('Password must be at least 6 characters long and include uppercase letters, lowercase letters, numbers, and symbols.');
            return;
        }

        if (password !== confirmPassword) {
            setPasswordError('Passwords do not match.');
            return;
        }

        if (isOtpExpired()) {
            alert("The verification code has expired. Please request a new one.");
            return;
        }

        setPasswordError('');

        try {
            const response = await axios.patch("http://localhost:4000/forgotpassword", {
                email,
                verificationCode,
                password
            });

            if (response.status === 200) {
                alert("Password updated successfully");
                navigate("/login");
            } else {
                alert("Error updating password");
            }
        } catch (error) {
            alert("Error updating password");
            console.error(error);
        }
    }

    return (
        <div className="forgot-page">
        <Carousel />
        <div className="header-container">
        <img src={logo} alt="Logo" className="logo" />
        <div className="header-text">
            <div className="main-title">First Choice</div>
            <div className="sub-title">Travel Hub INC</div>
        </div>
        </div>
            <div className="login-container">
                <div className="header">
                    <div className="text">Forgot Password</div>
                    <div className="underline"></div>
                </div>

                <form onSubmit={isCodeSent ? submitNewPassword : requestResetVerificationCode}>
                    <div className="input">
                        
                        <img src={email_icon} alt="Email icon" />
                        <input
                            type="email"
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Email"
                            required
                        />
                    </div>
                    <br />
                    <div className="input">
                        <img src={password_icon} alt="Password icon" />
                        <input
                            type="password"
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Password"
                            required
                        />
                    </div>
                    <br />
                    <input className = {"submit"} type="submit" value="Change Password" onClick={submit}/>
                </form>

                <br />
                <p>Back to</p>
                <br />

                <Link to="/login">Login Page</Link>
            </div>
        </div>
    );
}

export default ForgotPassword;

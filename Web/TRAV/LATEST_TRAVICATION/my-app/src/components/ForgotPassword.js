import React, { useState } from "react";
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
    const [verificationCode, setVerificationCode] = useState(''); // Verification code
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [showInputs, setShowInputs] = useState(false); // Manage the visibility of additional inputs
    const [passwordError, setPasswordError] = useState('');
    const [otpSentTime, setOtpSentTime] = useState(null);

    const navigate = useNavigate();

    async function requestResetVerificationCode(e) {
        e.preventDefault();
        try {
            const response = await axios.post("https://travication-backend.onrender.com/forgotpassword", { email });
            if (response.status === 200) {
                alert("A verification code has been sent to your email.");
                setShowInputs(true); // Show the additional inputs
                setOtpSentTime(Date.now());
            } else {
                alert("There was an error in sending the verification code. Please enter correct email address.");
            }
        } catch (error) {
            alert("There was an error in sending the verification code. Please enter correct email address.");
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
        const expiryTime = 2 * 60 * 1000; // 2 minutes
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
            const response = await axios.patch("https://travication-backend.onrender.com/forgotpassword", {
                email,
                verificationCode,
                password
            });

            if (response.status === 200) {
                alert("We confirm that your password has been successfully updated.");
                navigate("/login");
            } else {
                alert("An error occurred while updating the password.");
            }
        } catch (error) {
            alert("An error occurred while updating the password.");
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

                <form onSubmit={showInputs ? submitNewPassword : requestResetVerificationCode}>
                    <div className="input">
                        <img src={email_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="text" // Email input
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Email Address"
                            required
                        />
                    </div>
                    <br />
                    {showInputs && (
                        <>
                            <div className="input">
                                <input
                                    type="text"
                                    onChange={(e) => setVerificationCode(e.target.value)}
                                    placeholder="Verification Code"
                                    required
                                />
                            </div>
                            <br />
                            <div className="input">
                                <img src={password_icon} alt="New Password icon" className="email-icon" />
                                <input
                                    type="password"
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="New Password"
                                    required
                                />
                            </div>
                            <br />
                            <div className="input">
                                <img src={password_icon} alt="Confirm Password icon" className="email-icon" />
                                <input
                                    type="password"
                                    onChange={(e) => setConfirmPassword(e.target.value)}
                                    placeholder="Confirm Password"
                                    required
                                />
                            </div>
                        </>
                    )}
                    <br />
                    <input 
                        className="submit" 
                        type="submit" 
                        value={showInputs ? "Change Password" : "Request Verification Code"} 
                    />
                </form>

                <br />
                <p>Back to</p>
                <Link to="/login">Login Page</Link>
            </div>
        </div>
    );
}

export default ForgotPassword;

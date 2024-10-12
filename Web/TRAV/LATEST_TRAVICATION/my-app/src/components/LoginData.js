import React, { useState, useEffect } from "react";
import logo from '../assets/logo.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import { Link, useNavigate } from "react-router-dom";
import "./SignUpData.css"; // Import the CSS file
import axios from "axios";
import Carousel from './Carousel';

function LoginData() {
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [isLockedOut, setIsLockedOut] = useState(false);
    const [attempts, setAttempts] = useState(0);
    const maxAttempts = 5;
    const lockoutDuration = 2 * 60 * 1000; // 2 minutes

    // Effect to manage the lockout timer
    useEffect(() => {
        let timer;
        if (isLockedOut) {
            timer = setTimeout(() => {
                setIsLockedOut(false);
                setAttempts(0); // Reset attempts after lockout duration
            }, lockoutDuration);
        }
        return () => clearTimeout(timer);
    }, [isLockedOut]);

    async function submit(e) {
        e.preventDefault();

        // Check if the user is locked out
        if (isLockedOut) {
            alert("You are temporarily locked out. Please try again later.");
            return;
        }

        try {
            const response = await axios.post("http://localhost:4000/login", {
                email,
                password
            }, { withCredentials: true });

            const responseData = response.data;

            if (responseData === "admin exist") {
                navigate("/home");
            } else if (responseData === "exist") {
                navigate("/managerhome");
            } else if (responseData.error) {
                // Handle different error cases
                if (responseData.error === "User not exist") {
                    alert("Account does not exist. Please sign up.");
                } else if (responseData.error === "User login declined") {
                    alert("Your login has been declined.");
                } else if (responseData.error === "Invalid username or password") {
                    // Increment attempts and handle lockout logic
                    setAttempts(prev => {
                        const newAttempts = prev + 1;
                        if (newAttempts >= maxAttempts) {
                            setIsLockedOut(true);
                            alert("You have been locked out due to too many failed login attempts. Please try again in 2 minutes.");
                        } else {
                            alert(`Incorrect email or password. Attempts left: ${maxAttempts - newAttempts}`);
                        }
                        return newAttempts;
                    });
                }
            }
        } catch (e) {
            if (e.response && e.response.data && e.response.data.error) {
                alert(e.response.data.error);
            } else {
                alert("An unexpected error occurred. Please try again later.");
            }
            console.error(e);
        }
    }

    return (
        <div className="login-page">
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
                    <div className="text">Login</div>
                    <div className="underline"></div>
                </div>

                <form onSubmit={submit}>
                    <br />
                    <div className="input">
                    <img src={email_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => { setEmail(e.target.value) }}
                            placeholder="Email"
                            required
                        />
                    </div>
                    <br />
                    <div className="input">
                    <img src={password_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => { setPassword(e.target.value) }}
                            placeholder="Password"
                            required
                        />
                    </div>
                    <div className="forgot-password">
                        <Link to="/ForgotPassword">Forgot Password?</Link>
                    </div>
                    <br />
                    <input className="submit" type="submit" value="Login" disabled={isLockedOut} />
                </form>
                <br />
                <p>Don't have an account?</p>
                <Link to="/signup">Signup Page</Link>
            </div>
            <style>{`
                body {
                    background: #FFF;
                    font-family: 'Roboto', sans-serif;
                    margin: 0;
                    padding: 0;
                    height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-direction: column;
                }
                .header-container {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-top: 5px;
                    position: absolute;
                    top: 20px;
                    left: 50%;
                    transform: translateX(-50%);
                }
                .logo {
                    height: 50px; /* Adjust the height of the logo */
                    margin-right: 10px; /* Space between the logo and the text */
                    width: auto; /* Maintain aspect ratio */
                }
                .main-title {
                    font-size: 36px; /* Increase the font size */
                    font-weight: bold;
                    color: darkred;
                }
                .sub-title {
                    font-size: 24px; /* Set the font size */
                    font-weight: bold;
                    color: black;
                }
                .header .text {
                    font-weight: normal; /* Ensure the "Login" text is not bold */
                }
                .login-container {
                    position: relative;
                    z-index: 1;
                    background: rgba(255, 255, 255, 0.8); /* Semi-transparent background */
                    padding: 20px;
                    border-radius: 10px;
                    margin-top: 100px; /* Adjusted margin to move the login form lower */
                }
            `}</style>
        </div>
    );
}

export default LoginData;

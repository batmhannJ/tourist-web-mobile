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
            console.log("Response Data:", response.data); // Log the response data

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
                

.header-container {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: 10px;
    position: absolute;
    top: 30px;
    left: 50%;
    transform: translateX(-50%);
}

.logo {
    height: 60px; /* Logo size */
    margin-right: 10px; /* Reduced space between logo and text */
    width: auto;
}

.main-title {
    font-size: 40px; /* Large title */
    font-weight: bold;
    color: #1f4b99; /* Dark blue title */
}

.sub-title {
    font-size: 22px;
    font-weight: 500;
    color: #3f7cfb; /* Lighter blue subtitle */
}

.text {
    font-size: 30px; /* Adjust font size as needed */
    font-weight: bold; /* Make the text bold */
    color: #1f4b99; /* Text color */
    text-align: center; /* Center the text */
    margin-top: 5px;
}

.underline {
    width: 100%; /* Full width */
    height: 1px; /* Height of the underline */
    background-color: #3f7cfb; /* Underline color */
    margin: 0 auto; /* Center the underline */
    max-width: 300px; /* Max width to limit size */
}

.login-text {
    font-size: 12px; /* Adjust this value to make text smaller */
    font-weight: normal;
    color: #555; /* Gray login text */
    margin: 0; /* Ensure no extra margin */
    text-align: center; /* Center the text */
}

.email-icon {
    height: 24px; /* Set the desired height of the icon */
    width: auto; /* Maintain aspect ratio */
    margin-right: 10px; /* Space between icon and adjacent text/input */
    transition: transform 0.2s ease; /* Smooth transition for hover effect */
}

/* Optional: Hover effect */
.email-icon:hover {
    transform: scale(1.1); /* Slightly enlarge the icon on hover */
}

.login-container {
    position: relative;
    z-index: 1;
    background: #fff; /* White background */
    padding: 20px;
    border-radius: 15px;
    margin-left:480px;
    margin-top: 170px; /* Adjusted margin for upward movement */
    box-shadow: 0px 10px 30px rgba(0, 0, 0, 0.1); /* Shadow for depth */
    width: 100%; /* Adjusted width */
    max-width: 500px; /* Maximum width */
    box-sizing: border-box; /* Include padding and border in element's total width and height */
}

/* Input Fields */
.input {
    display: flex;
    align-items: center;
    margin-bottom: 5; /* Space between input fields */
    background-color: #f9f9f9;
    border-radius: 8px;
    padding: 5px 10px; /* Increased padding for better touch */
    box-shadow: inset 0px 2px 5px rgba(0, 0, 0, 0.1); /* Inner shadow */
    border: 1px solid #ddd;
    transition: border 0.3s ease;
    width: 100%;
    height: 50px;
    box-sizing: border-box; /* Ensure padding is part of width */
}

.input img {
    height: 24px; /* Icon size */
    margin-right: 10px; /* Space between icon and input */
}

.input input {
    width: 100%; /* Full width for input */
    padding: 8px; /* Padding inside input */
    font-size: 16px;
    border: none;
    background: transparent;
    outline: none;
    color: #333;
}

.input:focus-within {
    border-color: #3f7cfb; /* Blue border on focus */
}

.forgot-password {
    margin-top:10px;
    margin-left: auto; /* Aligns to the right */
    font-size: 14px;
}

.forgot-password a {
    color: #1f4b99;
    text-decoration: none;
    font-size: 14px;
}

.forgot-password a:hover {
    text-decoration: underline;
}

.submit {
    width: 100%;
    background-color: #3f7cfb;
    color: white;
    padding: 10px; /* Padding for button */
    border: none;
    border-radius: 8px;
    font-size: 18px;
    cursor: pointer;
    transition: background-color 0.3s ease;
    box-sizing: border-box;
    margin-top: 10px; /* Space above the button */
}

.submit:hover {
    background-color: #1f4b99; /* Darker shade on hover */
}

.signup-link {
    display: inline-block; /* Makes the link behave like a button */
    padding: 10px 20px; /* Padding for spacing */
    background-color: #3f7cfb; /* Background color */
    color: white; /* Text color */
    border-radius: 8px; /* Rounded corners */
    font-size: 16px; /* Font size */
    text-decoration: none; /* Removes underline */
    text-align: center; /* Center the text */
    transition: background-color 0.3s ease; /* Smooth transition on hover */
    margin-top: 10px; /* Margin on top */
}

.signup-link:hover {
    background-color: #1f4b99; /* Darker shade on hover */
}
            `}</style>
        </div>
    );
}

export default LoginData;

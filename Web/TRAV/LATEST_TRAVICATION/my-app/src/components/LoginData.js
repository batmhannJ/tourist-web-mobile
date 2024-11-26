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
    const [otp, setOtp] = useState('');
    const [isOtpSent, setIsOtpSent] = useState(false);
    const [isOtpVerified, setIsOtpVerified] = useState(false);
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

    // Function to send OTP
    async function sendOtp() {
        try {
            const response = await axios.post("https://travication-backend.onrender.com/send-otp", { email });
            if (response.data.success) {
                alert("OTP sent to your email.");
                setIsOtpSent(true); // Set to true to show OTP input
            } else {
                alert("Error sending OTP. Please try again.");
                console.error("Error response:", response.data); // Log error details
            }
        } catch (error) {
            alert("An error occurred while sending OTP.");
            console.error("Error while sending OTP:", error);
        }
    }

    // Function to verify OTP
    async function verifyOtp() {
        try {
            const response = await axios.post("https://travication-backend.onrender.com/verify-otp", { email, otp });
            console.log("Verify OTP Response:", response.data); // Log response for debugging
            if (response.data.success) {
                alert("OTP verified successfully.");
                setIsOtpVerified(true);
            } else {
                alert("Invalid OTP. Please try again.");
            }
        } catch (error) {
            if (error.response) {
                alert(`Error: ${error.response.data.message || 'An error occurred during OTP verification.'}`);
            } else {
                alert("An unexpected error occurred. Please try again.");
            }
            console.error("Error during OTP verification:", error);
        }
    }

    async function submit(e) {
        e.preventDefault();

        if (!isOtpVerified) {
            alert("Please verify your OTP first.");
            return;
        }

        // Check if the user is locked out
        if (isLockedOut) {
            alert("You are temporarily locked out. Please try again later.");
            return;
        }

        try {
            const response = await axios.post("https://travication-backend.onrender.com/login", {
                email,
                password
            }, { withCredentials: true });

            const responseData = response.data;

            if (responseData === "admin exist") {
                localStorage.setItem("userType", "admin");
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
                        {!isOtpSent && (
                            <button type="button" onClick={sendOtp}>
                                Send OTP
                            </button>
                        )}
                    </div>
                    {isOtpSent && !isOtpVerified && (
                        <div className="input">
                            <input
                                type="text"
                                value={otp}
                                onChange={(e) => setOtp(e.target.value)}
                                placeholder="Enter OTP"
                                required
                            />
                            <button type="button" onClick={verifyOtp}>
                                Verify OTP
                            </button>
                        </div>
                    )}
                    <br />
                    <div className="input">
                        <img src={password_icon} alt="Password icon" className="email-icon" />
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => { setPassword(e.target.value) }}
                            placeholder="Password"
                            required
                            disabled={!isOtpVerified}
                        />
                    </div>
                    <div className="forgot-password">
                        <Link to="/ForgotPassword">Forgot Password?</Link>
                    </div>
                    <br />
                    <input className="submit" type="submit" value="Login" disabled={!isOtpVerified || isLockedOut} />
                </form>
                <br />
                <p>Don't have an account?</p>
                <Link to="/signup">Signup Page</Link>
                <br />
                <p>Download our application by clicking the link below:</p>
                <a
                    href="https://drive.google.com/file/d/1_Ac9qjl1lmbXvaqOi1Wd7Dj78jaPovof/view?usp=sharing"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="download-link"
                >
                    Download App
                </a>
            </div>
            <style>
{`
/* General Styles */
.header-container {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: 10px;
    position: absolute;
    top: 30px;
    left: 50%;
    transform: translateX(-50%);
    padding: 0 10px;
    max-width: 100%;
    box-sizing: border-box;
}

.download-link {
    display: inline-block;
    margin-top: 10px;
    color: #fff;
    background-color: #1f4b99;
    padding: 10px 20px;
    border-radius: 8px;
    text-decoration: none;
    font-size: 16px;
    transition: background-color 0.3s ease;
}

.download-link:hover {
    background-color: #3f7cfb;
}

.logo {
    height: 60px;
    margin-right: 10px;
    width: auto;
}

.main-title {
    font-size: 40px;
    font-weight: bold;
    color: #1f4b99;
}

.sub-title {
    font-size: 22px;
    font-weight: 500;
    color: #3f7cfb;
}

.text {
    font-size: 30px;
    font-weight: bold;
    color: #1f4b99;
    text-align: center;
    margin-top: 5px;
}

.underline {
    width: 100%;
    height: 1px;
    background-color: #3f7cfb;
    margin: 0 auto;
    max-width: 300px;
}

.login-text {
    font-size: 12px;
    font-weight: normal;
    color: #555;
    margin: 0;
    text-align: center;
}

.email-icon {
    height: 24px;
    width: auto;
    margin-right: 10px;
    transition: transform 0.2s ease;
}

.email-icon:hover {
    transform: scale(1.1);
}

.login-container {
    position: relative;
    z-index: 1;
    background: #fff;
    padding: 20px;
    border-radius: 15px;
    margin: auto;
    margin-top: 170px;
    box-shadow: 0px 10px 30px rgba(0, 0, 0, 0.1);
    width: 90%;
    max-width: 500px;
    box-sizing: border-box;
}

/* Apply zero margin-bottom to input elements */
.input {
    display: flex;
    align-items: center;
    margin-bottom: 0; /* Ensure no extra space is added */
    background-color: #f9f9f9;
    border-radius: 8px;
    padding: 5px 10px;
    box-shadow: inset 0px 2px 5px rgba(0, 0, 0, 0.1);
    border: 1px solid #ddd;
    transition: border 0.3s ease;
    width: 100%;
    height: 50px;
    box-sizing: border-box;
}

/* Set specific spacing between each input within the login container */
.login-container .input + .input {
    margin-top: 8px; /* Reduced gap between input fields */
}

.input img {
    height: 24px;
    margin-right: 10px;
}

.input input {
    width: 100%;
    padding: 8px;
    font-size: 16px;
    border: none;
    background: transparent;
    outline: none;
    color: #333;
}

.input:focus-within {
    border-color: #3f7cfb;
}

.forgot-password {
    margin-top: 10px;
    margin-left: auto;
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
    padding: 10px;
    border: none;
    border-radius: 8px;
    font-size: 18px;
    cursor: pointer;
    transition: background-color 0.3s ease;
    box-sizing: border-box;
    margin-top: 10px;
}

.submit:hover {
    background-color: #1f4b99;
}

.signup-link {
    display: inline-block;
    padding: 10px 20px;
    background-color: #3f7cfb;
    color: white;
    border-radius: 8px;
    font-size: 16px;
    text-decoration: none;
    text-align: center;
    transition: background-color 0.3s ease;
    margin-top: 10px;
}

.signup-link:hover {
    background-color: #1f4b99;
}

/* Responsive Design */
@media (max-width: 768px) {
    .header-container {
        flex-direction: column;
        top: 20px;
    }

    .main-title {
        font-size: 30px;
    }

    .sub-title {
        font-size: 18px;
    }

    .text {
        font-size: 24px;
    }

    .login-container {
        margin-top: 100px;
        padding: 15px;
        width: 95%;
    }

    .input {
        height: 45px;
    }
}

@media (max-width: 480px) {
    .header-container {
        padding: 5px;
    }

    .logo {
        height: 50px;
        margin: 0 auto 5px;
    }

    .main-title {
        font-size: 24px;
    }

    .sub-title {
        font-size: 16px;
    }

    .text {
        font-size: 20px;
    }

    .login-container {
        margin-top: 70px;
        padding: 10px;
        width: 100%;
    }

    .input {
        height: 40px;
        padding: 4px 8px;
    }

    .submit {
        font-size: 16px;
        padding: 8px;
    }

    .signup-link {
        font-size: 14px;
        padding: 8px 16px;
    }
}
`}
</style>


        </div>
    );
}

export default LoginData;

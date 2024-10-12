import React, { useState } from "react";
import logo from '../assets/logo.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import { Link, useNavigate } from "react-router-dom";
import "./SignUpData.css"; // Import the CSS file
import axios from "axios";
import Carousel from './Carousel';

function LoginData() {
    const [action, setAction] = useState("Login");
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');

    async function submit(e) {
        e.preventDefault();

        try {
            const response = await axios.post("http://localhost:4000/login", {
                email, password
            }, { withCredentials: true });

            const responseData = response.data;

            if (responseData === "admin exist") {
                checkSession();
                navigate("/home");
            } else if (responseData === "exist"){
                checkSession();
                navigate("/managerhome");
            }else if (responseData.error && responseData.error === "User not exist") {
                alert("User has not signed up");
            } else if (responseData.error && responseData.error === "User login declined") {
                alert("Your login has been declined.");
            } else if (responseData.error && responseData.error === "Invalid username or password") {
                alert("Invalid username or password");
            }
        } catch (e) {
            alert("Login error");
            console.error(e);
        }
    }

    const checkSession = async () => {
        try {
            const response = await axios.get('http://localhost:4000/check-session', { withCredentials: true });
            if (response.data && response.data.user) {
                console.log("Session data:", response.data.user);
            } else {
                setMessage("No user session found");
            }
        } catch (error) {
            console.error("Error checking session:", error);
            if (error.response && error.response.data && error.response.data.message) {
                setMessage(error.response.data.message);
            } else {
                setMessage("An error occurred while checking the session.");
            }
        }
    };

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
                    <div className="text">{action}</div>
                    <div className="underline"></div>
                </div>

                <form onSubmit={submit}>
                    <br />
                    <div className="input">
                    <img src={email_icon} alt="Email icon" className="email-icon" />
                        <input
                            type="email"
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
                            onChange={(e) => { setPassword(e.target.value) }}
                            placeholder="Password"
                            required
                        />
                    </div>
                    <div className="forgot-password">
                        <Link to="/ForgotPassword">Forgot Password?</Link>
                    </div>
                    <br />
                    <input className="submit" type="submit" value="Login" />
                </form>
                <br />
                <p>Don't have an account?</p>
                <Link to="/signup">Signup Page</Link>
            </div>
            

        </div>
    );
}

export default LoginData;

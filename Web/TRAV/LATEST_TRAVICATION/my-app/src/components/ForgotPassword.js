import React, { useState } from "react";
import user_icon from '../assets/person.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import "./SignUpData.css"; // Import the CSS file
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

function ForgotPassword() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    async function submit(e) {
        e.preventDefault();

        try {
            const response = await axios.patch("http://localhost:4000/forgotpassword", {
                email,
                password
            });

            if (response.status === 200) {
                alert("Password updated successfully");
            } else {
                alert("Error updating password");
            }
        } catch (e) {
            alert("Error updating password");
            console.error(e);
        }
    }

   

    return (
        <div>
            <style>{`
                body {
                    background: linear-gradient(to right, #5B247A, #1BCEDF);
                }
            `}</style>
            <div className="login-container">
                <div className="header">
                    <div className="text">Forgot Password</div>
                    <div className="underline"></div>
                </div>

                <form onSubmit={submit}>

               
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

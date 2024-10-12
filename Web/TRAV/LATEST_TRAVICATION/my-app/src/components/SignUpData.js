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

    async function submit(e){
        e.preventDefault();

        try{
            await axios.post("http://localhost:4000/signupdata",{
                name, email, password
            })
            .then(res=>{
                if(res.data === "exist"){
                    alert("User already exists")
                } else if(res.data === "not exist"){
                    alert("Account Created Successfuly")
                    history("/login", {state:{id:email}})
                }
            })
            .catch(e=>{
                alert("wrong details")
                console.log(e);
            })
        }
        catch(e){
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
                            placeholder="Email"
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

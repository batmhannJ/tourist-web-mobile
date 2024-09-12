import React, { useState } from "react";
import user_icon from '../assets/person.png';
import email_icon from '../assets/email.png';
import password_icon from '../assets/password.png';
import "./SignUpData.css"; // Import the CSS file
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";

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
        <div>
            <style>{`
                body {
                 background: linear-gradient(to right, #5B247A, #1BCEDF); 
                }
            `}</style>
            <div className="login-container">
                <div className="header">
                    <div className="text">{action}</div>
                    <div className="underline"></div>
                </div>
                

                <form onSubmit={submit}>

                <div className="input">
                        
                        <img src={email_icon} alt="Email icon" />
                        <input
                            type="text"
                            onChange={(e) => setName(e.target.value)}
                            placeholder="Name"
                            required
                        />
                    </div>
                    <br />
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
                    <input className = {"submit"} type="submit" onClick={submit}/>
                </form>

                <br />
                <p>OR</p>
                <br />

                <Link to="/login">Login Page</Link>
                
            </div>
        </div>
    );
}

export default SignUpData;

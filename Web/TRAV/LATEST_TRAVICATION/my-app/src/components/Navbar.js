import React, { Component } from "react";
import "./NavbarStyles.css";
import { MenuItems } from "./MenuItems";

class Navbar extends Component {
    state = {
        clicked: false
    };

    handleClick = () => {
        this.setState({ clicked: !this.state.clicked });
    };

    handleLogout = () => {
        console.log("Logging out...");
        sessionStorage.clear(); 
        
        window.location.href = "/login"; 
    };

    render() {
        return (
            <nav className="NavbarItems">
                <h1 className="navbar-logo">Travication</h1>

                <div className="menu-icons" onClick={this.handleClick}>
                    <i className={this.state.clicked ? "fas fa-times" : "fas fa-bars"}></i>
                </div>

                <ul className={this.state.clicked ? "nav-menu active" : "nav-menu"}>
                    {MenuItems.map((item, index) => (
                        <li key={index}>
                            {item.title === "Log Out" ? (
                                <button className={item.cName} onClick={this.handleLogout}>
                                    <i className={item.icon}></i>
                                    <span>{item.title}</span>
                                </button>
                            ) : (
                                <a className={item.cName} href={item.url}>
                                    <i className={item.icon}></i>
                                    <span>{item.title}</span>
                                </a>
                            )}
                        </li>
                    ))}
                </ul>
            </nav>
        );
    }
}

export default Navbar;

// src/pages/ManagerRegister.js
import React from 'react';
import Hero from "../components/Hero";
import Navbar from "../components/Navbar";
import AboutImg from "../assets/about-img.jpg";
import Footer from "../components/Footer";
import ManagerRegister from "../components/ManagerRegister"; // Correct import

function ManagerRegisterPage() {
    return (
        <>
            <Navbar />
            <Hero 
                cName="hero-mid"
                heroImg={AboutImg}
                title="Manager Register"
                btnClass="hide"
            />
            <ManagerRegister /> {/* Correct component usage */}
            <Footer />
        </>
    );
}

export default ManagerRegisterPage;

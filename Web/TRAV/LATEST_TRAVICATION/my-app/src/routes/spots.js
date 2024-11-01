// src/pages/ManagerRegister.js
import React from 'react';
import Hero from "../components/Hero";
import Navbar from "../components/Navbar";
import AboutImg from "../assets/about-img.jpg";
import Footer from "../components/Footer";
import AdminLocations from "../components/AdminLocations"; // Correct import

function AdminLocationsPage() {
    return (
        <>
            <Navbar />
            <Hero 
                cName="hero-mid"
                heroImg={AboutImg}
                title="Map Management"
                btnClass="hide"
            />
            <AdminLocations /> {/* Correct component usage */}
            <Footer />
        </>
    );
}

export default AdminLocationsPage;

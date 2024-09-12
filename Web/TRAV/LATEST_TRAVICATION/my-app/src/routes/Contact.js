import Hero from "../components/Hero";
import Navbar from "../components/ManagerNavbar";
import AboutImg from "../assets/contact-bg.jpg";
import Footer from "../components/Footer";
import ManageLocations from "../components/ManageLocations";

function Contact () {
    return(
        <>
        <Navbar/>
        <Hero 
        cName="hero-mid"
        heroImg={AboutImg}
        title="Maps"
        
        btnClass="hide"
        />
          
        <ManageLocations/>
        <Footer/>
        </>
    )

}

export default Contact;
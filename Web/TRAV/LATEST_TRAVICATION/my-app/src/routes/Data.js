import Hero from "../components/Hero";
import Navbar from "../components/ManagerNavbar";
import AboutImg from "../assets/about-img.jpg";
import Footer from "../components/Footer";
import AboutUs from "../components/AboutUs";

function Data () {
    return(
        <>
        <Navbar/>
        <Hero 
        cName="hero-mid"
        heroImg={AboutImg}
        title="About"
        
        btnClass="hide"
        />
        <AboutUs/>

        <Footer/>
          
        </>
    )

}

export default Data;
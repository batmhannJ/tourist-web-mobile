import Hero from "../components/Hero";
import Navbar from "../components/Navbar";
import AboutImg from "../assets/about-img.jpg";
import Footer from "../components/Footer";
import ManagerAccountManagement from "../components/ManagerAccountManagement";

function Service () {
    return(
        <>
       <Navbar/>
        <Hero 
        cName="hero-mid"
        heroImg={AboutImg}
        title="Service"

        
        
        btnClass="hide"
        />
        <ManagerAccountManagement/>

        <Footer/>
        </>
    )

}

export default Service;
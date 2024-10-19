import Hero from "../components/Hero";
import Navbar from "../components/ManagerNavbar";
import AboutImg from "../assets/about-img.jpg";
import Footer from "../components/Footer";
import DataAnalytics from "../components/DataAnalytics";

function Data () {
    return(
        <>
        <Navbar/>
        <Hero 
        cName="hero-mid"
        heroImg={AboutImg}
        title="Data Analytics"
        
        btnClass="hide"
        />
        <DataAnalytics/>

        <Footer/>
          
        </>
    )

}

export default Data;
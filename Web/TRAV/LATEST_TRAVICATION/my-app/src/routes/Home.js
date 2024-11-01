import Destination from "../components/Destination";
import Footer from "../components/Footer";
import Hero from "../components/Hero";
import AboutImg from "../assets/about-img.jpg";
import Navbar from "../components/Navbar";
function Home () {
    return(
        <>
        <Navbar/>
        <Hero 
        cName="hero"
        heroImg={AboutImg}
        title="Your Jouney Your Story"
        text="Choose Your Favorite Destination"
        buttonText="Travel Plan"
        url="/"
        btnClass="show"
        />
          <Destination/>
          <Footer/>
        </>
    );

} 

export default Home; 
import Destination from "../components/Destination";
import Footer from "../components/Footer";
import Hero from "../components/Hero";
import Navbar from "../components/Navbar";
function Home () {
    return(
        <>
        <Navbar/>
        <Hero 
        cName="hero"
        heroImg="https://media.discordapp.net/attachments/1229381821893185548/1233761672892649626/IMG_4265.jpg?ex=662e4599&is=662cf419&hm=858aafc3d82e47895744b5e2e71ddb9ed0dc18211463ad9d7ad46904ec694db6&=&format=webp&width=993&height=662"
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
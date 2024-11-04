import React from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import Siargao1 from "../assets/siargao1-img.jpg";
import Siargao2 from "../assets/siargao2.jpg";
import Tagayatay1 from "../assets/tagaytay1.jpg";
import Tagaytay2 from "../assets/tagaytag2.jpg";
import Ilocos1 from "../assets/ilocos1.jpg";
import Ilocos2 from "../assets/ilocos2-1.jpg";
import Baguio1 from "../assets/baguio1.jpg";
import Baguio2 from "../assets/baguio2.jpg";
import Antipolo1 from "../assets/antipolo1.jpg";
import Antipolo2 from "../assets/antipolo2.jpg";

import DestinationData from "./DestinationData";
import "./DestinationStyles.css";

const Destination = () => {
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            const response = await axios.post('https://travication-backend.onrender.com/logout', {}, { withCredentials: true });
            if (response.status === 200) {
                alert(response.data.message); // Show success message
                navigate('/login'); // Redirect to login page
            }
        } catch (error) {
            console.error('Logout error:', error);
            alert('Error during logout. Please try again.');
        }
    };

    return (
        <div className="destination">
            
            <h1>Popular Destinations</h1>
            <p>Tours give you the opportunity to see a lot, within a time frame</p>

            <DestinationData 
                className="first-des"
                heading="Siargao"
                text="Located in the province of Surigao del Norte, Siargao is a paradise for surfers and nature lovers alike. Famous for its cloud-nine waves, the island boasts some of the best surfing spots in the Philippines, attracting surf enthusiasts from around the world. Beyond surfing, visitors can explore the island's natural wonders, including the stunning Magpupungko Rock Pools, the picturesque Sugba Lagoon, and the enchanting Sohoton Cove. Siargao also offers vibrant nightlife, with beachfront bars and restaurants lining the shores of General Luna. With its laid-back vibe, pristine beaches, and world-class surf breaks, Siargao offers an unforgettable tropical experience."
                img1={Siargao1}
                img2={Siargao2}
            />

            <DestinationData 
                className="first-des-reverse"
                heading="Tagayatay"
                text="Perched on a ridge overlooking Taal Lake and its iconic volcano, Tagaytay offers breathtaking views and a cool climate, making it a popular weekend getaway from Manila. Visitors can marvel at the scenic vistas from Picnic Grove or People's Park in the Sky, where panoramic views of the surrounding landscape abound. The city is also known for its delectable cuisine, particularly bulalo (beef marrow stew) and tawilis (freshwater fish), served in numerous restaurants overlooking the scenic countryside. Tagaytay's charm lies in its tranquil ambiance, scenic landscapes, and delicious culinary offerings, making it an ideal destination for relaxation and indulgence."
                img1={Tagayatay1}
                img2={Tagaytay2}
            />

            <DestinationData 
                className="first-des"
                heading="Ilocos"
                text="Steeped in history and heritage, Ilocos Sur is a treasure trove of Spanish colonial architecture, stunning landscapes, and cultural attractions. Visitors can explore the UNESCO World Heritage-listed city of Vigan, known for its well-preserved Spanish-era houses and cobblestone streets. The historic town of Santa Maria is home to the picturesque Santa Maria Church, another UNESCO site, while the coastal town of Narvacan offers beautiful beaches and sand dunes. Nature lovers can hike to the stunning Kapurpurawan Rock Formation or visit the towering Bantay Abot Cave. With its rich history, breathtaking scenery, and warm hospitality, Ilocos Sur invites travelers to step back in time and discover the beauty of the Philippines' northern region."
                img1={Ilocos1}
                img2={Ilocos2}
            />

            <DestinationData 
                className="first-des-reverse"
                heading="Baguio"
                text="Baguio: Nestled in the Cordillera Mountains, Baguio is known as the Summer Capital of the Philippines for its cool climate and scenic beauty. Visitors are greeted with lush pine forests, vibrant flower gardens, and panoramic views of rolling hills. The city offers a variety of attractions, from the iconic Burnham Park and Mines View Park to the historic Camp John Hay and the colorful market of Session Road. Baguio is also famous for its strawberry farms, where visitors can pick their own fresh berries. Whether exploring its natural wonders, sampling local delicacies like strawberry taho, or shopping for handicrafts, Baguio promises a refreshing retreat for all."
                img1={Baguio1}
                img2={Baguio2}
            />

            <DestinationData 
                className="first-des"
                heading="Antipolo, Rizal"
                text="Perched atop the slopes of the Sierra Madre mountain range, Antipolo offers a serene escape from the bustling Metro Manila. The city is renowned for the Antipolo Cathedral, a centuries-old church housing the revered image of Our Lady of Peace and Good Voyage. Nearby, Hinulugang Taktak waterfall provides a tranquil spot for picnics and relaxation amidst lush greenery. Art enthusiasts flock to the Pinto Art Museum, an expansive gallery showcasing contemporary Filipino art within a Mediterranean-inspired compound. With its blend of natural beauty, cultural heritage, and artistic inspiration, Antipolo is a must-visit destination for travelers seeking a peaceful retreat."
                img1={Antipolo1}
                img2={Antipolo2}
            />
        </div>
    );
};

export default Destination;

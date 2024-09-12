import React from "react";
import './Carousel.css';
import image1 from '../assets/image1.jpg';
import image2 from '../assets/image2.jpg';
import image3 from '../assets/image3.jpg';
import image4 from '../assets/image4.jpg';
import image5 from '../assets/image5.jpg';

const Carousel = () => {
    return (
        <div className="carousel">
            <div className="slides">
                <div className="slide"><img src={image1} alt="Slide 1" /></div>
                <div className="slide"><img src={image2} alt="Slide 2" /></div>
                <div className="slide"><img src={image3} alt="Slide 3" /></div>
                <div className="slide"><img src={image4} alt="Slide 4" /></div>
                <div className="slide"><img src={image5} alt="Slide 5" /></div>
            </div>
        </div>
    );
};

export default Carousel;

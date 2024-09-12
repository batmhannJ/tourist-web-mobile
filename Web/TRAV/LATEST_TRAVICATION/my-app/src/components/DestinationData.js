import { Component } from "react";
import "./DestinationStyles.css";
import  Siargao1 from "../assets/siargao1-img.jpg"  
import  Siargao2 from "../assets/siargao2-img.jpg"

class DestinationData extends Component {
    render(){
        return(
 
            <div className={this.props.className}>
                <div className="des-text">
                <h2>{this.props.heading}</h2>

                <p>
               {this.props.text}
                </p>

            </div>

            <div className="image">
                <img alt="img" src={this.props.img1}/>
                <img alt="img" src={this.props.img2}/>
            </div>
            </div>
          

        );

    }
}

export default DestinationData;

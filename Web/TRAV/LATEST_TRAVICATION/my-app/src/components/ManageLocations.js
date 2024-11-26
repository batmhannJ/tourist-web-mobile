import React, { useState, useEffect } from "react";
import { MapContainer, TileLayer, Marker, useMapEvents } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import axios from "axios";

// Define a custom icon
const customIcon = L.AwesomeMarkers.icon({
    icon: "flag", // You can change this to icons like "coffee", "home", "flag", etc.
    markerColor: "red", // Options: red, darkred, orange, green, blue, purple, darkpurple, cadetblue
    prefix: "fa", // This is for FontAwesome icons
});

const ManageLocations = () => {
    const [locations, setLocations] = useState([]);
    const [newLocation, setNewLocation] = useState({
        city: "",
        destinationName: "",
        latitude: "",
        longitude: "",
        description: "",
    });
    const [selectedImage, setSelectedImage] = useState(null);

    useEffect(() => {
        // Fetch locations from the backend
        axios
            .get("https://travication-backend.onrender.com/getlocation")
            .then((response) => setLocations(response.data))
            .catch((error) => console.error("Error fetching locations:", error));
    }, []);

    const MapEventHandler = () => {
        useMapEvents({
            click: (e) => {
                setNewLocation({
                    ...newLocation,
                    latitude: e.latlng.lat.toFixed(6),
                    longitude: e.latlng.lng.toFixed(6),
                });
            },
        });
        return null;
    };

    const handleAddLocation = async () => {
        if (!newLocation.city || !newLocation.destinationName || !newLocation.description || !selectedImage) {
            alert("Please fill all fields and select an image.");
            return;
        }

        const formData = new FormData();
        formData.append("city", newLocation.city);
        formData.append("destinationName", newLocation.destinationName);
        formData.append("latitude", newLocation.latitude);
        formData.append("longitude", newLocation.longitude);
        formData.append("description", newLocation.description);
        formData.append("image", selectedImage);

        try {
            await axios.post("https://travication-backend.onrender.com/addlocation", formData, {
                headers: { "Content-Type": "multipart/form-data" },
            });
            alert("Location added successfully.");
            window.location.reload();
        } catch (error) {
            console.error("Error adding location:", error);
            alert("Failed to add location.");
        }
    };

    return (
        <div>
            <h1>Manage Locations</h1>
            <form>
                <label>City:</label>
                <input
                    type="text"
                    value={newLocation.city}
                    onChange={(e) => setNewLocation({ ...newLocation, city: e.target.value })}
                />

                <label>Destination Name:</label>
                <input
                    type="text"
                    value={newLocation.destinationName}
                    onChange={(e) => setNewLocation({ ...newLocation, destinationName: e.target.value })}
                />

                <label>Description:</label>
                <textarea
                    value={newLocation.description}
                    onChange={(e) => setNewLocation({ ...newLocation, description: e.target.value })}
                />

                <label>Image:</label>
                <input type="file" onChange={(e) => setSelectedImage(e.target.files[0])} />

                <div style={{ height: "400px", margin: "20px 0" }}>
                    <MapContainer center={[12.8797, 121.7740]} zoom={6} style={{ height: "100%", width: "100%" }}>
                        <TileLayer
                            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                            attribution="&copy; <a href='http://osm.org/copyright'>OpenStreetMap</a> contributors"
                        />
                        <MapEventHandler />
                        {newLocation.latitude && newLocation.longitude && (
                            <Marker
                                position={[newLocation.latitude, newLocation.longitude]}
                                icon={customIcon}
                            />
                        )}
                    </MapContainer>
                </div>

                <p>
                    Latitude: {newLocation.latitude}, Longitude: {newLocation.longitude}
                </p>

                <button type="button" onClick={handleAddLocation}>
                    Add Location
                </button>
            </form>
        </div>
    );
};

export default ManageLocations;

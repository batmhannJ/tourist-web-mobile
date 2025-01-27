import React, { useState, useEffect } from 'react';
import axios from 'axios';
import "./ContactFormStyles.css";
import { MapContainer, TileLayer, Marker, useMapEvents } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";


const customIcon = new L.Icon({
    iconUrl: '../assets/icon.png',
    iconSize: [25, 41], // Size of the icon
    iconAnchor: [12, 41], // Point of the icon which will correspond to marker's location
    popupAnchor: [1, -34], // Point from which the popup should open relative to the iconAnchor
    shadowUrl: 'path-to-your-shadow.png', // Optional, replace with your shadow image path
    shadowSize: [41, 41], // Size of the shadow
});


function ManageLocations() {
    const [locations, setLocations] = useState([]);
    const [editingLocation, setEditingLocation] = useState(null);
    const [newLocation, setNewLocation] = useState({ city: '', destinationName: '', latitude: '', longitude: '', description: '' });
    const [selectedCity, setSelectedCity] = useState('');
    const [selectedImage, setSelectedImage] = useState(null);

    // Predefined city data with latitude and longitude boundaries
    const cityData = {
        Baguio: { latitude: { min: 16.3910, max: 16.4570 }, longitude: { min: 120.5650, max: 120.6220 } },
        Bohol: { latitude: { min: 9.5540, max: 10.2130 }, longitude: { min: 123.7570, max: 124.5630 } },
        Cebu: { latitude: { min: 9.4870, max: 11.2590 }, longitude: { min: 123.2450, max: 124.0590 } },
        Boracay: { latitude: { min: 11.9370, max: 11.9880 }, longitude: { min: 121.9170, max: 121.9600 } },
        Batanes: { latitude: { min: 20.2500, max: 20.8500 }, longitude: { min: 121.7100, max: 122.0400 } },
    };

    useEffect(() => {
        axios.get('https://travication-backend.onrender.com/getlocation')
            .then(response => {
                if (Array.isArray(response.data)) {
                    setLocations(response.data);
                } else {
                    console.error('Response data is not an array:', response.data);
                }
            })
            .catch(error => {
                console.error('Error fetching locations:', error);
            });
    }, []);

    const MapEventHandler = () => {
        useMapEvents({
            click: (e) => {
                const { lat, lng } = e.latlng;
                if (isWithinBoundary(lat, lng)) {
                    setNewLocation({ ...newLocation, latitude: lat.toFixed(6), longitude: lng.toFixed(6) });
                } else {
                    alert(`Coordinates out of bounds for ${selectedCity}.`);
                }
            },
        });
        return null;
    };

    const handleImageChange = (e) => {
        setSelectedImage(e.target.files[0]);
    };

    const handleCityChange = (e) => {
        const selectedCity = e.target.value;
        setSelectedCity(selectedCity);

        if (selectedCity && cityData[selectedCity]) {
            setNewLocation({
                ...newLocation,
                city: selectedCity,
                latitude: '',
                longitude: ''
            });
        } else {
            setNewLocation({ ...newLocation, city: '', latitude: '', longitude: '' });
        }
    };

    const isWithinBoundary = (lat, lon) => {
        const { min: latMin, max: latMax } = cityData[selectedCity].latitude;
        const { min: lonMin, max: lonMax } = cityData[selectedCity].longitude;

        return lat >= latMin && lat <= latMax && lon >= lonMin && lon <= lonMax;
    };

    useEffect(() => {
        if (selectedCity) {
            initMap();
        }
    }, [selectedCity]);

     
    const loadGoogleMapsScript = () => {
        if (!document.getElementById('google-maps-script')) {
            const script = document.createElement('script');
            script.id = 'google-maps-script';
            script.src = `https://maps.googleapis.com/maps/api/js?key=AIzaSyBEcu_p865o6zGHCcA9oDlKl04xeFCBaIs&libraries=places`;
            script.async = true;
            script.defer = true;
            script.onload = () => initMap(); // Ensure the map initializes only after the script loads
            document.body.appendChild(script);
        } else {
            initMap(); // If script already exists, initialize the map
        }
    };
    
      
    
    const initMap = () => {
        try {
            if (!window.google || !window.google.maps) {
                console.error("Google Maps script not loaded or initialized.");
                return;
            }
    
            const map = new window.google.maps.Map(document.getElementById('map'), {
                center: { lat: 16.4023, lng: 120.5960 }, // Default center
                zoom: 13,
            });
    
            let marker = null;
    
            map.addListener('click', (e) => {
                const lat = e.latLng.lat();
                const lon = e.latLng.lng();
    
                if (!selectedCity) {
                    alert('Please select a city first.');
                    return;
                }
    
                if (isWithinBoundary(lat, lon)) {
                    setNewLocation({ ...newLocation, latitude: lat.toFixed(6), longitude: lon.toFixed(6) });
    
                    if (marker) marker.setMap(null);
                    marker = new window.google.maps.Marker({
                        position: { lat, lng: lon },
                        map,
                        title: "Selected Location",
                    });
                } else {
                    alert(`Coordinates out of bounds for ${selectedCity}.`);
                }
            });
    
            // Update map center based on selected city
            const cityCoordinates = {
                Baguio: { lat: 16.4023, lng: 120.5960 },
                Bohol: { lat: 9.7480, lng: 123.9177 },
                Cebu: { lat: 10.3157, lng: 123.8854 },
                Boracay: { lat: 11.9670, lng: 121.9300 },
                Batanes: { lat: 20.4541, lng: 121.9576 },
            };
    
            if (selectedCity && cityCoordinates[selectedCity]) {
                map.setCenter(cityCoordinates[selectedCity]);
            }
        } catch (error) {
            console.error("Error initializing Google Maps:", error);
        }
    };    
    
useEffect(() => {
    loadGoogleMapsScript();  // Call to load the script when component mounts
}, []);


    const handleEditLocation = (index) => {
        setEditingLocation(index);
        setNewLocation({ ...locations[index] });
    };

    const handleUpdateLocation = async (e) => {
        e.preventDefault();

        const lat = parseFloat(newLocation.latitude);
        const lon = parseFloat(newLocation.longitude);

        if (!newLocation.city || !newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description) {
            alert("Please fill in all fields.");
            return;
        }

        if (editingLocation === null || editingLocation < 0 || editingLocation >= locations.length) {
            alert("Invalid location selected for editing.");
            return;
        }

        // Validate latitude and longitude
        if (!isWithinBoundary(lat, lon)) {
            alert(`Latitude must be between ${cityData[selectedCity].latitude.min} and ${cityData[selectedCity].latitude.max}, and Longitude must be between ${cityData[selectedCity].longitude.min} and ${cityData[selectedCity].longitude.max}.`);
            return;
        }

        const id = locations[editingLocation]._id;

        const formData = new FormData();
        formData.append("city", newLocation.city);
        formData.append("destinationName", newLocation.destinationName);
        formData.append("latitude", newLocation.latitude);
        formData.append("longitude", newLocation.longitude);
        formData.append("description", newLocation.description);

        if (selectedImage) {
            formData.append("image", selectedImage);
        }

        const today = new Date();
        const formattedDate = today.toISOString().split('T')[0];
        formData.append("dateAdded", formattedDate); // Add dateUpdated field


        try {
            const response = await axios.patch(`https://travication-backend.onrender.com/editlocation/${id}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });

            console.log('Update Response:', response.data);
            alert("Location updated successfully.");
            window.location.reload();
        } catch (error) {
            console.error("Error updating location:", error);
            alert("Error updating location. Please try again.");
        }
    };

    const handleDeleteManager = async (id, index) => {
        const confirmDelete = window.confirm("Are you sure you want to delete this?");
        if (confirmDelete) {
            try {
                await axios.delete(`https://travication-backend.onrender.com/deletelocation/${id}`);
                const updatedLocations = [...locations];
                updatedLocations.splice(index, 1);
                setLocations(updatedLocations);
                alert("Location deleted successfully.");
            } catch (e) {
                alert("Location delete error");
                console.error(e);
            }
        }
    };

    return (
        <div className="form-container">
            <h1>Manage Locations</h1>
            <div className="location-fields">
                <div className="form-container">
                    <form>
                        {/* City Selection */}
                        <div className="field-group">
                            <label htmlFor="city">City:</label>
                            <select id="city" value={selectedCity} onChange={handleCityChange}>
                                <option value="">Select City</option>
                                {Object.keys(cityData).map((city) => (
                                    <option key={city} value={city}>
                                        {city}
                                    </option>
                                ))}
                            </select>
                        </div>
    {/* Destination Name */}
    <div className="field-group">
            <label htmlFor="destinationName">Select Location on Map: </label>
            <div id="map" style={{ height: '400px', width: '100%', margin: '10px 0' }}></div>

        </div>

                        {/* Destination Name */}
                        <div className="field-group">
                            <label htmlFor="destinationName">Destination Name:</label>
                            <input
                                id="destinationName"
                                type="text"
                                value={newLocation.destinationName}
                                onChange={(e) => setNewLocation({ ...newLocation, destinationName: e.target.value })}
                            />
                        </div>

                        {/* Latitude */}
                        <div className="field-group">
                            <label htmlFor="latitude">Latitude:</label>
                            <input
                                id="latitude"
                                type="text"
                                value={newLocation.latitude}
                                onChange={(e) => setNewLocation({ ...newLocation, latitude: e.target.value })}
                                disabled={!selectedCity}
                            />
                        </div>

                        {/* Longitude */}
                        <div className="field-group">
                            <label htmlFor="longitude">Longitude:</label>
                            <input
                                id="longitude"
                                type="text"
                                value={newLocation.longitude}
                                onChange={(e) => setNewLocation({ ...newLocation, longitude: e.target.value })}
                                disabled={!selectedCity}
                            />
                        </div>

                        {/* Description */}
                        <div className="description-field">
                            <label htmlFor="description">Description:</label>
                            <textarea
                                id="description"
                                value={newLocation.description}
                                onChange={(e) => setNewLocation({ ...newLocation, description: e.target.value })}
                            />
                        </div>

                        {/* Image Upload */}
                        <div className="field-group">
                            <label htmlFor="image">Image:</label>
                            <input id="image" type="file" onChange={handleImageChange} />
                        </div>

                        {/* Update Button */}
                        <div className="button-group">
                            <button type="submit" onClick={handleUpdateLocation}>Update Location</button>
                        </div>
                    </form>
                </div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>City</th>
                        <th>Name</th>
                        <th>Latitude</th>
                        <th>Longitude</th>
                        <th>Description</th>
                        <th>Image</th>
                        <th>Date Added</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                {locations.map((location, index) => {
                                const date = new Date(location.dateAdded);
                                const formattedDate = date.toISOString().split('T')[0]; // Extract YYYY-MM-DD
                                return (
                        <tr key={location._id}>
                            <td>{location.city}</td>
                            <td>{location.destinationName}</td>
                            <td>{location.latitude}</td>
                            <td>{location.longitude}</td>
                            <td>{location.description}</td>
                            <td>
                                {location.image ? (
                                    <img
                                        src={`https://travication-backend.onrender.com/${location.image.replace(/\\/g, '/')}`}
                                        alt={location.destinationName}
                                        width="300"
                                        height="300"
                                        onError={(e) => {
                                            console.error('Error loading image:', e.target.src);
                                            e.target.src = '/fallback-image.jpg';
                                        }}
                                    />
                                ) : (
                                    'No image'
                                )}
                            </td>
                            <td>{formattedDate}</td>
                            <td>
                                <button onClick={() => handleEditLocation(index)}>Edit</button>
                                <button onClick={() => handleDeleteManager(location._id, index)}>Delete</button>
                            </td>
                        </tr>
                   );
                })}
                </tbody>
            </table>
        </div>
    );
}

export default ManageLocations;

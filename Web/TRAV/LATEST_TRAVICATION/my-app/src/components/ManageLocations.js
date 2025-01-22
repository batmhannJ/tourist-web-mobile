import React, { useState, useEffect } from 'react';
import axios from 'axios';
import "./ContactFormStyles.css";

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

    const initMap = () => {
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
    
                // Place a pin on the map
                if (marker) marker.setMap(null); // Remove the previous marker
                marker = new window.google.maps.Marker({
                    position: { lat, lng: lon },
                    map,
                    title: "Selected Location",
                });
            } else {
                alert(`Coordinates out of bounds for ${selectedCity}.`);
            }
        });
    };
    

    const handleAddLocation = async () => {
        const lat = parseFloat(newLocation.latitude);
        const lon = parseFloat(newLocation.longitude);

        if (!newLocation.city || !newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description || !selectedImage) {
            alert("Please fill all fields and select an image");
            return;
        }

        // Validate latitude and longitude
        if (!isWithinBoundary(lat, lon)) {
            alert(`Latitude must be between ${cityData[selectedCity].latitude.min} and ${cityData[selectedCity].latitude.max}, and Longitude must be between ${cityData[selectedCity].longitude.min} and ${cityData[selectedCity].longitude.max}.`);
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
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            alert("Location added successfully.");
            window.location.reload();
        } catch (e) {
            alert("Location add error");
        }
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
            <div className="description">
                This is where you can describe the location.
            </div>
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

        {/* Submit Buttons */}
        <div className="button-group">
            {editingLocation !== null ? (
                <button type="submit" onClick={handleUpdateLocation}>Update Location</button>
            ) : (
                <button type="submit" onClick={handleAddLocation}>Add Location</button>
            )}
        </div>
    </form>
</div>
</div>
            <table>
                <thead>
                    <tr>
                        <th>City</th>
                        <th>Destination Name</th>
                        <th>Latitude</th>
                        <th>Longitude</th>
                        <th>Description</th>
                        <th>Image</th> {/* New column for the image */}
                    </tr>
                </thead>
                <tbody>
                    {locations.map((location, index) => (
                        <tr key={location._id}>
                            <td>{location.city}</td>
                            <td>{location.destinationName}</td>
                            <td>{location.latitude}</td>
                            <td>{location.longitude}</td>
                            <td>{location.description}</td>
                            <td>
                                {location.image ? (
                                    <>
                                        {console.log('Fetching image from URL:', `https://travication-backend.onrender.com/${location.image.replace(/\\/g, '/')}`)}
                                        <img 
                                            src={`https://travication-backend.onrender.com/${location.image.replace(/\\/g, '/')}`} 
                                            alt={location.destinationName} 
                                            width="300" 
                                            height="300"
                                            onError={(e) => {
                                                console.error('Error loading image:', e.target.src);
                                                e.target.src = '/fallback-image.jpg'; // Optional fallback image
                                            }}
                                        />
                                    </>
                                ) : (
                                    <p>No image available</p>
                                )}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ManageLocations;
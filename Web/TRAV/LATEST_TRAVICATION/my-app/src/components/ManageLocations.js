import React, { useState, useEffect } from 'react';
import axios from 'axios';
import "./ContactFormStyles.css";

function ManageLocations() {
    const [locations, setLocations] = useState([]);
    const [editingLocation, setEditingLocation] = useState(null);
    const [newLocation, setNewLocation] = useState({ city: '', destinationName: '', latitude: '', longitude: '', description: '' });
    const [selectedCity, setSelectedCity] = useState('');
    const [selectedImage, setSelectedImage] = useState(null); // State for storing the selected image
    
    // Predefined city data with latitude and longitude ranges
    const cityData = {
        Baguio: { latitude: [16.41639, 16.41639], longitude: [120.59306, 120.59306] },
        Bohol: { latitude: [9.84999, 9.84999], longitude: [124.14354, 124.14354] },
        Cebu: { latitude: [10.31672, 10.31672], longitude: [123.89071, 123.89071] },
        Boracay: { latitude: [11.968603, 11.968603], longitude: [121.918381, 121.918381] },
        Batanes: { latitude: [20.45798, 20.45798], longitude: [121.9941, 121.9941] }
    };


    useEffect(() => {
        axios.get('http://localhost:4000/getlocation')
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
        setSelectedImage(e.target.files[0]); // Store selected image
    };

    const handleCityChange = (e) => {
        const selectedCity = e.target.value;
        setSelectedCity(selectedCity);

        // Set latitude and longitude based on the selected city
        if (selectedCity && cityData[selectedCity]) {
            const { latitude, longitude } = cityData[selectedCity];
            setNewLocation({
                ...newLocation,
                city: selectedCity, // This is what you were missing
                latitude: latitude[0],
                longitude: longitude[0]
            });
        } else {
            setNewLocation({ ...newLocation, city: '', latitude: '', longitude: '' });
        }
    };

    
    const handleAddLocation = async () => {
        if (!newLocation.city || !newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description || !selectedImage) {
            alert("Please fill all fields and select an image");
            return;
        }

        const formData = new FormData();
        formData.append("city", newLocation.city);
        formData.append("destinationName", newLocation.destinationName);
        formData.append("latitude", newLocation.latitude);
        formData.append("longitude", newLocation.longitude);
        formData.append("description", newLocation.description);
        formData.append("image", selectedImage); // Append image to form data

        try {
            await axios.post("http://localhost:4000/addlocation", formData, {
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

    const handleEditLocation = (index) => {
        setEditingLocation(index);
        setNewLocation({ ...locations[index] });
    };

    const handleUpdateLocation = async (e) => {
        e.preventDefault();
    
        // Validate all required fields
        if (!newLocation.city || !newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description) {
            alert("Please fill in all fields.");
            return;
        }
    
        // Ensure editingLocation is set and is within the bounds of locations array
        if (editingLocation === null || editingLocation < 0 || editingLocation >= locations.length) {
            alert("Invalid location selected for editing.");
            return;
        }
    
        const id = locations[editingLocation]._id; // Get the ID of the location to be updated
    
        const formData = new FormData();
        formData.append("city", newLocation.city);
        formData.append("destinationName", newLocation.destinationName);
        formData.append("latitude", newLocation.latitude);
        formData.append("longitude", newLocation.longitude);
        formData.append("description", newLocation.description);
    
        // Only append the image if a new one has been selected
        if (selectedImage) {
            formData.append("image", selectedImage);
        }
    
        try {
            // Make the API request to update the location
            const response = await axios.patch(`http://localhost:4000/editlocation/${id}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
    
            console.log('Update Response:', response.data); // Log response for debugging
    
            // Notify user and refresh the page
            alert("Location updated successfully.");
            window.location.reload();
        } catch (error) {
            console.error("Error updating location:", error);
            alert("Error updating location. Please try again.");
        }
    };
    
    
    

    const handleDeleteManager = async (id, index) => {
        const confirmDelete = window.confirm("Are you sure you want to delete this?");
        if(confirmDelete){
            try {
                await axios.delete(`http://localhost:4000/deletelocation/${id}`); // Correct endpoint
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
                        <th>Actions</th>
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
            {console.log('Fetching image from URL:', `http://localhost:4000/${location.image.replace(/\\/g, '/')}`)}
            <img 
                src={`http://localhost:4000/${location.image.replace(/\\/g, '/')}`} 
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

                            <td>
                            <div className="action-buttons">
                                <button className="edit-button" onClick={() => handleEditLocation(index)}>Edit</button>
                                <button className="delete-button" onClick={() => handleDeleteManager(location._id, index)}>Delete</button>
                            </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ManageLocations;
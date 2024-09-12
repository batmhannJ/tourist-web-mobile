import React, { useState, useEffect } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faEdit, faTrash } from '@fortawesome/free-solid-svg-icons';
import "./ContactFormStyles.css";
import axios from "axios";

function ManageLocations() {
    const [locations, setLocations] = useState([]);
    const [editingLocation, setEditingLocation] = useState(null);
    const [newLocation, setNewLocation] = useState({ destinationName: '', latitude: '', longitude: '', description: '' });

    useEffect(() => {
        axios.get('http://localhost:4000/getlocation')
            .then(response => {
                // Ensure the data is an array before setting state
                if (Array.isArray(response.data)) {
                    setLocations(response.data);
                } else {
                    console.error('Response data is not an array:', response.data);
                }
            })
            .catch(error => {
                console.error('Error fetching managers:', error);
            });
    }, []); 

     const handleAddLocation = async (e) => {
        if (!newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description) {
            alert("Fill all fields");
            return; 
        }
    
        try {
              // Otherwise, we are in add mode, so call the add function
              axios.post("http://localhost:4000/addlocation", {
                  destinationName: newLocation.destinationName,
                  latitude: newLocation.latitude,
                  longitude: newLocation.longitude,
                  description: newLocation.description
              });
              alert("location added successfully.");
              window.location.reload();
      } catch(e) {
          alert("location Add error");
      }
   }
    
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


const handleEditLocation = (index) => {
    setEditingLocation(index);
    setNewLocation({ ...locations[index] });
};

const handleUpdateLocation = async (e) => { // Update parameter to event and add async
    e.preventDefault(); // Prevent default form submission
    if (!newLocation.destinationName || !newLocation.latitude || !newLocation.longitude || !newLocation.description) {
        alert("Fill all fields");
        return;
    }

    const id = locations[editingLocation]._id; // Get the id of the location being edited

    try {
        const response = await axios.patch(`http://localhost:4000/editlocation/${id}`, {
            destinationName: newLocation.destinationName,
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
            description: newLocation.description
        });

        const updatedLocations = locations.map((location, idx) =>
            idx === editingLocation ? response.data : location
        );

        setLocations(updatedLocations);
        setEditingLocation(null);
        setNewLocation({ destinationName: '', latitude: '', longitude: '', description: '' });
        alert("Location updated successfully.");
        window.location.reload();
    } catch (error) {
        alert("Location update error.");
        console.error(error);
    }
};


    return (
        <div className="form-container">
            <h1>Manage Locations</h1>
            <div className="location-fields">
                <div className="field-group">
                    <label htmlFor="destinationName">Destination Name:</label>
                    <input
                        id="destinationName"
                        type="text"
                        value={newLocation.destinationName}
                        onChange={(e) => setNewLocation({ ...newLocation, destinationName: e.target.value })}
                    />
                </div>
                <div className="field-group">
                    <label htmlFor="latitude">Latitude:</label>
                    <input
                        id="latitude"
                        type="text"
                        value={newLocation.latitude}
                        onChange={(e) => setNewLocation({ ...newLocation, latitude: e.target.value })}
                    />
                </div>
                <div className="field-group">
                    <label htmlFor="longitude">Longitude:</label>
                    <input
                        id="longitude"
                        type="text"
                        value={newLocation.longitude}
                        onChange={(e) => setNewLocation({ ...newLocation, longitude: e.target.value })}
                    />
                </div>
            </div>
            <div className="description-field">
                <label htmlFor="description">Description:</label>
                <textarea
                    id="description"
                    value={newLocation.description}
                    onChange={(e) => setNewLocation({ ...newLocation, description: e.target.value })}
                />
            </div>
            <div className="button-group">
                {editingLocation !== null ? (
                    <button type="submit"  onClick={handleUpdateLocation}>Update Location</button>
                ) : (
                    <button type="submit" onClick={handleAddLocation}>Add Location</button>
                )}
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Destination Name</th>
                        <th>Latitude</th>
                        <th>Longitude</th>
                        <th>Description</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {locations.map((location, index) => (
                        <tr key={location._id}>
                            <td>{location.destinationName}</td>
                            <td>{location.latitude}</td>
                            <td>{location.longitude}</td>
                            <td>{location.description}</td>
                            <td>
                                <div className="action-buttons">
                                <button onClick={() => handleEditLocation(index)}>Edit</button> {/* Pass index to handler */}
                                <button onClick={() => handleDeleteManager(location._id, index)}>Delete</button>
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
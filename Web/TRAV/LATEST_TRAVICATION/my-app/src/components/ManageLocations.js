import React, { useState, useEffect } from 'react';
import axios from 'axios';
import "./ContactFormStyles.css";
import { GoogleMap, Marker, useLoadScript } from '@react-google-maps/api';

const mapContainerStyle = {
  width: '100%',
  height: '400px',
};

function ManageLocations() {
  const [locations, setLocations] = useState([]);
  const [editingLocation, setEditingLocation] = useState(null);
  const [newLocation, setNewLocation] = useState({ city: '', destinationName: '', latitude: '', longitude: '', description: '' });
  const [selectedCity, setSelectedCity] = useState('');
  const [selectedImage, setSelectedImage] = useState(null);

  const { isLoaded } = useLoadScript({
    googleMapsApiKey: "AIzaSyBEcu_p865o6zGHCcA9oDlKl04xeFCBaIs",
  });

  const [mapCenter, setMapCenter] = useState({ lat: 12.8797, lng: 121.7740 }); // Default to Philippines
  const [mapZoom, setMapZoom] = useState(5); // Default zoom

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
      const cityBounds = cityData[selectedCity];
      const cityCenter = {
        lat: (cityBounds.latitude.min + cityBounds.latitude.max) / 2,
        lng: (cityBounds.longitude.min + cityBounds.longitude.max) / 2,
      };
      setMapCenter(cityCenter);
      setMapZoom(12); // Zoom in on the selected city

      setNewLocation({
        ...newLocation,
        city: selectedCity,
        latitude: '',
        longitude: ''
      });
    } else {
      // Reset to default map view if no city is selected
      setMapCenter({ lat: 12.8797, lng: 121.7740 });
      setMapZoom(5);
    }
  };

  const handleMapClick = (event) => {
    const lat = event.latLng.lat();
    const lng = event.latLng.lng();
    console.log("Map Clicked at Lat:", lat, "Lng:", lng);

    if (!selectedCity) {
      alert("Please select a city first.");
      return;
    }

    const cityBounds = cityData[selectedCity];
    if (!cityBounds) return;

    if (
      lat >= cityBounds.latitude.min &&
      lat <= cityBounds.latitude.max &&
      lng >= cityBounds.longitude.min &&
      lng <= cityBounds.longitude.max
    ) {
      setNewLocation({
        ...newLocation,
        latitude: lat.toFixed(6),
        longitude: lng.toFixed(6),
      });
    } else {
      alert("Selected location is outside the city boundaries.");
    }
  };

  if (!isLoaded) return <div>Loading Google Maps...</div>;

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

        {/* Google Map */}
      <div className="field-group">
      <GoogleMap
            mapContainerStyle={mapContainerStyle}
            center={mapCenter}
            zoom={mapZoom}
            onClick={handleMapClick}
          >
            {newLocation.latitude && newLocation.longitude && (
              <Marker
                position={{
                  lat: parseFloat(newLocation.latitude),
                  lng: parseFloat(newLocation.longitude),
                }}
              />
            )}
          </GoogleMap>

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

                            {/*<td>
                            <div className="action-buttons">
                                <button className="edit-button" onClick={() => handleEditLocation(index)}>Edit</button>
                                <button className="delete-button" onClick={() => handleDeleteManager(location._id, index)}>Delete</button>
                            </div>
                            </td>*/}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ManageLocations;
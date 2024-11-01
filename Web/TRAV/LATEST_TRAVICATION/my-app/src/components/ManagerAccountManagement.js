import React, { useState, useEffect } from 'react';
import "./ServiceStyles.css";
import axios from "axios";

function TourManagerPage() {
    const [managers, setManagers] = useState([]);
    const [editingManager, setEditingManager] = useState(null);
    const [updatedManager, setUpdatedManager] = useState({ name: '', email: '' });

    useEffect(() => {
        fetchManagers();
    }, []);

    const fetchManagers = async () => {
        try {
            const response = await axios.get('http://localhost:4000/getmanagers');
            if (Array.isArray(response.data)) {
                setManagers(response.data);
            } else {
                console.error('Response data is not an array:', response.data);
            }
        } catch (error) {
            console.error('Error fetching managers:', error);
        }
    };

    const handleUpdateManager = async (e) => {
        e.preventDefault();
        if (!updatedManager.name || !updatedManager.email) {
            alert("Fill both fields");
            return;
        }

        const id = managers[editingManager]._id; // Get the id of the manager being edited
        try {
            const response = await axios.patch(`http://localhost:4000/editmanager/${id}`, {
                name: updatedManager.name,
                email: updatedManager.email,
            });

            const updatedManagers = managers.map((manager, idx) =>
                idx === editingManager ? response.data : manager
            );

            setManagers(updatedManagers);
            resetManagerForm();
            alert("The manager information has been updated successfully.");
        } catch (error) {
            alert("An error occurred while updating the manager.");
            console.error(error);
        }
    };

    const handleEditManager = (index) => {
        setEditingManager(index);
        setUpdatedManager({ ...managers[index] }); // Load the selected manager's data for editing
    };

    const resetManagerForm = () => {
        setEditingManager(null);
        setUpdatedManager({ name: '', email: '' });
    };

    const handleDeleteManager = async (id, index) => {
        const confirmDelete = window.confirm("Are you sure you want to delete this?");
        if (confirmDelete) {
            try {
                await axios.delete(`http://localhost:4000/deletemanager/${id}`);
                const updatedManagers = [...managers];
                updatedManagers.splice(index, 1);
                setManagers(updatedManagers);
                alert("Manager deleted successfully.");
            } catch (error) {
                alert("Error deleting manager");
                console.error(error);
            }
        }
    };

    const handleApproveManager = async (id, index) => {
        try {
            const response = await axios.patch(`http://localhost:4000/approvemanager/${id}`);
            const updatedManagers = [...managers];
            updatedManagers[index] = response.data;
            setManagers(updatedManagers);
            alert("The manager account has been successfully approved.");
        } catch (error) {
            alert("An error occurred while approving the manager.");
            console.error(error);
        }
    };

    const handleDeclineManager = async (id, index) => {
        try {
            const response = await axios.patch(`http://localhost:4000/declinemanager/${id}`);
            const updatedManagers = [...managers];
            updatedManagers[index] = response.data;
            setManagers(updatedManagers);
            alert("The manager account has been successfully declined.");
        } catch (error) {
            alert("An error occurred while declining the manager.");
            console.error(error);
        }
    };

    return (
        <div style={{
            backgroundColor: '#ffffff', // White background for the container
            borderRadius: '8px', // Slightly rounded corners
            padding: '30px', // Generous padding
            maxWidth: '900px', // Max width for the container
            margin: '40px auto', // Centered with top/bottom margins
            boxShadow: '0 2px 15px rgba(0, 0, 0, 0.1)', // Subtle shadow for depth
            fontFamily: 'Arial, sans-serif', // Clean font family
        }}>
            <h1 style={{
                fontSize: '35px', // Title size
                color: '#333333', // Dark gray color for the title
                marginBottom: '25px', // Space below the title
                textAlign: 'center', // Centered title
                fontWeight: 'bold' // Bold title
            }}>Manage Tour Managers</h1>
        
            {editingManager !== null && (
                <form onSubmit={handleUpdateManager} style={{
                    display: 'flex', // Flexbox for input and button alignment
                    justifyContent: 'center', // Centered content
                    marginBottom: '30px', // Space below the form
                }}>
                    <input
                        type='email'
                        placeholder="Tour Manager Email"
                        value={updatedManager.email}
                        onChange={(e) => setUpdatedManager({ ...updatedManager, email: e.target.value })}
                        style={{
                            padding: '12px 15px', // Padding for input
                            border: '2px solid #007bff', // Blue border for input
                            borderRadius: '5px', // Rounded corners for input
                            marginRight: '10px', // Space between input and button
                            flexGrow: '1', // Allow input to grow
                            fontSize: '16px', // Font size for input
                            outline: 'none', // Remove outline on focus
                        }}
                    />
                    <button type="submit" style={{
    backgroundColor: '#28a745', // Green background for submit button
    border: 'none', // No border
    color: '#ffffff', // White text
    padding: '5px 10px', /* Adjust padding for height */
    borderRadius: '5px', // Rounded corners for button
    cursor: 'pointer', // Pointer cursor
    fontSize: '16px', // Font size for button
    fontWeight: 'bold', // Bold button text
    transition: 'background-color 0.3s', // Transition for hover effect
}} onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#218838'} onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#28a745'}>Update Manager</button>

                </form>
            )}
        
            <div style={{
                borderTop: '2px solid #007bff', // Blue line separating header from content
                paddingTop: '20px', // Padding above the table
                marginTop: '20px', // Margin above the table
            }}>
                <table style={{
                    width: '100%', // Full width for the table
                    borderCollapse: 'collapse', // Remove gaps between cells
                }}>
                    <thead>
                        <tr style={{
                            backgroundColor: '#f1f1f1', // Light gray background for header
                            color: '#333333', // Darker text color for visibility
                            height: '50px', // Fixed height for header
                        }}>
                            <th style={{ padding: '10px', textAlign: 'left' }}>Name</th>
                            <th style={{ padding: '10px', textAlign: 'left' }}>Email</th>
                            <th style={{ padding: '10px', textAlign: 'left' }}>Status</th>
                            <th style={{ padding: '10px', textAlign: 'left' }}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {managers.map((manager, index) => (
                            <tr key={manager._id} style={{
                                borderBottom: '1px solid #dddddd', // Light border between rows
                                height: '50px', // Fixed height for rows
                            }}>
                                <td style={{ padding: '10px' }}>{manager.name}</td>
                                <td style={{ padding: '10px' }}>{manager.email}</td>
                                <td style={{ padding: '10px' }}>{manager.status}</td>
                                <td style={{ padding: '10px' }}>
                                    <button onClick={() => handleEditManager(index)} style={{
                                        backgroundColor: '#007bff', // Blue background for edit button
                                        border: 'none', // No border
                                        color: '#ffffff', // White text
                                        padding: '8px 12px', // Padding for button
                                        borderRadius: '5px', // Rounded corners for button
                                        cursor: 'pointer', // Pointer cursor
                                        marginRight: '5px', // Space between buttons
                                        fontSize: '14px', // Font size for button
                                        transition: 'background-color 0.2s', // Transition for hover effect
                                    }} onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#0056b3'} onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#007bff'}>Edit</button>
                                    <button onClick={() => handleApproveManager(manager._id, index)} style={{
                                        backgroundColor: '#28a745', // Green background for approve button
                                        border: 'none', // No border
                                        color: '#ffffff', // White text
                                        padding: '8px 12px', // Padding for button
                                        borderRadius: '5px', // Rounded corners for button
                                        cursor: 'pointer', // Pointer cursor
                                        marginRight: '5px', // Space between buttons
                                        fontSize: '14px', // Font size for button
                                    }}>Approve</button>
                                    <button onClick={() => handleDeclineManager(manager._id, index)} style={{
                                        backgroundColor: '#dc3545', // Red background for decline button
                                        border: 'none', // No border
                                        color: '#ffffff', // White text
                                        padding: '8px 12px', // Padding for button
                                        borderRadius: '5px', // Rounded corners for button
                                        cursor: 'pointer', // Pointer cursor
                                        fontSize: '14px', // Font size for button
                                    }}>Decline</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
        
    );
}
export default TourManagerPage;

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
        <div className="form-container">
            <h1>Manage Tour Managers</h1>
            {editingManager !== null && (
                <form onSubmit={handleUpdateManager}>
                    <input
                        type='email'
                        placeholder="Email"
                        value={updatedManager.email}
                        onChange={(e) => setUpdatedManager({ ...updatedManager, email: e.target.value })}
                    />
                    <button type="submit">Update Tour Manager</button>
                </form>
            )}

            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {managers.map((manager, index) => (
                        <tr key={manager._id}>
                            <td>{manager.name}</td>
                            <td>{manager.email}</td>
                            <td>{manager.status}</td>
                            <td>
                                <button onClick={() => handleEditManager(index)}>Edit</button>
                                <button onClick={() => handleApproveManager(manager._id, index)}>Approve</button>
                                <button onClick={() => handleDeclineManager(manager._id, index)}>Decline</button>
                                {/* <button onClick={() => handleDeleteManager(manager._id, index)}>Delete</button>*/}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
export default TourManagerPage;

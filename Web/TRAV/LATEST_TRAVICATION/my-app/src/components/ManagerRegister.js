// src/components/ManagerRegister.js
import React, { useState, useEffect } from 'react';
import "./ServiceStyles.css";
import axios from "axios";

function ManagerRegister() { // Renamed to ManagerRegister
    const [managers, setManagers] = useState([]);
    const [editingManager, setEditingManager] = useState(null);
    const [newManager, setNewManager] = useState({ name: '', email: '', password: '', role: ''});

    useEffect(() => {
        axios.get('http://localhost:4000/getmanagers')
            .then(response => {
                if (Array.isArray(response.data)) {
                    setManagers(response.data);
                } else {
                    console.error('Response data is not an array:', response.data);
                }
            })
            .catch(error => {
                console.error('Error fetching managers:', error);
            });
    }, []);

   
    const handleApproveManager = async (id, index) => {
        try {
            const response = await axios.patch(`http://localhost:4000/approvemanager/${id}`);
            const updatedManager = response.data;
    
            const updatedManagers = [...managers];
            updatedManagers[index] = updatedManager;
            
            setManagers(updatedManagers);
            alert("Manager approved successfully.");
        } catch (e) {
            alert("Manager approval error");
            console.error(e);
        }
    };
    
    const handleDeclineManager = async (id, index) => {
        try {
            const response = await axios.patch(`http://localhost:4000/declinemanager/${id}`);
            const updatedManager = response.data;
    
            const updatedManagers = [...managers];
            updatedManagers[index] = updatedManager;
            
            setManagers(updatedManagers);
            alert("Manager decline successfully.");
        } catch (e) {
            alert("Manager decline error");
            console.error(e);
        }
    };

    const handleDeleteManager = async (id, index) => {
        try {
            await axios.delete(`http://localhost:4000/deletemanager/${id}`);
            const updatedManagers = [...managers];
            updatedManagers.splice(index, 1);
            setManagers(updatedManagers);
            alert("Location deleted successfully.");
        } catch (e) {
            alert("Location delete error");
            console.error(e);
        }
    };

    return (
        <div className="form-container">
           

            <h1>Tour Managers Registering</h1>
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
                                <button onClick={() => handleApproveManager(manager._id, index)}>Approve</button>
                                <button onClick={() => handleDeclineManager(manager._id, index)}>Decline</button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ManagerRegister;

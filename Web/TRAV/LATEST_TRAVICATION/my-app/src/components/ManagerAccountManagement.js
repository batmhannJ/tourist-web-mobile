import React, { useState, useEffect } from 'react';
import "./ServiceStyles.css";
import axios from "axios";

function ManageTourManager() {
    const [managers, setManagers] = useState([]);
    const [editingManager, setEditingManager] = useState(null);
    const [newManager, setNewManager] = useState({ name: '', email: '', password: '', role: ''});
    

    

    useEffect(() => {
        axios.get('http://localhost:4000/getmanagers')
            .then(response => {
                // Ensure the data is an array before setting state
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

    const handleAddManager = (e) => {
      
      if (!newManager.name || !newManager.email) {
        alert("Fill both fields");
        return; 
    }

    

    try {
      if (editingManager !== null) {
          // If editingManager is not null, it means we are in edit mode, so call the update function instead
          handleUpdateManager(newManager._id); // Assuming _id is available for existing managers
      } else {
          // Otherwise, we are in add mode, so call the add function
          axios.post("http://localhost:4000/addmanager", {
              name: newManager.name,
              email: newManager.email
          });
          alert("Manager added successfully.");
      }
  } catch(e) {
      alert("Manager Add error");
  }
};

const handleEditManager = (index) => {
    setEditingManager(index);
    setNewManager({ ...managers[index] });
};

const handleUpdateManager = async (e) => { // Update parameter to event and add async
    e.preventDefault(); // Prevent default form submission
    if (!newManager.name || !newManager.email || !newManager.password) {
        alert("Select Manager First");
        return;
    }

    const id = managers[editingManager]._id; // Get the id of the location being edited

    try {
        const response = await axios.patch(`http://localhost:4000/editmanager/${id}`, {
            name: newManager.name,
            email: newManager.email,
            password: newManager.password
        });

        const updatedManagers = managers.map((manager, idx) =>
            idx === editingManager ? response.data : manager
        );

        setManagers(updatedManagers);
        setEditingManager(null);
        setNewManager({ name: '', email: '', password: ''});
        alert("Manager updated successfully.");
        window.location.reload();
    } catch (error) {
        alert("Manager update error.");
        console.error(error);
    }
};

  const handleDeleteManager = async (id, index) => {
    const confirmDelete = window.confirm("Are you sure you want to delete this?");
    if(confirmDelete){
        try {
            await axios.delete(`http://localhost:4000/deletemanager/${id}`); // Correct endpoint
            const updatedManagers = [...managers];
            updatedManagers.splice(index, 1);
            setManagers(updatedManagers);
            alert("Account deleted successfully.");
        } catch (e) {
            alert("Account delete error");
            console.error(e);
        }
    }
};
  
    return (
        <div className="form-container">
          
            <h2>{editingManager !== null ? 'Edit Tour Manager' : 'Edit Tour Manager'}</h2>
            <form onSubmit={handleAddManager}>
                <input
                    placeholder="Name"
                    value={newManager.name}
                    onChange={(e) => setNewManager({ ...newManager, name: e.target.value })}
                />
                <input type='email'
                    placeholder="Email"
                    value={newManager.email}
                    onChange={(e) => setNewManager({ ...newManager, email: e.target.value })}
                />
                
               
                    <button onClick={handleUpdateManager}>Update Tour Manager</button>
                
                  
            </form>

            <h1>Manage Tour Managers</h1>
            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {managers.map((manager, index) => (
                        <tr key={manager._id}>
                            <td>{manager.name}</td>
                            <td>{manager.email}</td>
                            <td>
                                <button onClick={() => handleEditManager(index, manager._id)}>Edit</button>{"\t\t\t\t\t"}
                                <button onClick={() => handleDeleteManager(manager._id, index)}>Delete</button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ManageTourManager;

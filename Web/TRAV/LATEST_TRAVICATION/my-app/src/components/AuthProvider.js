// src/AuthProvider.js
import React, { createContext, useState, useEffect } from 'react';
import axios from 'axios';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [loading, setLoading] = useState(true);

    const checkAuthStatus = async () => {
        try {
            // Determine the API URL based on the environment
            const apiURL =
                process.env.NODE_ENV === 'production'
                    ? 'https://travication-backend.onrender.com/check-session'
                    : 'https://travication-backend.onrender.com/check-session';

            // Use the apiURL for the request
            const response = await axios.get(apiURL, { withCredentials: true });
            console.log("API Response:", response); // Debugging line

            if (response.status === 200 && response.data.user) {
                setIsAuthenticated(true);
            } else {
                setIsAuthenticated(false);
            }
        } catch (error) {
            setIsAuthenticated(false);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        checkAuthStatus();
    }, []);

    return (
        <AuthContext.Provider value={{ isAuthenticated, setIsAuthenticated, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

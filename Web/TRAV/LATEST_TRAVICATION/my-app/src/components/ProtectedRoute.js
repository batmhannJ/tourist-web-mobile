import React, { useContext } from 'react';
import {Navigate , Outlet  } from 'react-router-dom';
import { AuthContext } from './AuthProvider';

const ProtectedRoute = ({ redirectTo = "/home" }) => {
    const { isAuthenticated, loading } = useContext(AuthContext);

    if (loading) {
        return <div>Loading...</div>; // Optional: Add a loading spinner
    }

    return isAuthenticated ? <Outlet /> : <Navigate to={redirectTo} />;
};

export default ProtectedRoute;

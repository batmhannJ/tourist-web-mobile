import React, { useContext, useEffect } from 'react';
import { Navigate , Outlet, useNavigate } from 'react-router-dom';
import { AuthContext } from './AuthProvider';


const ProtectedRoute = ({ redirectTo = "/home" }) => {
    const { isAuthenticated, loading } = useContext(AuthContext);
    const navigate = useNavigate();

    useEffect(() => {
        if (!loading) {
            if (isAuthenticated) {
                // Automatically navigate to the protected route if authenticated
                navigate(redirectTo, { replace: true });
            }
        }
    }, [isAuthenticated, loading, navigate, redirectTo]);

    if (loading) {
        return <div>Loading...</div>; // Optional: Add a loading spinner
    }

    return isAuthenticated ? <Outlet /> : <Navigate to={redirectTo} replace />;
};

export default ProtectedRoute;

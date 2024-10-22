// api/check-session.js
import { NextApiRequest, NextApiResponse } from 'next';

export default async (req, res) => {
    try {
        if (req.method === 'GET') {
            console.log('Session check initiated');
            // Add your authentication logic here
            res.status(200).json({ user: 'admin' });
        } else {
            res.setHeader('Allow', ['GET']);
            res.status(405).end(`Method ${req.method} Not Allowed`);
        }
    } catch (error) {
        console.error('Error in check-session:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};


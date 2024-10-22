// api/check-session.js
import { NextApiRequest, NextApiResponse } from 'next';

export default async (req, res) => {
    if (req.method === 'GET') {
        // Gawin ang iyong authentication logic dito
        res.status(200).json({ user: 'admin' });
    } else {
        res.setHeader('Allow', ['GET']);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
};

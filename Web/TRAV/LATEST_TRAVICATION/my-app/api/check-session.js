import { MongoClient } from 'mongodb';

const uri = 'mongodb+srv://travication:usRDnGdoj1VL3HYt@travicationuseraccount.hz2n2rg.mongodb.net/?retryWrites=true&w=majority&appName=test';
let client;

export default async (req, res) => {
    if (req.method === 'GET') {
        if (!client) {
            client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
            await client.connect();
        }

        const db = client.db('test');
        const usersCollection = db.collection('accounts');

        // Check if session exists and respond with the user data
        const user = await usersCollection.findOne({ role: 'admin' }); // Example query
        if (user) {
            return res.status(200).json({ user: user.email });
        } else {
            return res.status(401).json({ message: 'Not authenticated' });
        }
    } else {
        res.setHeader('Allow', ['GET']);
        res.status(405).end(`Method ${req.method} Not Allowed`);
    }
};

import React, { useEffect, useState } from 'react';
import './AboutUsStyles.css';
import { BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, Legend } from 'recharts';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

// Function to assign best months based on the city
const getBestMonthsForCity = (city) => {
    let bestMonths = [];
    switch (city.toLowerCase()) {
        case 'baguio':
            bestMonths = [3, 4, 5, 10, 11, 12];
            break;
        case 'bohol':
            bestMonths = [12, 1, 2, 3, 4, 5];
            break;
        case 'batanes':
            bestMonths = [3, 4, 5, 6, 7];
            break;
        case 'boracay':
            bestMonths = [2, 3, 4, 5, 8, 9];
            break;
        case 'cebu':
            bestMonths = [4, 5, 6, 7, 8, 9];
            break;
        default:
            bestMonths = [];
    }
    return bestMonths;
};

const DataAnalytics = () => {
    const [destinations, setDestinations] = useState([]);
    const [expandedMonth, setExpandedMonth] = useState(null);

    useEffect(() => {
        fetchDestinations();
    }, []);

    const fetchDestinations = async () => {
        try {
            const response = await fetch('http://localhost:4000/getlocation'); // Your API endpoint
            const data = await response.json();
            setDestinations(data);
        } catch (error) {
            console.error('Failed to fetch destinations:', error);
        }
    };

    // Prepare data for the popular cities chart
    const citiesData = destinations.reduce((acc, place) => {
        const existingCity = acc.find(city => city.name === place.city);
        if (existingCity) {
            existingCity.count += 1;
        } else {
            acc.push({ name: place.city, count: 1 });
        }
        return acc;
    }, []);

    const bestMonthCities = destinations.reduce((acc, place) => {
        const bestMonths = getBestMonthsForCity(place.city); // Get best months based on the city
        bestMonths.forEach(month => {
            if (!acc[month]) {
                acc[month] = [];
            }
            acc[month].push(place.destinationName);
        });
        return acc;
    }, {});

    // Generate a sorted array of months
    const months = [
        { number: 1, name: 'January' },
        { number: 2, name: 'February' },
        { number: 3, name: 'March' },
        { number: 4, name: 'April' },
        { number: 5, name: 'May' },
        { number: 6, name: 'June' },
        { number: 7, name: 'July' },
        { number: 8, name: 'August' },
        { number: 9, name: 'September' },
        { number: 10, name: 'October' },
        { number: 11, name: 'November' },
        { number: 12, name: 'December' },
    ];

    const handleToggleMonth = (month) => {
        setExpandedMonth(expandedMonth === month ? null : month);
    };

    return (
        <div className="analytics-container">
            <h1>Data Analytics Dashboard</h1>
            <h2>Popular Cities</h2>
            <div className="chart-container">
                <BarChart width={600} height={300} data={citiesData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="count" fill="#8884d8" />
                </BarChart>
            </div>

            <h2>Best Months for Travel</h2>
            <div className="months-container">
                {months.map(({ number, name }) => (
                    <div key={number} className="month-card">
                        <button
                            className="month-btn"
                            onClick={() => handleToggleMonth(number)}
                        >
                            {name}
                        </button>

                        {expandedMonth === number && (
                            <div className="destinations-list">
                                {bestMonthCities[number] && bestMonthCities[number].length > 0 ? (
                                    bestMonthCities[number].map((destination, index) => (
                                        <div key={index} className="destination-card">
                                            <p>{destination}</p>
                                        </div>
                                    ))
                                ) : (
                                    <p>No destinations for this month</p>
                                )}
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
}

export default DataAnalytics;

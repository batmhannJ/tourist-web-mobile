import React, { useEffect, useState } from 'react';
import './analytics.css';
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
    const [mostSearchedDestinations, setMostSearchedDestinations] = useState([]);
    const [expandedMonth, setExpandedMonth] = useState(null);
    const [isPanelOpen, setIsPanelOpen] = useState(false); // State for panel visibility

    useEffect(() => {
        fetchDestinations();
        fetchMostSearchedDestinations();  // Fetch most searched destinations
    }, []);

    const fetchDestinations = async () => {
        try {
            const response = await fetch('https://travication-backend.onrender.com/getlocation'); // Your API endpoint
            const data = await response.json();
            setDestinations(data);
        } catch (error) {
            console.error('Failed to fetch destinations:', error);
        }
    };

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
        const bestMonths = getBestMonthsForCity(place.city);
        bestMonths.forEach(month => {
            if (!acc[month]) {
                acc[month] = [];
            }
            acc[month].push(place.destinationName);
        });
        return acc;
    }, {});

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

    const handleToggleMonth = (monthNumber) => {
        // Check if there are tourist spots for the selected month
        if (bestMonthCities[monthNumber]?.length > 0) {
            if (expandedMonth === monthNumber) {
                // If the month is already expanded, toggle the panel closed
                setIsPanelOpen(!isPanelOpen);
            } else {
                // Set the new month and open the panel
                setExpandedMonth(monthNumber);
                setIsPanelOpen(true);
            }
        } else {
            // If no spots are available, keep the panel closed
            setIsPanelOpen(false);
        }
    };

    const handleClosePanel = () => {
        setIsPanelOpen(false);
        setExpandedMonth(null); // Reset the expanded month when closing
    };
    

    const fetchMostSearchedDestinations = async () => {
        try {
            const response = await fetch('https://travication-backend.onrender.com/getMostSearchedDestinations'); // Your API endpoint for most searched destinations
            const data = await response.json();
            setMostSearchedDestinations(data);
        } catch (error) {
            console.error('Failed to fetch most searched destinations:', error);
        }
    };

    return (
        <div className="analytics-container">

<section style={{
    backgroundColor: '#ffffff', // Bright white background for clarity
    padding: '30px', // Increased padding for spaciousness
    borderRadius: '15px', // More pronounced rounded corners
    boxShadow: '0 4px 15px rgba(0, 0, 0, 0.1)', // Deeper shadow for depth
    maxWidth: '900px', // Wider section for more space
    margin: '20px auto', // Center horizontally
    textAlign: 'center' // Center all text
}}>
    <h2 style={{
        fontSize: '26px', // Slightly larger title font size
        color: '#2c3e50', // Darker text color for better contrast
        marginBottom: '25px', // Space below title
        fontWeight: 'bold' // Bold title for emphasis
    }}>Destination Counts per City</h2>
    <div style={{
        backgroundColor: '#f7f9fc', // Light background for the chart area
        borderRadius: '10px', // Rounded corners for the chart area
        padding: '25px', // Padding around the chart
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)', // Subtle shadow for the chart area
        display: 'flex', // Flexbox for centering
        justifyContent: 'center', // Center the chart
        alignItems: 'center' // Center vertically
    }}>
        <BarChart width={800} height={300} data={citiesData}> {/* Increased width of the BarChart */}
            <CartesianGrid strokeDasharray="3 3" stroke="#dcdcdc" /> {/* Light gray grid */}
            <XAxis dataKey="name" tick={{ fill: "#34495e" }} /> {/* Darker tick color */}
            <YAxis tick={{ fill: "#34495e" }} />
            <Tooltip contentStyle={{ backgroundColor: '#fff', border: '1px solid #ddd' }} /> {/* Tooltip styling */}
            <Legend />
            <Bar dataKey="count" fill="#3498db" /> {/* Changed bar color to blue */}
        </BarChart>
    </div>
</section>
<br />

            {/*<section className="searched-section">
                <h2 className="section-title">Most Searched Destinations</h2>
                <div className="most-searched-container">
                    {mostSearchedDestinations.length > 0 ? (
                        mostSearchedDestinations.map((destination, index) => (
                            <div key={index} className="destination-card">
                                <div className="destination-info">
                                    <p className="destination-title">{destination.title || 'Unnamed Destination'}</p>
                                    <p
                                        className="destination-count"
                                        style={{
                                            backgroundColor: COLORS[index % COLORS.length],
                                        }}
                                    >
                                        Search Count: {destination.count}
                                    </p>
                                </div>
                            </div>
                        ))
                    ) : (
                        <p>No data available for most searched destinations.</p>
                    )}
                </div>
            </section>*/}

            <section className="popular-cities-section">
            <h2 className="section-title">Popular Cities</h2>
            <div className="months-container">
                {months.map(({ number, name }) => (
                    <div key={number} className="month-card">
                        <button className="month-btn" onClick={() => handleToggleMonth(number)}>
                            {name}
                        </button>
                    </div>
                ))}
            </div>

            {/* Sliding Panel Structure */}
            <div className={`sliding-panel ${isPanelOpen ? 'open' : ''}`}>
                <div className="panel-header">
                    <h2 className="panel-title">Explore Tourist Spots for {months[expandedMonth - 1]?.name}</h2>
                    <button className="close-panel-btn" onClick={handleClosePanel}>✖</button>
                </div>
                <div className="panel-content">
                    {bestMonthCities[expandedMonth]?.length > 0 ? (
                        <ul className="destination-list">
                            {bestMonthCities[expandedMonth].map((destination, index) => (
                                <li key={index} className="destination-item">
                                    {destination}
                                </li>
                            ))}
                        </ul>
                    ) : (
                        <p className="no-destinations" style={{ display: 'none' }}>No tourist spots available.</p>
                    )}
                </div>
            </div>
        </section>

        </div>
    );
};

export default DataAnalytics;

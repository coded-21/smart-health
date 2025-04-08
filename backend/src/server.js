const express = require('express');
const cors = require('cors');
const { generateBiometricData } = require('./utils/mockDataGenerator');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/biometric-data', (req, res) => {
    const data = generateBiometricData();
    res.json(data);
});

app.get('/api/biometric-data/history', (req, res) => {
    // Generate last 10 readings
    const history = Array.from({ length: 10 }, () => generateBiometricData());
    res.json(history);
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}); 
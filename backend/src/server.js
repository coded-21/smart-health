const express = require('express');
const cors = require('cors');
const { generateBiometricData } = require('./utils/mockDataGenerator');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Store the last 100 readings (about 100 seconds of data)
const dataStore = {
  readings: []
};

// Generate a reading every second in the background to ensure continuous data
let generationInterval = null;

function startDataGeneration() {
  if (!generationInterval) {
    console.log('Starting background data generation every 1 second');
    // Generate initial data point
    const initialData = generateBiometricData();
    // console.log('Initial data generated:', initialData); // Debug log
    dataStore.readings.push(initialData);
    
    // Set up interval for continuous data generation
    generationInterval = setInterval(() => {
      const data = generateBiometricData();
      // console.log('Generated data:', data); // Debug log
      dataStore.readings.push(data);
      
      // Keep only the last 100 readings
      if (dataStore.readings.length > 100) {
        dataStore.readings.shift();
      }
    }, 1000); // Generate data every second
  }
}

// Routes
app.get('/api/biometric-data', (req, res) => {
  if (!generationInterval) {
    startDataGeneration();
  }
  const user = req.query.user || 'default';

  let latestReading;
  if (user === 'johnson') {
    // Generate separate data just for Johnson
    latestReading = require('./utils/mockDataGenerator').generateBiometricData('johnson');
  } else {
    // Use shared pool for default data
    latestReading = dataStore.readings.length > 0
      ? dataStore.readings[dataStore.readings.length - 1]
      : generateBiometricData();
  }

  // Ensure heartRate is an integer
  latestReading.hr = Math.round(latestReading.hr);

  res.json(latestReading);
});

app.get('/api/biometric-data/history', (req, res) => {
    // Ensure we've started data generation
    if (!generationInterval) {
      startDataGeneration();
    }
    
    
    // Format the readings to match Flutter app expectations
    const formattedReadings = dataStore.readings.map(reading => ({
      timestamp: reading.timestamp,
      heartRate: reading.hr,
      skinResponse: reading.eda,
      hrv: reading.hrv,
      respiratoryRate: reading.rr,
      stressLevel: reading.stressLevel,
      stressScore: reading.stressScore,
      motion: {
        x: Math.random() * 2 - 1,
        y: Math.random() * 2 - 1,
        z: Math.random() * 2 - 1
      }
    }));
    
    res.json(formattedReadings);
});

// New endpoint to get history for a specific time range
app.get('/api/biometric-data/range', (req, res) => {
    // Ensure we've started data generation
    if (!generationInterval) {
      startDataGeneration();
    }
    
    const seconds = parseInt(req.query.seconds) || 15;
    const now = new Date();
    const cutoff = new Date(now.getTime() - seconds * 1000);
    
    const filteredData = dataStore.readings
      .filter(reading => new Date(reading.timestamp) >= cutoff)
      .map(reading => ({
        timestamp: reading.timestamp,
        heartRate: reading.hr,
        skinResponse: reading.eda,
        hrv: reading.hrv,
        respiratoryRate: reading.rr,
        stressLevel: reading.stressLevel,
        stressScore: reading.stressScore,
        motion: {
          x: Math.random() * 2 - 1,
          y: Math.random() * 2 - 1,
          z: Math.random() * 2 - 1
        }
      }));
    
    res.json(filteredData);
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

// Start data generation on server start
startDataGeneration();

// Clean up on server exit
process.on('SIGINT', () => {
  console.log('Stopping data generation');
  if (generationInterval) {
    clearInterval(generationInterval);
  }
  process.exit();
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
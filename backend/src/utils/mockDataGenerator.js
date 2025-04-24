const { computeStressLevel } = require('./stressEvaluator');

// Global variables to store historical data
const dataHistory = [];
const SECONDS_TO_KEEP = 40; // Keep 40 seconds of data for HRV calculation
let previousData = null; // Store the previous reading for smooth transitions

// Track last stress and HRV calculation times
let lastStressCalculationTime = null;
let lastHRVCalculationTime = null;
let lastStressResult = { level: 'calculating...', score: 0 };
let lastHRVValue = null;

// Constants for realistic data generation
const STRESS_CALCULATION_INTERVAL = 15 * 1000; // 15 seconds in milliseconds
const HRV_CALCULATION_INTERVAL = 40 * 1000; // 40 seconds in milliseconds

// Max change allowed between iterations (helps create smoother transitions)
const MAX_HR_CHANGE = 3.0;  // bpm
const MAX_EDA_CHANGE = 0.3; // microsiemens
const MAX_RR_CHANGE = 0.4;  // breaths per minute
const MAX_HRV_CHANGE = 0.2; // ms

// Initial baselines values (will be adjusted on first generation)
const BASELINE = {
  hr: 75,    // Heart rate between 60-100
  eda: 3.0,  // Electrodermal activity between 1-6
  rr: 14.0,  // Respiratory rate between 12-20
  hrv: 1.5   // HRV between 0.5-2.8 (never reaching 3.0)
};

const generateBiometricData = (user = 'default') => {
  if (user === 'johnson') {
    // Generate hardcoded-style readings just for Johnson
    const hr = Math.floor(Math.random() * 10) + 78;
    const eda = 3.8 + Math.random() * 2;
    const hrv = 1.2 + Math.random() * 1.2;
    const rr = 15 + Math.random() * 2;

    const stressLevel = computeStressLevel(hr, eda, hrv, rr);

    return {
      timestamp: new Date().toISOString(),
      hr: hr,
      eda: eda.toFixed(2),
      hrv: hrv.toFixed(2),
      rr: rr.toFixed(1),
      stressLevel: stressLevel.level,
      stressScore: stressLevel.score
    };
  }

  const timestamp = new Date();
  
  // Create a new reading with smoothing if previous data exists
  let newReading = {};
  
  if (previousData) {
    // Generate values within a reasonable range of previous values
    const hrDelta = (Math.random() * 2 - 1) * MAX_HR_CHANGE;
    const edaDelta = (Math.random() * 2 - 1) * MAX_EDA_CHANGE;
    const rrDelta = (Math.random() * 2 - 1) * MAX_RR_CHANGE;
    
    // Calculate new values with constraints
    const hr = Math.max(55, Math.min(110, previousData.hr + hrDelta));
    const eda = Math.max(0.5, Math.min(7.0, parseFloat(previousData.eda) + edaDelta));
    const rr = Math.max(10, Math.min(22, parseFloat(previousData.rr) + rrDelta));
    
    newReading = { timestamp, hr, eda, rr };
  } else {
    // First reading - use baseline with some randomness
    newReading = {
      timestamp,
      hr: BASELINE.hr + (Math.random() * 10 - 5),
      eda: BASELINE.eda + (Math.random() * 1 - 0.5),
      rr: BASELINE.rr + (Math.random() * 2 - 1)
    };
  }

  console.log('New reading generated:', newReading); // Debug log
  dataHistory.push(newReading);
  previousData = newReading; // Store for next iteration

  // Clean up old data (older than 40 seconds)
  const cutoffTime = new Date(timestamp.getTime() - SECONDS_TO_KEEP * 1000);
  while (dataHistory.length > 0 && dataHistory[0].timestamp < cutoffTime) {
    dataHistory.shift();
  }

  // Calculate HRV only if we have enough data
  let hrv = null;
  if (dataHistory.length >= 10) { // Reduced from 40 to make it available sooner
    hrv = calculateHRV(dataHistory);
    lastHRVCalculationTime = timestamp;
    
    // Apply smoothing to HRV if we have a previous value
    if (lastHRVValue !== null) {
      const hrvDelta = (Math.random() * 2 - 1) * MAX_HRV_CHANGE;
      // Ensure HRV never reaches exactly 3.0 (max 2.8)
      hrv = Math.max(0.2, Math.min(2.8, lastHRVValue + hrvDelta));
    }
    
    lastHRVValue = hrv;
  }

  // Calculate averages for stress calculation
  const avgData = calculateAverages(dataHistory);

  // Calculate stress level and score (stressLevel contains the score)
  const stressLevel = computeStressLevel(avgData.hr, avgData.eda, hrv, avgData.rr);

  const result = {
    timestamp: timestamp.toISOString(),
    hr: Math.round(newReading.hr),
    eda: newReading.eda.toFixed(2),
    hrv: hrv === null ? 'calculating...' : hrv.toFixed(2),
    rr: newReading.rr.toFixed(1),
    stressLevel: stressLevel.level,
    stressScore: stressLevel.score
  };

  console.log('Generated biometric data:', result); // Debug log
  return result;
};

// Calculate heart rate variability based on all data points
function calculateHRV(dataPoints) {
  if (dataPoints.length < 2) {
    // Default HRV between 0.5 and 2.8 (never exactly 3.0)
    return Math.random() * 2.3 + 0.5; 
  }
  
  // Calculate RR intervals (time between heartbeats)
  const hrValues = dataPoints.map(point => point.hr);
  
  // Calculate standard deviation of heart rates as a simple proxy for HRV
  const mean = hrValues.reduce((sum, hr) => sum + hr, 0) / hrValues.length;
  const variance = hrValues.reduce((sum, hr) => sum + Math.pow(hr - mean, 2), 0) / hrValues.length;
  const stdDev = Math.sqrt(variance);
  
  // Scale to a more realistic HRV range (0.5 - 2.8), never reaching 3.0
  // This adjustment provides better distribution with higher probability in the middle range
  const rawHRV = (stdDev / 8) * 2.3 + 0.5;
  
  // Ensure the value stays within bounds
  return Math.max(0.5, Math.min(2.8, rawHRV));
}

// Calculate averages of metrics from an array of data points
function calculateAverages(dataPoints) {
  if (dataPoints.length === 0) {
    return {
      hr: BASELINE.hr,
      eda: BASELINE.eda,
      rr: BASELINE.rr
    };
  }
  
  const totals = dataPoints.reduce((acc, point) => {
    return {
      hr: acc.hr + point.hr,
      eda: acc.eda + parseFloat(point.eda || point.eda),
      rr: acc.rr + parseFloat(point.rr || point.rr)
    };
  }, { hr: 0, eda: 0, rr: 0 });
  
  return {
    hr: totals.hr / dataPoints.length,
    eda: totals.eda / dataPoints.length,
    rr: totals.rr / dataPoints.length
  };
}

module.exports = {
  generateBiometricData
};
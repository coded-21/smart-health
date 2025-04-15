// src/utils/mockDataGenerator.js

const { computeStressLevel } = require('./stressEvaluator');

const baselines = {
  hr: { mean: 75, std: 5 },
  hrv: { mean: 1.5, std: 0.5 },
  eda: { mean: 2.5, std: 1.0 },
  rr: { mean: 14, std: 2 }
};

const generateBiometricData = () => {
  const hr = Math.floor(Math.random() * 30) + 70;
  const hrv = Math.random() * 3;
  const eda = Math.random() * 6;
  const rr = Math.random() * 6 + 12;

  const stressResult = computeStressLevel({ hr, hrv, eda, rr }, baselines);

  return {
    timestamp: new Date().toISOString(),
    heartRate: hr,
    hrv,
    skinResponse: eda,
    rr,
    stressScore: stressResult.stressScore,
    stressLevel: stressResult.stressLevel
  };
};

module.exports = { generateBiometricData };

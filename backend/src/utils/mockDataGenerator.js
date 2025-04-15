// Mock data generator for biometric sensors
const { computeStressLevel } = require('./stressEvaluator');


const generateHeartRate = () => {
    // Generate heart rate between 60-100 BPM
    return Math.floor(Math.random() * (100 - 60 + 1)) + 60;
};

const generateSkinResponse = () => {
    // Generate skin response (GSR) between 0-100 microsiemens
    return Math.random() * 100;
};

const generateMotionData = () => {
    // Generate motion data (x, y, z accelerometer values)
    return {
        x: (Math.random() * 2 - 1) * 9.81, // -9.81 to 9.81 m/s²
        y: (Math.random() * 2 - 1) * 9.81,
        z: (Math.random() * 2 - 1) * 9.81
    };
};

const { estimateCognitiveLoad } = require('./loadEstimator');

const baselines = {
  eda: { mean: 2.5, std: 1.0 },
  hr: { mean: 75, std: 5 },
  hrv: { mean: 1.5, std: 0.5 },
  rr: { mean: 14, std: 2 },
  eye: { mean: 0.5, std: 0.1 }, // e.g., fixation dispersion score
  pupil: { mean: 3.8, std: 0.4 }
};

const generateBiometricData = () => {
  const eda = Math.random() * 6;
  const hr = Math.floor(Math.random() * 30) + 70;
  const hrv = Math.random() * 3;
  const rr = Math.random() * 6 + 12;
  const eyeMovementScore = Math.random(); // simulate between 0–1
  const pupilSize = Math.random() * 1.5 + 3.5;
  const motion = generateMotionData();


  const signals = { eda, hr, hrv, rr, eyeMovementScore, pupilSize };
  const { cli, level } = estimateCognitiveLoad(signals, baselines);

  return {
    timestamp: new Date().toISOString(),
    eda,
    hr,
    hrv,
    rr,
    eyeMovementScore,
    pupilSize,
    cognitiveLoadIndex: cli,
    cognitiveLoadLevel: level,
    stressLevel: computeStressLevel(hr, eda, motion)
  };
};


module.exports = {
    generateBiometricData
}; 
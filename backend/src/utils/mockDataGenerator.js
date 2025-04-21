

const { computeStressLevel } = require('./stressEvaluator');

const generateBiometricData = () => {
  const hr = Math.floor(Math.random() * 30) + 70;
  const eda = Math.random() * 6;
  const hrv = Math.random() * 3;
  const rr = Math.random() * 10 + 10;

  // Fix: destructure output to get proper string + score
  const { level, score } = computeStressLevel(hr, eda, hrv, rr);

  console.log('Stress Inputs:', { hr, eda, hrv, rr });
  console.log('Computed Score:', score);

  return {
    timestamp: new Date().toISOString(),
    hr,
    eda,
    hrv,
    rr,
    stressLevel: level,        
    stressScore: score         
  };
};

module.exports = {
  generateBiometricData
};

  
// src/utils/stressEvaluator.js

const computeStressScore = ({ hr, hrv, eda, rr }, baselines) => {
    const z = (val, base) => (val - base.mean) / base.std;
  
    const zHR = z(hr, baselines.hr);
    const zHRV = -z(hrv, baselines.hrv); // lower HRV = higher stress
    const zEDA = z(eda, baselines.eda);
    const zRR = z(rr, baselines.rr);
  
    return 1.2 * zEDA + 1.0 * zHR + 1.0 * zRR + 1.3 * zHRV;
  };
  
  const mapStressScoreToLevel = (score) => {
    if (score > 2.0) return 'high';
    if (score > 0.5) return 'moderate';
    return 'low';
  };
  
  const computeStressLevel = (signals, baselines) => {
    const score = computeStressScore(signals, baselines);
    return {
      stressScore: parseFloat(score.toFixed(2)),
      stressLevel: mapStressScoreToLevel(score)
    };
  };
  
  module.exports = { computeStressLevel };
  
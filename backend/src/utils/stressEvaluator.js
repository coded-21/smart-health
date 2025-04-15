function normalize(value, min, max) {
    return Math.min(Math.max((value - min) / (max - min), 0), 1);
  }
  
  function computeStressScore(hr, eda, hrv, rr) {
    const HR_MIN = 60, HR_MAX = 100;
    const EDA_MIN = 0.5, EDA_MAX = 6.0;
    const HRV_MIN = 0.5, HRV_MAX = 3.0;
    const RR_MIN = 10, RR_MAX = 20;
  
    const hrNorm = normalize(hr, HR_MIN, HR_MAX);
    const edaNorm = normalize(eda, EDA_MIN, EDA_MAX);
    const hrvNorm = normalize(hrv, HRV_MIN, HRV_MAX);
    const rrNorm = normalize(rr, RR_MIN, RR_MAX);
  
    const score =
      0.2 * hrNorm +
      0.2 * edaNorm +
      0.5 * (1 - hrvNorm) + // inverse because lower HRV = more stress
      0.1 * rrNorm;
  
    return score; // raw score between 0 and 1
  }
  
  function computeStressLevel(hr, eda, hrv, rr) {
    const rawScore = computeStressScore(hr, eda, hrv, rr);
    const percentage = Math.round(rawScore * 100); // THIS is for UI
  
    let level;
    if (rawScore >= 0.7) level = 'high';
    else if (rawScore >= 0.5) level = 'elevated';
    else if (rawScore >= 0.3) level = 'normal'
    else if (rawScore >= 0.1) level = 'optimal';
    else level = 'low';
  
    return { level, score: percentage };
  }
  
  module.exports = {
    computeStressLevel,
    computeStressScore
  };
  
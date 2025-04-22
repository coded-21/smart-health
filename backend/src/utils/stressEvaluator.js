function normalize(value, min, max) {
  // Handle null or undefined values
  if (value === null || value === undefined) {
    return null;
  }
  // Handle string values that should be considered as unavailable
  if (typeof value === 'string' && value.toLowerCase().includes('calculating')) {
    return null;
  }
  
  return Math.min(Math.max((value - min) / (max - min), 0), 1);
}

function computeStressScore(hr, eda, hrv, rr) {
  // Define biometric ranges for normalization
  const HR_MIN = 60, HR_MAX = 100;
  const EDA_MIN = 0.5, EDA_MAX = 6.0;
  const HRV_MIN = 0.5, HRV_MAX = 3.0;
  const RR_MIN = 10, RR_MAX = 20;

  // Normalize available values to 0-1 range
  const hrNorm = normalize(hr, HR_MIN, HR_MAX);
  const edaNorm = normalize(eda, EDA_MIN, EDA_MAX);
  const hrvNorm = normalize(hrv, HRV_MIN, HRV_MAX);
  const rrNorm = normalize(rr, RR_MIN, RR_MAX);

  // Track available metrics and their total weight
  let availableMetrics = 0;
  let totalWeight = 0;
  let weightedSum = 0;
  
  // Add each available metric with its weight
  if (hrNorm !== null) {
    weightedSum += 0.2 * hrNorm;
    totalWeight += 0.2;
    availableMetrics++;
  }
  
  if (edaNorm !== null) {
    weightedSum += 0.2 * edaNorm;
    totalWeight += 0.2;
    availableMetrics++;
  }
  
  if (hrvNorm !== null) {
    // Note: HRV is inversely related to stress (lower HRV = higher stress)
    weightedSum += 0.5 * (1 - hrvNorm);
    totalWeight += 0.5;
    availableMetrics++;
  }
  
  if (rrNorm !== null) {
    weightedSum += 0.1 * rrNorm;
    totalWeight += 0.1;
    availableMetrics++;
  }
  
  // If no metrics are available, return null
  if (availableMetrics === 0 || totalWeight === 0) {
    return null;
  }
  
  // Calculate normalized score based on available metrics
  const score = weightedSum / totalWeight;
  
  return score; // raw score between 0 and 1, or null if no data
}

function computeStressLevel(hr, eda, hrv, rr) {
  const rawScore = computeStressScore(hr, eda, hrv, rr);
  
  // Handle the case where not enough data is available
  if (rawScore === null) {
    return { level: 'calculating...', score: 0 };
  }
  
  const percentage = Math.round(rawScore * 100); // Convert to percentage for UI display as an integer
  
  // New stress level thresholds: 0-25 low, 25-50 medium, 50-75 high, 75-100 very high
  let level;
  if (percentage >= 75) level = 'high';
  else if (percentage >= 50) level = 'medium';
  else if (percentage >= 25) level = 'low';
  else level = 'rest';

  return { level, score: percentage };
}

// New function to analyze trend in stress levels
function analyzeStressTrend(dataPoints, timeWindowSeconds = 60) {
  if (dataPoints.length < 2) {
    return { trend: 'stable', changeRate: 0 };
  }
  
  // Filter to get only data from the specified time window
  const now = new Date();
  const cutoff = new Date(now.getTime() - timeWindowSeconds * 1000);
  
  const relevantData = dataPoints.filter(
    point => new Date(point.timestamp) >= cutoff
  ).sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  
  if (relevantData.length < 2) {
    return { trend: 'stable', changeRate: 0 };
  }
  
  // Calculate linear regression to determine trend
  const scores = relevantData.map(point => point.stressScore);
  const times = relevantData.map(point => new Date(point.timestamp).getTime() / 1000); // convert to seconds
  
  const n = scores.length;
  const startTime = times[0];
  
  // Normalize times to be relative to start time
  const normalizedTimes = times.map(t => t - startTime);
  
  // Calculate slope of the trend line
  let sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
  for (let i = 0; i < n; i++) {
    sumX += normalizedTimes[i];
    sumY += scores[i];
    sumXY += normalizedTimes[i] * scores[i];
    sumX2 += normalizedTimes[i] * normalizedTimes[i];
  }
  
  const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  
  // Determine trend based on slope
  let trend;
  if (Math.abs(slope) < 0.1) trend = 'stable';
  else if (slope > 0) trend = 'increasing';
  else trend = 'decreasing';
  
  return { trend, changeRate: slope };
}

module.exports = {
  computeStressLevel,
  computeStressScore,
  analyzeStressTrend
};
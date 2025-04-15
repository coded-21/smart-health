// Simple Z-score function
const z = (x, mean, std) => (x - mean) / std;

// Feature-weighted cognitive load index
const computeCognitiveLoadIndex = (signals, baselines) => {
  const {
    eda, // SCR peaks per minute
    hr, // beats per minute
    hrv, // LF/HF ratio or RMSSD
    rr, // breaths per minute
    eyeMovementScore, // normalized metric: lower = more focused (e.g. fixation duration)
    pupilSize // mm
  } = signals;

  const weights = {
    eda: 1.2,
    hr: 1.0,
    hrv: -1.3, // lower HRV = higher stress
    rr: 1.0,
    eye: -1.0, // less movement = more load
    pupil: 1.4
  };

  const cli =
    weights.eda * z(eda, baselines.eda.mean, baselines.eda.std) +
    weights.hr * z(hr, baselines.hr.mean, baselines.hr.std) +
    weights.hrv * z(hrv, baselines.hrv.mean, baselines.hrv.std) +
    weights.rr * z(rr, baselines.rr.mean, baselines.rr.std) +
    weights.eye * z(eyeMovementScore, baselines.eye.mean, baselines.eye.std) +
    weights.pupil * z(pupilSize, baselines.pupil.mean, baselines.pupil.std);

  return cli;
};

const classifyLoadLevel = (cli) => {
  if (cli < 0) return 'low';
  if (cli < 1.5) return 'moderate';
  if (cli < 2.5) return 'high';
  return 'very high';
};

const estimateCognitiveLoad = (signals, baselines) => {
  const cli = computeCognitiveLoadIndex(signals, baselines);
  const level = classifyLoadLevel(cli);
  return { cli: Number(cli.toFixed(2)), level };
};

module.exports = { estimateCognitiveLoad };


const computeStressLevel = (heartRate, skinResponse, motion) => {
    let stressIndicators = 0;

    if (heartRate > 90) stressIndicators++;
    if (skinResponse > 70) stressIndicators++;

    const motionMagnitude = Math.sqrt(
        motion.x ** 2 + motion.y ** 2 + motion.z ** 2
    );
    if (motionMagnitude > 12) stressIndicators++;

    if (stressIndicators >= 2) return 'high';
    if (stressIndicators === 1) return 'moderate';
    return 'low';
};

module.exports = {
    computeStressLevel
};

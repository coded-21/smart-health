// Mock data generator for biometric sensors

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

const generateBiometricData = () => {
    return {
        timestamp: new Date().toISOString(),
        heartRate: generateHeartRate(),
        skinResponse: generateSkinResponse(),
        motion: generateMotionData()
    };
};

module.exports = {
    generateBiometricData
}; 
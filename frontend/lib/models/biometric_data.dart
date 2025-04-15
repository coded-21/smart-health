class BiometricData {
  final DateTime timestamp;
  final int heartRate;
  final double skinResponse;
  final String stressLevel;
  final String cognitiveLoadLevel;
  final double cognitiveLoadIndex;
  final double hrv;
  final double rr;
  final double eyeMovementScore;
  final double pupilSize;


  BiometricData({
    required this.timestamp,
    required this.heartRate,
    required this.skinResponse,
    required this.stressLevel,
    required this.cognitiveLoadLevel,
    required this.cognitiveLoadIndex,
    required this.hrv,
    required this.rr,
    required this.eyeMovementScore,
    required this.pupilSize,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) {
    return BiometricData(
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['hr'],
      skinResponse: (json['eda'] as num).toDouble(),
      stressLevel: json['stressLevel'] ?? 'unknown',
      cognitiveLoadLevel: json['cognitiveLoadLevel'] ?? 'unknown',
      cognitiveLoadIndex: (json['cognitiveLoadIndex'] as num).toDouble(),
      hrv: (json['hrv'] as num).toDouble(),
      rr: (json['rr'] as num).toDouble(),
      eyeMovementScore: (json['eyeMovementScore'] as num).toDouble(),
      pupilSize: (json['pupilSize'] as num).toDouble(),
    );
  }
}


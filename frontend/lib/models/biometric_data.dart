class BiometricData {
  final DateTime timestamp;
  final int heartRate;
  final double skinResponse;
  final double hrv;
  final double rr;
  final String stressLevel;
  final int stressScore;

  BiometricData({
    required this.timestamp,
    required this.heartRate,
    required this.skinResponse,
    required this.hrv,
    required this.rr,
    required this.stressLevel,
    required this.stressScore,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) {
    return BiometricData(
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['hr'] ?? 0,
      skinResponse: json['eda'] is String
          ? double.parse(json['eda'])
          : (json['eda'] ?? 0).toDouble(), // Handle both String and numeric cases
      hrv: json['hrv'] is String
          ? double.parse(json['hrv'])
          : (json['hrv'] ?? 0).toDouble(), // Handle both String and numeric cases
      rr: json['rr'] is String
          ? double.parse(json['rr'])
          : (json['rr'] ?? 0).toDouble(), // Handle both String and numeric cases
      stressLevel: json['stressLevel'] ?? 'low',
      stressScore: json['stressScore'] ?? 0,
    );
  }
}


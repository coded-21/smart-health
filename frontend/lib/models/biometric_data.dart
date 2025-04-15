class BiometricData {
  final DateTime timestamp;
  final int heartRate;
  final double skinResponse;
  final double hrv;
  final double rr;
  final String stressLevel;
  final double stressScore;

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
      heartRate: json['heartRate'],
      skinResponse: json['skinResponse'],
      hrv: json['hrv'],
      rr: json['rr'],
      stressLevel: json['stressLevel'],
      stressScore: json['stressScore'].toDouble(),
    );
  }
}


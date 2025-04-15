import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StressRing extends StatelessWidget {
  final int score;
  final String label; // 👈 NEW

  const StressRing({
    super.key,
    required this.score,
    required this.label, // 👈 NEW
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 80.0,
          lineWidth: 10.0,
          percent: (score.clamp(0, 100) / 100),
          center: Text('$score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          progressColor: Colors.amber,
          backgroundColor: Colors.grey.shade300,
          animation: true,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16)),

      ],
    );
  }
}

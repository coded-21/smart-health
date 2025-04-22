import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StressRing extends StatelessWidget {
  final int score; // 0–100 range
  final String label;
  final Color color;

  const StressRing({
    super.key,
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: score.toDouble()),
          duration: const Duration(seconds: 1), // Smooth animation duration
          builder: (context, animatedScore, _) {
            return CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 10.0,
              percent: (animatedScore.clamp(0, 100)) / 100,
              center: Text(
                '${animatedScore.toInt()}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              progressColor: color,
              backgroundColor: Colors.grey.shade300,
              animation: false, // Disable internal animation
            );
          },
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

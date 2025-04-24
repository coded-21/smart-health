// lib/widgets/squad_view.dart or lib/screens/squad_view.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SquadMember {
  final String name;
  final String initials;
  int stressLevel;
  Color color;

  SquadMember(this.name, this.initials, this.stressLevel)
      : color = _getColor(stressLevel);

  void updateStress() {
    stressLevel += Random().nextInt(11) - 5; // ±5 fluctuation
    stressLevel = stressLevel.clamp(0, 100);
    color = _getColor(stressLevel);
  }

  static Color _getColor(int stress) {
    if (stress >= 75) return Colors.red;
    if (stress >= 50) return Colors.orange;
    if (stress >= 25) return Colors.yellow;
    return Colors.green;
  }
}

class SquadView extends StatefulWidget {
  const SquadView({super.key});

  @override
  State<SquadView> createState() => _SquadViewState();
}

class _SquadViewState extends State<SquadView> {
  late List<SquadMember> members;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    members = [
      SquadMember("Johnson D.", "JD", 87),
      SquadMember("Miller S.", "MS", 62),
      SquadMember("Rodriguez B.", "RB", 23),
      SquadMember("Thompson L.", "TL", 58),
      SquadMember("Kim P.", "KP", 45),
      SquadMember("Garcia H.", "GH", 42),
      SquadMember("Wilson M.", "WM", 79),
      SquadMember("Chen A.", "CA", 28),
    ];
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        for (final m in members) {
          m.updateStress();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text("Squad Stress Overview", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 200), //  this adds side padding to the entire grid
            child: GridView.count(
              crossAxisCount: 4, // 4 per row
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: members.map(_buildCard).toList(),
            ),
          ),
        ),
      ],
    ),
  );
  }


  Widget _buildCard(SquadMember m) {
  return Card(
    elevation: 2,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.black, width: 1), // ⬅Black border
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20, // smaller avatar
            backgroundColor: m.color,
            child: Text(
              m.initials,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          Text(
            '${m.stressLevel}% Stress',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
}


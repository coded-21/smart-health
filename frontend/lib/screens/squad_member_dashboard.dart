import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/stress_ring.dart';
import '../widgets/signal_card.dart';
import '../widgets/alert_card.dart';
import '../models/biometric_data.dart';
import 'squad_view.dart'; // for SquadMember
double? _smoothedStress;
BiometricData? _data;
Timer? _timer;


class SquadMemberDashboard extends StatefulWidget {
  final SquadMember member;

  const SquadMemberDashboard({super.key, required this.member});

  @override
  State<SquadMemberDashboard> createState() => _SquadMemberDashboardState();
}

class _SquadMemberDashboardState extends State<SquadMemberDashboard> {
  BiometricData? _data;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.member.name == "Johnson D.") {
      _fetchBiometricData();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchBiometricData());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBiometricData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/biometric-data?user=johnson'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _data = BiometricData.fromJson(json.decode(response.body));

          final target = _data!.stressScore.toDouble();
          _smoothedStress = _smoothedStress == null
              ? target
              : (_smoothedStress! * 0.7 + target * 0.3); // smoothing / damping
        });

      }
    } catch (e) {
      print('Error fetching Johnson data: $e');
    }
  }

  Color getStressColor(int level) {
    if (level >= 75) return Colors.redAccent;
    if (level >= 50) return Colors.orangeAccent;
    if (level >= 30) return Colors.blueAccent;
    if (level >= 10) return Colors.greenAccent;
    return Colors.yellowAccent;
  }

  String getStressLabel(int level) {
    if (level >= 75) return 'high';
    else if (level >= 50) return 'elevated';
    else if (level >= 30) return 'normal';
    else if (level >= 10) return 'optimal';
    return 'rest';
  }

  @override
  Widget build(BuildContext context) {
    final isJohnson = widget.member.name == "Johnson D.";

    final stressLevel = isJohnson ? _data?.stressScore ?? 0 : widget.member.stressLevel;
    final stressLabel = isJohnson
        ? (_data?.stressLevel.toUpperCase() ?? "LOADING")
        : getStressLabel(widget.member.stressLevel);
    final stressColor = isJohnson
        ? _data == null
            ? Colors.grey
            : getStressColor(_data!.stressScore)
        : getStressColor(widget.member.stressLevel);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.member.name}'s Dashboard")),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (stressLevel >= 75) ...[
                AlertCard(
                  icon: Icons.warning_amber_rounded,
                  title: "Elevated Stress Level",
                  message: "Member is at risk of cognitive overload.",
                ),
                const SizedBox(height: 20),
              ],
              StressRing(
                score: isJohnson
                    ? _smoothedStress?.round() ?? 0
                    : widget.member.stressLevel,
                label: "Stress: $stressLabel",
                color: stressColor,
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SignalCard(
                      icon: Icons.favorite,
                      value: isJohnson
                          ? '${_data?.heartRate ?? "--"}'
                          : "${60 + widget.member.stressLevel % 40}",
                      label: 'Heart Rate (BPM)',
                      background: const Color(0xFFE8F5E9),
                    ),
                    SignalCard(
                      icon: Icons.water_drop,
                      value: isJohnson
                          ? (_data?.skinResponse.toStringAsFixed(2) ?? "--")
                          : (1.0 + widget.member.stressLevel / 100 * 4.0).toStringAsFixed(2),
                      label: 'Skin Response (µS)',
                      background: const Color(0xFFFFFDE7),
                    ),
                    SignalCard(
                      icon: Icons.line_axis,
                      value: isJohnson
                          ? (_data?.hrv.toStringAsFixed(2) ?? "--")
                          : (1.2 + (100 - widget.member.stressLevel) / 50).toStringAsFixed(2),
                      label: 'HRV (LF/HF)',
                      background: const Color(0xFFE3F2FD),
                    ),
                    SignalCard(
                      icon: Icons.air,
                      value: isJohnson
                          ? (_data?.rr.toStringAsFixed(1) ?? "--")
                          : (12.0 + widget.member.stressLevel / 10).toStringAsFixed(1),
                      label: 'Respiration Rate (bpm)',
                      background: const Color(0xFFFFEBEE),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/biometric_data.dart';
import '../widgets/stress_ring.dart';
import '../widgets/signal_card.dart';
import '../widgets/alert_card.dart';
import '../screens/squad_view.dart'; 
import '../screens/weapon_indicator.dart'; 

bool _showSquadView = false;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ValueNotifier<BiometricData?> _dataNotifier = ValueNotifier<BiometricData?>(null);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBiometricData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchBiometricData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dataNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchBiometricData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/biometric-data'));
      if (response.statusCode == 200) {
        final data = BiometricData.fromJson(json.decode(response.body));
        _dataNotifier.value = data; // Update the ValueNotifier
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Smart Health Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showSquadView ? Icons.dashboard : Icons.group),
            tooltip: 'Toggle Squad View',
            onPressed: () {
              setState(() {
                _showSquadView = !_showSquadView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.square),
            tooltip: 'View Weapon Indicator',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeaponIndicator(color: getStressColor(_dataNotifier.value?.stressLevel ?? 'low')),
                ),
              );
            },
          ),
        ],
      ),

      body: _showSquadView
        ? SquadView() // new widget you'll create
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [ 
            
            // Static UI (doesn't rebuild)
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Alerts", style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 12),
            

            // Dynamic UI (rebuilds only when data changes)
            ValueListenableBuilder<BiometricData?>(
              valueListenable: _dataNotifier,
              builder: (context, data, _) {
                if (data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    if (data.stressLevel.toLowerCase() == 'high') ...[
                      AlertCard(
                        icon: Icons.warning_amber_rounded,
                        title: "Elevated Stress Level",
                        message: "Exercise caution & de-escalate stress",
                      ),
                      const SizedBox(height: 32),
                    ],
                    StressRing(
                      score: data.stressScore,
                      label: 'Stress: ${data.stressLevel.toUpperCase()}',
                      color: getStressColor(data.stressLevel),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SignalCard(
                          icon: Icons.favorite,
                          value: '${data.heartRate}',
                          label: 'Heart Rate (BPM)',
                          background: const Color(0xFFE8F5E9),
                        ),
                        SignalCard(
                          icon: Icons.water_drop,
                          value: data.skinResponse.toStringAsFixed(2),
                          label: 'Skin Response (µS)',
                          background: const Color(0xFFFFFDE7),
                        ),
                        SignalCard(
                          icon: Icons.line_axis,
                          value: data.hrv.toStringAsFixed(2),
                          label: 'HRV (LF/HF)',
                          background: const Color(0xFFE3F2FD),
                        ),
                        SignalCard(
                          icon: Icons.air,
                          value: data.rr.toStringAsFixed(1),
                          label: 'Respiration Rate (bpm)',
                          background: const Color(0xFFFFEBEE),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color getStressColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return const Color.fromARGB(255, 231, 226, 70);
      case 'low':
        return const Color.fromARGB(255, 57, 192, 16);
      case 'rest':
        return const Color.fromARGB(255, 201, 159, 34);
      default:
        return const Color.fromARGB(255, 60, 60, 60);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/biometric_data.dart';
import '../widgets/stress_ring.dart';
import '../widgets/signal_card.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BiometricData? _data;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBiometricData();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _fetchBiometricData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBiometricData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/biometric-data'));
      if (response.statusCode == 200) {
        setState(() {
          _data = BiometricData.fromJson(json.decode(response.body));
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Smart Health Dashboard"),
        centerTitle: true,
      ),
      body: _isLoading || _data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Date + Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_data!.timestamp.toLocal().toString().substring(0, 10),
                          style: const TextStyle(fontSize: 18)),
                      Text(_data!.timestamp.toLocal().toString().substring(11, 16),
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StressRing(
                        score: (_data!.cognitiveLoadIndex * 25).clamp(0, 100).toInt(),
                        label: 'Cognitive Load',
                      ),
                      StressRing(
                        score: _data!.stressLevel.toLowerCase() == 'high'
                            ? 100
                            : _data!.stressLevel.toLowerCase() == 'moderate'
                                ? 60
                                : 25,
                        label: 'Stress Level',
                      ),
                    ],
                  ),


                  const SizedBox(height: 20),

                  // Text(
                  //   'Cognitive Load: ${_data!.cognitiveLoadLevel.toUpperCase()}',
                  //   style: Theme.of(context).textTheme.titleMedium,
                  // ),

                  // Text(
                  //   'Load Score (CLI): ${_data!.cognitiveLoadIndex.toStringAsFixed(2)}',
                  //   style: Theme.of(context).textTheme.bodySmall,
                  // ),

                  // Signal Cards
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SignalCard(
                        icon: Icons.favorite,
                        value: '${_data!.heartRate}',
                        label: 'Heart Rate (BPM)',
                        background: const Color(0xFFE8F5E9),
                      ),
                      SignalCard(
                        icon: Icons.water_drop,
                        value: _data!.skinResponse.toStringAsFixed(2),
                        label: 'Skin Response (µS)',
                        background: const Color(0xFFFFFDE7),
                      ),
                      SignalCard(
                        icon: Icons.line_axis,
                        value: _data!.hrv.toStringAsFixed(2),
                        label: 'HRV (LF/HF)',
                        background: const Color(0xFFE3F2FD),
                      ),
                      SignalCard(
                        icon: Icons.air,
                        value: _data!.rr.toStringAsFixed(1),
                        label: 'Respiration Rate (bpm)',
                        background: const Color(0xFFFFEBEE),
                      ),
                      SignalCard(
                        icon: Icons.visibility,
                        value: _data!.eyeMovementScore.toStringAsFixed(2),
                        label: 'Eye Movement',
                        background: const Color(0xFFEDE7F6),
                      ),
                      SignalCard(
                        icon: Icons.remove_red_eye,
                        value: _data!.pupilSize.toStringAsFixed(2),
                        label: 'Pupil Size (mm)',
                        background: const Color(0xFFFFF3E0),
                      ),
                      
                    ],
                  ),


                  const SizedBox(height: 32),

                  // Alerts
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Alerts", style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  const AlertCard(
                    icon: Icons.location_on,
                    title: "Location Change",
                    message: "Change location to *new location* in 15 minutes",
                  ),
                  const AlertCard(
                    icon: Icons.warning_amber_rounded,
                    title: "Elevated Stress Level",
                    message: "Exercise caution & de-escalate stress",
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/biometric_data.dart';
import 'widgets/stress_chart.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const SmartHealthApp());
}

class SmartHealthApp extends StatelessWidget {
  const SmartHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Health',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class BiometricDataScreen extends StatefulWidget {
  const BiometricDataScreen({super.key});

  @override
  State<BiometricDataScreen> createState() => _BiometricDataScreenState();
}

class _BiometricDataScreenState extends State<BiometricDataScreen> {
  Map<String, dynamic>? _biometricData;
  bool _isLoading = false;

  Future<void> _fetchBiometricData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/biometric-data'));
      if (response.statusCode == 200) {
        setState(() {
          _biometricData = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBiometricData();
    // Refresh data every 1 seconds
    Future.delayed(const Duration(seconds: 1), _fetchBiometricData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Health Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBiometricData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _biometricData == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDataCard(
                        'Heart Rate',
                        '${_biometricData!['heartRate']} BPM',
                        Icons.favorite,
                        Colors.red,
                      ),
                      const SizedBox(height: 16),
                      _buildDataCard(
                        'Skin Response',
                        '${_biometricData!['skinResponse'].toStringAsFixed(2)} µS',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildDataCard(
                        'Motion',
                        'X: ${_biometricData!['motion']['x'].toStringAsFixed(2)} m/s²\n'
                        'Y: ${_biometricData!['motion']['y'].toStringAsFixed(2)} m/s²\n'
                        'Z: ${_biometricData!['motion']['z'].toStringAsFixed(2)} m/s²',
                        Icons.rotate_right,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Last Updated: ${_biometricData!['timestamp']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Text('Stress Trend (Past 10 Readings)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      FutureBuilder<List<BiometricData>>(
                        future: fetchStressHistory(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No stress history available');
                          } else {
                            return StressChart(data: snapshot.data!);
                          }
                        },
                      ),

                    ],
                  ),
                ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 


Future<List<BiometricData>> fetchStressHistory() async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/biometric-data/history'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BiometricData.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load stress data');
  }
}

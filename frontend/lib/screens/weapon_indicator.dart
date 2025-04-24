import 'package:flutter/material.dart';

class WeaponIndicator extends StatelessWidget {
  final Color color;

  const WeaponIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Square"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          color: color,
        ),
      ),
    );
  }
}
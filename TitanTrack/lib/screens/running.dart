import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/glass_card.dart';

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  double _totalDistance = 0.0;
  bool _isTracking = false;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;

  // 1. Request Permission & Start Tracking
  void _toggleTracking() async {
    if (_isTracking) {
      _positionStream?.cancel();
      setState(() => _isTracking = false);
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    setState(() => _isTracking = true);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      if (_lastPosition != null) {
        // Calculate distance between last point and current point
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude,
        );
        setState(() {
          _totalDistance += distance;
        });
      }
      _lastPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RUN & EARN")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            GlassCard(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("TOTAL DISTANCE", style: TextStyle(color: Colors.white60)),
                  Text("${(_totalDistance / 1000).toStringAsFixed(2)} KM", 
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF00FF99))),
                  const SizedBox(height: 10),
                  Text("POINTS: ${(_totalDistance / 10).toStringAsFixed(0)}", 
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 18)),
                ],
              ),
            ),
            const Spacer(),
            // Start/Stop Button
            GestureDetector(
              onTap: _toggleTracking,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _isTracking ? Colors.redAccent : const Color(0xFF00FF99),
                child: Icon(_isTracking ? Icons.stop : Icons.play_arrow, size: 50, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Text(_isTracking ? "TRACKING LIVE..." : "TAP TO START", style: const TextStyle(letterSpacing: 2)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
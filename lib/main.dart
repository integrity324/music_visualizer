import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MusicVisualizerApp());
}

class MusicVisualizerApp extends StatelessWidget {
  const MusicVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Music Visualizer',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';

class ItaxAllPage extends StatefulWidget {
  const ItaxAllPage({super.key});

  @override
  State<ItaxAllPage> createState() => _ItaxAllPageState();
}

class _ItaxAllPageState extends State<ItaxAllPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Welcome',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

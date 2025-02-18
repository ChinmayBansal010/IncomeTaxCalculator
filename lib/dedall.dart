import 'package:flutter/material.dart';

class DedAllPage extends StatefulWidget {
  const DedAllPage({super.key});

  @override
  State<DedAllPage> createState() => _DedAllPageState();
}

class _DedAllPageState extends State<DedAllPage> {
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

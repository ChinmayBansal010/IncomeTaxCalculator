import 'package:flutter/material.dart';

class ExportAll extends StatefulWidget {
  const ExportAll({super.key});

  @override
  State<ExportAll> createState() => _ExportAllState();
}

class _ExportAllState extends State<ExportAll> {
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

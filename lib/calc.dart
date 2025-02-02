import 'package:flutter/material.dart';

class CalcArrearPage extends StatefulWidget {
  const CalcArrearPage({super.key});

  @override
  State<CalcArrearPage> createState() => _CalcArrearPageState();
}

class _CalcArrearPageState extends State<CalcArrearPage> {
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

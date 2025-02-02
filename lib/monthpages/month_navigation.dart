import 'package:flutter/material.dart';
import 'month_update.dart';
import 'package:flutter/foundation.dart';

class MonthNavigationPage extends StatelessWidget {
  final String biometricId;

  const MonthNavigationPage({required this.biometricId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.calendar_month, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            const Text('MONTH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildResponsiveGrid(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    int columnCount;
    if (screenWidth > 1200) {
      columnCount = 3; // 3 columns for wide screens
    } else if (screenWidth > 800) {
      columnCount = 2; // 2 columns for medium screens
    } else {
      columnCount = 1; // 1 column for small screens
    }

    final List<String> labels = [
      'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST',
      'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER', 'JANUARY', 'FEBRUARY'
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 4, // Controls button width-to-height ratio
      ),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        return _createMenuButton(labels[index], () {
          String shortMonth = _getShortMonthName(index + 1);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonthDataPage(
                biometricId: biometricId,
                shortMonth: shortMonth,
                longMonth: labels[index],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _createMenuButton(String label, VoidCallback onPressed) {
    return HoverButton(label: label, onPressed: onPressed);
  }

  // Short month names for navigation
  String _getShortMonthName(int month) {
    const shortMonths = [
      'mar', 'apr', 'may', 'jun', 'jul', 'aug',
      'sept', 'oct', 'nov', 'dec', 'jan', 'feb'
    ];
    return shortMonths[month - 1];
  }
}

class HoverButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const HoverButton({required this.label, required this.onPressed, super.key});

  @override
  HoverButtonState createState() => HoverButtonState();
}

class HoverButtonState extends State<HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Only apply MouseRegion on Web (or desktop)
      return MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isHovered ? Colors.blueAccent : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Android/iOS-specific behavior
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black54],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

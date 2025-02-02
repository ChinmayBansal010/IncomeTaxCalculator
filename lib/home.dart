import 'package:flutter/material.dart';
import 'main.dart';
import 'main_data.dart';
import 'da.dart';
import 'month_data.dart';
import 'itax.dart';
import 'itaxall.dart';
import 'arrear_data.dart';
import 'deduction_data.dart';
import 'tax.dart';
import 'calc.dart';
import 'exportall.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            const Text('HOME', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"), // Add your background image here
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

    final labels = [
      "MAIN",
      "DA%",
      "MONTH",
      "ARREAR",
      "DEDUCTION",
      "ITAX FORM",
      "ITAX EXPORT",
      "TAX EXPORT",
      "CALC",
      "EXPORT ALL",
      "LOGOUT"
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
          _navigateToPage(labels[index], context);
        });
      },
    );
  }

  void _navigateToPage(String label, BuildContext context) {
    switch (label) {
      case "MAIN":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainDataPage()));
        break;
      case "DA%":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DaPage()));
        break;
      case "MONTH":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthDataPage()));
        break;
      case "ARREAR":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ArrearPage()));
        break;
      case "DEDUCTION":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeductionPage()));
        break;
      case "ITAX FORM":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ItaxPage()));
        break;
      case "ITAX EXPORT":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ItaxAllPage()));
        break;
      case "TAX EXPORT":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TaxPage()));
        break;
      case "CALC":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalcArrearPage()));
        break;
      case "EXPORT ALL":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ExportAll()));
        break;
      case "LOGOUT":
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        break;
    }
  }

  Widget _createMenuButton(String label, VoidCallback onPressed) {
    return HoverButton(label: label, onPressed: onPressed);
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

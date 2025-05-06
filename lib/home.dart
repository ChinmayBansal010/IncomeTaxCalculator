import 'package:flutter/material.dart';
import 'package:incometax/shared.dart';
import 'package:incometax/tds.dart';
import 'main.dart';
import 'main_data.dart';
import 'da.dart';
import 'month_data.dart';
import 'itax.dart';
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
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.home, size: 24, color: Colors.black),
            SizedBox(width: 8),
            Text('HOME - ${sharedData.ccurrentYear}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"), // Background image
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
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
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
      "TAX EXPORT",
      "ARREAR - CALC",
      "EXPORT ALL",
      "TDS",
      "TDS - 0",
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

  Future<void> _navigateToPage(String label, BuildContext context) async{
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
      case "TAX EXPORT":
        setState(() => _isLoading = true);
        try {
          await createExcel();
        } catch (e) {
          if (!mounted) return;
          _showErrorSnackbar(e.toString());
        } finally {
          setState(() => _isLoading = false);
        }
        break;
      case "ARREAR - CALC":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalcArrearPage()));
        break;
      case "EXPORT ALL":
        setState(() => _isLoading = true);
        try {
          await exportAll();
        } catch (e) {
          if (!mounted) return;
          _showErrorSnackbar(e.toString());
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
        break;
      case "TDS":
        setState(() => _isLoading = true);
        try {
          await exportExcel(false);
        } catch (e) {
          if (!mounted) return;
          _showErrorSnackbar(e.toString());
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      case "TDS - 0":
        setState(() => _isLoading = true);
        try {
          await exportExcel(true);
        } catch (e) {
          if (!mounted) return;
          _showErrorSnackbar(e.toString());
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      case "LOGOUT":
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        break;
    }
  }

  Widget _createMenuButton(String label, VoidCallback onPressed) {
    return HoverButton(label: label, onPressed: onPressed);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed: $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {}, // Optionally handle 'OK' action
        ),
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';
import 'package:quiver/iterables.dart';

class DaPage extends StatefulWidget {
  const DaPage({super.key});
  @override
  State<DaPage> createState() => _DaPageState();
}

class _DaPageState extends State<DaPage> with TickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> months = [
    "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER",
    "OCTOBER", "NOVEMBER", "DECEMBER", "JANUARY", "FEBRUARY"
  ];
  final List<String> shortMonths = [
    "mar", "apr", "may", "jun", "jul", "aug", "sept", "oct", "nov", "dec", "jan", "feb"
  ];
  final List<String> fields = ["DA", "HRA", "NPA"];

  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference daRef = database.child(sharedData.userPlace).child('percentage');

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    for (var month in months) {
      for (var field in fields) {
        _controllers["$month-$field"] = TextEditingController(text: "0");
      }
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DataSnapshot snapshot = await daRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        for (var month in zip([shortMonths, months])) {
          for (var field in fields) {
            String key = "${month[0]}${field[0].toLowerCase()}";

            if (data[key] != null) {
              _controllers["${month[1]}-$field"]?.text = data[key].toString();
            }
          }
        }
        if (mounted) {
          _animationController.forward(from: 0.0);
        }
      } else {
        if (mounted) {
          _showModernSnackbar("No Data Found", Icons.info_outline_rounded, const Color(0xFF3B82F6));
          _animationController.forward(from: 0.0);
        }
      }
    } catch (e) {
      if (mounted) {
        _showModernSnackbar("Failed to fetch data: $e", Icons.error_outline_rounded, const Color(0xFFEF4444));
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void resetFields() {
    setState(() {
      _controllers.forEach((key, controller) => controller.text = "0");
    });
  }

  void saveData() async {
    if (checkYearFrozenAndShowDialog(context)) return;
    bool isValid = true;
    _controllers.forEach((key, controller) {
      int? value = int.tryParse(controller.text);
      if (value == null || value < 0 || value > 100) {
        isValid = false;
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                strokeWidth: 3,
              ),
              SizedBox(width: 24),
              Text(
                "Updating Rates...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ),
    );

    if (isValid) {
      try {
        Map<String, dynamic> daData = {};
        for (var month in zip([shortMonths, months])) {
          daData["${month[0]}d"] = _controllers["${month[1]}-DA"]!.text;
          daData["${month[0]}h"] = _controllers["${month[1]}-HRA"]!.text;
          daData["${month[0]}n"] = _controllers["${month[1]}-NPA"]!.text;
        }
        await daRef.set(daData);

        if (mounted) {
          Navigator.pop(context);
          _showResultDialog(
            "Success",
            "Percentage data has been successfully updated.",
            Icons.check_circle_rounded,
            const Color(0xFF10B981),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          _showResultDialog(
            "Error",
            "Failed to add data: \n$e",
            Icons.error_rounded,
            const Color(0xFFEF4444),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        _showResultDialog(
          "Invalid Input",
          "All values must be valid numbers between 0 and 100.",
          Icons.warning_rounded,
          const Color(0xFFF59E0B),
        );
      }
    }
  }

  void _showResultDialog(String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showModernSnackbar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
        title: Text(
          "Allowance Rates Formulation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 16 : 20,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: isMobile ? 110 : 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: isMobile
                      ? const EdgeInsets.fromLTRB(12, 10, 12, 16)
                      : const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Icon(Icons.percent_rounded, color: Colors.white, size: isMobile ? 20 : 28),
                      ),
                      SizedBox(width: isMobile ? 12 : 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DA, HRA & NPA Rates",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Configure monthly percentages for accurate calculations",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 11 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: GridView.builder(
                        padding: isMobile
                            ? const EdgeInsets.fromLTRB(10, 0, 10, 80)
                            : const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isMobile ? 600 : 380,
                          mainAxisExtent: isMobile ? 105 : 160,
                          crossAxisSpacing: isMobile ? 8 : 20,
                          mainAxisSpacing: isMobile ? 8 : 20,
                        ),
                        itemCount: months.length,
                        itemBuilder: (context, index) {
                          final delay = (index * 0.05).clamp(0.0, 1.0);
                          final animation = CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
                          );

                          return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: _buildMonthCard(months[index], isMobile),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              padding: isMobile
                  ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
                  : const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: resetFields,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 18),
                            side: const BorderSide(color: Color(0xFFFECACA), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
                            backgroundColor: const Color(0xFFFEF2F2),
                          ),
                          icon: Icon(Icons.refresh_rounded, size: isMobile ? 16 : 20),
                          label: Text(
                            isMobile ? "RESET" : "RESET ALL",
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 10 : 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.save_rounded, size: isMobile ? 16 : 20),
                          label: Text(
                            isMobile ? "SAVE RATES" : "SAVE CONFIGURATION",
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(String month, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
        border: Border.all(
          color: isMobile ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: isMobile ? 0.06 : 0.04),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 12),
            decoration: BoxDecoration(
              color: isMobile ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMobile ? 12 : 18),
                topRight: Radius.circular(isMobile ? 12 : 18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isMobile ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12 : 15,
                fontWeight: FontWeight.w800,
                color: isMobile ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                letterSpacing: isMobile ? 1.0 : 1.5,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: isMobile ? 6 : 12,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildPercentField("$month-DA", "DA%", isMobile)),
                  SizedBox(width: isMobile ? 6 : 12),
                  Expanded(child: _buildPercentField("$month-HRA", "HRA%", isMobile)),
                  SizedBox(width: isMobile ? 6 : 12),
                  Expanded(child: _buildPercentField("$month-NPA", "NPA%", isMobile)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentField(String key, String label, bool isMobile) {
    Color labelColor = const Color(0xFF64748B);
    Color fillColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF0F172A);
    Color suffixColor = const Color(0xFF94A3B8);
    Color focusColor = const Color(0xFF2563EB);

    if (isMobile) {
      if (label == "DA%") {
        labelColor = const Color(0xFF047857);
        fillColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFA7F3D0);
        textColor = const Color(0xFF065F46);
        suffixColor = const Color(0xFF059669);
        focusColor = const Color(0xFF059669);
      } else if (label == "HRA%") {
        labelColor = const Color(0xFF6D28D9);
        fillColor = const Color(0xFFF5F3FF);
        borderColor = const Color(0xFFDDD6FE);
        textColor = const Color(0xFF5B21B6);
        suffixColor = const Color(0xFF7C3AED);
        focusColor = const Color(0xFF7C3AED);
      } else if (label == "NPA%") {
        labelColor = const Color(0xFFBE123C);
        fillColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFFECDD3);
        textColor = const Color(0xFF9F1239);
        suffixColor = const Color(0xFFE11D48);
        focusColor = const Color(0xFFE11D48);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[key],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: isMobile ? 6 : 12,
                horizontal: isMobile ? 4 : 8,
              ),
              suffixText: "%",
              suffixStyle: TextStyle(
                color: suffixColor,
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 11 : 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                borderSide: BorderSide(color: focusColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
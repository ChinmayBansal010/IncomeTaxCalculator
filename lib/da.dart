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
    fetchData();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No Data Found")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch data: $e")),
        );
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Updating...", style: TextStyle(fontSize: 16)),
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
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Success"),
              content: const Text(
                  "% data has been successfully added."),
              actions: [
                TextButton(
                  onPressed: () => { Navigator.pop(ctx) },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to add data: \n$e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Invalid! All values must be between 0-100"),
            actions: [
              TextButton(
                onPressed: () => { Navigator.pop(ctx) },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DA% Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical, // Only vertical scroll
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ensure the table is inside a horizontally scrollable container
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                      child: Table(
                        columnWidths: {
                          0: FixedColumnWidth(150),
                          1: FixedColumnWidth(120),
                          2: FixedColumnWidth(120),
                          3: FixedColumnWidth(120),
                        },
                        border: TableBorder.all(color: Colors.black, width: 1),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.blueAccent),
                            children: [
                              _buildHeaderCell("MONTH"),
                              _buildHeaderCell("DA%"),
                              _buildHeaderCell("HRA%"),
                              _buildHeaderCell("NPA%"),
                            ],
                          ),
                          ...months.map((month) {
                            return TableRow(
                              children: [
                                _buildMonthCell(month),
                                _buildTextField("$month-DA"),
                                _buildTextField("$month-HRA"),
                                _buildTextField("$month-NPA"),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  // Buttons with animations
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedButton("SAVE", Colors.green[300], saveData),
                        SizedBox(width: 20),
                        _buildAnimatedButton("RESET", Colors.red[300], resetFields),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.3),
            blurRadius: 10.0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMonthCell(String month) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[50]!.withValues(alpha: 0.5),
            blurRadius: 8.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          month,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTextField(String key) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.4),
            blurRadius: 8.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[key],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: 'Enter value',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String label, Color? color, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
        boxShadow: [
          BoxShadow(
            color: color?.withValues(alpha: 0.5) ?? Colors.transparent,
            spreadRadius: 5,
            blurRadius: 7,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}

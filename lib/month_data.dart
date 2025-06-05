import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/monthpages/month_navigation.dart';
// Import the MainPage
import 'shared.dart';

class MonthDataPage extends StatefulWidget {
  const MonthDataPage({super.key});
  @override
  State<MonthDataPage> createState() => _MonthDataPageState();
}

class _MonthDataPageState extends State<MonthDataPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef;
  Map<String, Map<String, dynamic>> biometricData = {};
  Map<String, Map<String, dynamic>> filteredData = {}; // For storing filtered results
  bool isLoading = true;
  bool shouldRefetch = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bioRef = _dbRef.child(sharedData.userPlace).child('maindata');
    fetchData();
    searchController.addListener(_filterData);
  }

  Future<void> fetchData() async {
    try {
      DatabaseEvent event = await bioRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Cast the snapshot value safely
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;

        // Initialize the data map
        Map<String, Map<String, dynamic>> data = {};

        // Ensure data exists and process the fetched rawData
        rawData.forEach((key, value) {
          if (key is String && value is Map) {
            // Ensure each value is a valid Map
            data[key] = Map<String, dynamic>.from(value);
          }
        });

        setState(() {
          biometricData = data;
          filteredData = data; // Initially, no filter applied
          isLoading = false;
          shouldRefetch = false;
        });
      } else {
        setState(() {
          errorMessage = 'No data available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  // Filter data based on search input
  void _filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = Map.fromEntries(biometricData.entries.where((entry) {
        String biometricId = entry.key.toLowerCase();
        String name = entry.value['name']?.toLowerCase() ?? '';
        return biometricId.contains(query) || name.contains(query);
      }));
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterData);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = 16.0; // Standard padding
    double fontSize = screenWidth > 600 ? 18 : 14; // Font size adjustment
    double maxWidth = screenWidth > 600 ? 600 : screenWidth - 2 * padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MONTH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        leading: BackButton(onPressed: () {
          Navigator.pop(context, true);
        }),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center( // Centering the content
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by Biometric ID or Name',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: fontSize),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          List<String> sortedBiometricIds = filteredData.keys.toList()..sort();
                          String biometricId = sortedBiometricIds[index];
                          Map<String, dynamic> details = filteredData[biometricId]!;

                          // Slide-in animation for each list item
                          return AnimatedSlide(
                            offset: Offset(0, 0),
                            duration: Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black, width: 2),
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.all(5.0),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () async {
                                  bool? result = await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MonthNavigationPage(
                                        biometricId: biometricId,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      isLoading = true;
                                      shouldRefetch = true;
                                    });
                                    bioRef = _dbRef.child(sharedData.userPlace).child('maindata');
                                    fetchData();
                                    searchController.addListener(_filterData);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '$biometricId - ${details['name']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
        ],
      ),
      // floatingActionButton: Stack(
      //   fit: StackFit.expand,
      //   children: [
      //     Positioned(
      //       bottom: 16,
      //       right: 16,
      //       child: CustomFloatingButton(
      //         label: 'COPY',
      //         icon: Icons.copy,
      //         onPressed: () {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text('Copy functionality executed!')),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
class CustomFloatingButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomFloatingButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  CustomFloatingButtonState createState() => CustomFloatingButtonState();
}

class CustomFloatingButtonState extends State<CustomFloatingButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.2 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 50), // Larger button size
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.black,
                  Colors.black54,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 32, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}

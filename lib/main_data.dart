import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main/main_update.dart'; // Import the MainPage
import 'main/main_add.dart'; // Import the MainPage
import 'shared.dart';

class MainDataPage extends StatefulWidget {
  const MainDataPage({super.key});
  @override
  State<MainDataPage> createState() => _MainDataPageState();
}

class _MainDataPageState extends State<MainDataPage> {
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
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String, Map<String, dynamic>> data = {};

        rawData.forEach((key, value) {
          if (key is String && value is Map) {
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

    // Define a max width for the form content
    double maxWidth = 800; // Maximum width for the form content (larger for web)
    double padding = 16.0; // Standard padding
    double fontSize = screenWidth > 600 ? 18 : 14; // Font size for mobile vs web

    return Scaffold(
      appBar: AppBar(
        title: Text("MAIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth), // Limiting width
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by Biometric ID or Name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: fontSize, // Applying moderate font size
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : errorMessage.isNotEmpty
                        ? Center(child: Text(errorMessage))
                        : Expanded(
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          List<String> sortedBiometricIds = filteredData.keys.toList()
                            ..sort();
                          String biometricId = sortedBiometricIds[index];
                          Map<String, dynamic> details = filteredData[biometricId]!;

                          // Slide-in animation for each list item
                          return AnimatedSlide(
                            offset: Offset(0, 0),
                            duration: Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(color: Colors.black, width: 2),
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.all(5.0),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () async {
                                  bool? result = await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainUpdatePage(
                                        biometricId: biometricId,
                                        name: details['name'] ?? '',
                                        fhName: details['fhname'] ?? '',
                                        designation: details['designation'] ?? '',
                                        dob: details['dob'] ?? '',
                                        doa: details['doa'] ?? '',
                                        dort: details['dort'] ?? '',
                                        group: details['group'] ?? '',
                                        category: details['category'] ?? '',
                                        sex: details['sex'] ?? '',
                                        address: details['address'] ?? '',
                                        aadhaar: details['aadhaarno'] ?? '0',  // Default value '0' for aadhaar if null
                                        mobile: details['mobileno'] ?? '0',    // Default value '0' for mobile if null
                                        account: details['accountno'] ?? '0',  // Default value '0' for account if null
                                        branch: details['branch'] ?? '',
                                        micr: details['micrno'] ?? '0',       // Default value '0' for micr if null
                                        ifsc: details['ifsc'] ?? '',
                                        pan: details['panno'] ?? '',
                                        payScale: details['payscale'] ?? '',
                                        level: details['level'] ?? '',
                                        gpfNo: details['gpfno'] ?? '0',     // Default value '0' for gpfNo if null
                                        npsNo: details['npsno'] ?? '0',     // Default value '0' for npsNo if null
                                        email: details['emailid'] ?? '',
                                        cycleNo: details['cycleno'] ?? '',
                                        voterId: details['voterid'] ?? '',
                                        dojo: details['dojo'] ?? '',
                                        place: details['place'] ?? '',
                                        bloodGroup: details['bloodgrp'] ?? '',
                                        emergencyNo: details['emergencyno'] ?? '0', // Default value '0' for emergencyNo if null
                                        nicEmail: details['nicemailid'] ?? '',
                                        dorn: details['dorn'] ?? '',
                                        education: details['education'] ?? '',
                                        empType: details['emptype'] ?? '',
                                        bankName: details['bname'] ?? '',
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
                                        fontSize: fontSize, // Applying moderate font size
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainAddPage(),
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
        child: Icon(Icons.add),
      ),
    );
  }
}

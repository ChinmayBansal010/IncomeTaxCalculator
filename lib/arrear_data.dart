import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/arrear/arrear_save.dart';
import 'shared.dart';

class ArrearPage extends StatefulWidget {
  const ArrearPage({super.key});

  @override
  State<ArrearPage> createState() => _ArrearPageState();
}

class _ArrearPageState extends State<ArrearPage> {
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
    bioRef = _dbRef.child(sharedData.userPlace).child('arrdata');
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
      if(mounted){
        setState(() {
          errorMessage = 'Error fetching data: $e';
          isLoading = false;
        });
      }
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

    // Define maxWidth for the content layout
    double maxWidth = 800;
    double padding = 16.0;
    double fontSize = screenWidth > 600 ? 18 : 14; // Dynamically adjust font size

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARREAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                constraints: BoxConstraints(maxWidth: maxWidth), // Limiting max width
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
                            fontSize: fontSize,
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
                                      builder: (context) => ArrearUpdatePage(
                                        biometricId: biometricId,
                                        name: details['name'] ?? '',
                                        mmda: details['mmda'] ?? '0',
                                        mmhra: details['mmhra'] ?? '0',
                                        mmdaonta: details['mmdaonta'] ?? '0',
                                        mmpca: details['mmpca'] ?? '0',
                                        mmnpa: details['mmnpa'] ?? '0',
                                        mmtution: details['mmtution'] ?? '0',
                                        mmother: details['mmother'] ?? '0',
                                        mmext1: details['mmext1'] ?? '0',
                                        mmext2: details['mmext2'] ?? '0',
                                        mmext3: details['mmext3'] ?? '0',
                                        jada: details['jada'] ?? '0',
                                        jahra: details['jahra'] ?? '0',
                                        jadaonta: details['jadaonta'] ?? '0',
                                        japca: details['japca'] ?? '0',
                                        janpa: details['janpa'] ?? '0',
                                        jatution: details['jatution'] ?? '0',
                                        jaother: details['jaother'] ?? '0',
                                        jaext1: details['jaext1'] ?? '0',
                                        jaext2: details['jaext2'] ?? '0',
                                        jaext3: details['jaext3'] ?? '0',
                                        snda: details['snda'] ?? '0',
                                        snhra: details['snhra'] ?? '0',
                                        sndaonta: details['sndaonta'] ?? '0',
                                        snpca: details['snpca'] ?? '0',
                                        snnpa: details['snnpa'] ?? '0',
                                        sntution: details['sntution'] ?? '0',
                                        snother: details['snother'] ?? '0',
                                        snext1: details['snext1'] ?? '0',
                                        snext2: details['snext2'] ?? '0',
                                        snext3: details['snext3'] ?? '0',
                                        dfda: details['dfda'] ?? '0',
                                        dfhra: details['dfhra'] ?? '0',
                                        dfdaonta: details['dfdaonta'] ?? '0',
                                        dfpca: details['dfpca'] ?? '0',
                                        dfnpa: details['dfnpa'] ?? '0',
                                        dftution: details['dftution'] ?? '0',
                                        dfother: details['dfother'] ?? '0',
                                        dfext1: details['dfext1'] ?? '0',
                                        dfext2: details['dfext2'] ?? '0',
                                        dfext3: details['dfext3'] ?? '0',
                                        bonus: details['bonus'] ?? '0',
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    if (mounted){
                                      setState(() {
                                        isLoading = true;
                                        shouldRefetch = true;
                                      });
                                      bioRef = _dbRef.child(sharedData.userPlace).child('arrdata');
                                      fetchData();
                                      searchController.addListener(_filterData);
                                    }
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
                                        fontSize: fontSize, // Dynamically adjusted font size
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
    );
  }
}

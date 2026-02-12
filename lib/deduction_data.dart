import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/deduction/deduction_save.dart';
import 'package:incometax/deduction/deduction_all.dart';
import 'shared.dart';

class DeductionPage extends StatefulWidget {
  const DeductionPage({super.key});

  @override
  State<DeductionPage> createState() => _DeductionPageState();
}

class _DeductionPageState extends State<DeductionPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef;
  Map<String, Map<String, dynamic>> biometricData = {};
  Map<String, Map<String, dynamic>> filteredData = {};
  bool isLoading = true;
  bool shouldRefetch = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bioRef = _dbRef.child(sharedData.userPlace).child('deddata');
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

        if(mounted){
          setState(() {
            biometricData = data;
            filteredData = data;
            isLoading = false;
            shouldRefetch = false;
          });
        }
      } else {
        if(mounted){
          setState(() {
            errorMessage = 'No data available';
            isLoading = false;
          });
        }
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

  Future<void> _dedall() async{
    List<String> sortedBiometricIds = biometricData.keys.toList()..sort();
    for (int index = 0; index < sortedBiometricIds.length; index++){
      String biometricId = sortedBiometricIds[index];
      Map<String, dynamic> details = biometricData[biometricId]!;

      WidgetsFlutterBinding.ensureInitialized();


      final DeductionAllPage processor = DeductionAllPage(
        biometricId: biometricId,
        name: details['name'] ?? '',
        hrr: details['hrr'] ?? '',
        oname: details['oname'] ?? '',
        opan: details['opan'] ?? '',
        po: details['po'] ?? '0',
        ppf: details['ppf'] ?? '0',
        lic: details['lic'] ?? '0',
        hlp: details['hlp'] ?? '0',
        hli: details['hli'] ?? '0',
        atg: details['80g'] ?? '0',
        tution: details['tution'] ?? '0',
        cea: details['cea'] ?? '0',
        fd: details['fd'] ?? '0',
        nsc: details['nsc'] ?? '0',
        atc: details['80c'] ?? '0',
        ulip: details['ulip'] ?? '0',
        atccd1: details['80ccd1'] ?? '0',
        gpf: details['gpf'] ?? '0',
        gis: details['gis'] ?? '0',
        elss: details['elss'] ?? '0',
        ssy: details['ssy'] ?? '0',
        atccdnps: details['80ccdnps'] ?? '0',
        atd: details['80d'] ?? '0',
        atdp: details['80dp'] ?? '0',
        atdps: details['80dps'] ?? '0',
        atu: details['80u'] ?? '0',
        ate: details['80e'] ?? '0',
        relief: details['relief'] ?? '0',
        atee: details['80ee'] ?? '0',
        rpaid: details['rpaid'] ?? '0',
        convcontuniform: details['taexem'] ?? '0',
        other: details['other'] ?? '0',
        atccd2: details['80ccd2'] ?? '0',
        totalsav: details['totalsav'] ?? '0',
        maxsav: details['maxsav'] ?? '0',
        htype: details['htype'] ?? 'SELF',
        rent: details['rent'] ?? '0',
        ext3: details['ext3'] ?? '0',
        ext4: details['ext4'] ?? '0',
        ext5: details['ext5'] ?? '0',
      );
      await processor.initializeData();

    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = 16.0;
    double fontSize = screenWidth > 600 ? 18 : 14;
    double maxWidth = screenWidth > 600 ? 600 : screenWidth - 2 * padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEDUCTION', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                                      builder: (context) => DeductionUpdatePage(
                                        biometricId: biometricId,
                                        name: details['name'] ?? '',
                                        hrr: details['hrr'] ?? '0',
                                        oname: details['oname'] ?? '',
                                        opan: details['opan'] ?? '',
                                        po: details['po'] ?? '0',
                                        ppf: details['ppf'] ?? '0',
                                        lic: details['lic'] ?? '0',
                                        hlp: details['hlp'] ?? '0',
                                        hli: details['hli'] ?? '0',
                                        atg: details['80g'] ?? '0',
                                        tution: details['tution'] ?? '0',
                                        cea: details['cea'] ?? '0',
                                        fd: details['fd'] ?? '0',
                                        nsc: details['nsc'] ?? '0',
                                        atc: details['80c'] ?? '0',
                                        ulip: details['ulip'] ?? '0',
                                        atccd1: details['80ccd1'] ?? '',
                                        gpf: details['gpf'] ?? '',
                                        gis: details['gis'] ?? '',
                                        elss: details['elss'] ?? '0',
                                        ssy: details['ssy'] ?? '0',
                                        atccdnps: details['80ccdnps'] ?? '0',
                                        atd: details['80d'] ?? '0',
                                        atdp: details['80dp'] ?? '0',
                                        atdps: details['80dps'] ?? '0',
                                        atu: details['80u'] ?? '0',
                                        ate: details['80e'] ?? '0',
                                        relief: details['relief'] ?? '0',
                                        atee: details['80ee'] ?? '0',
                                        rpaid: details['rpaid'] ?? '0',
                                        convcontuniform: details['taexem'] ?? '',
                                        other: details['other'] ?? '0',
                                        atccd2: details['80ccd2'] ?? '',
                                        totalsav: details['totalsav'] ?? '0',
                                        maxsav: details['maxsav'] ?? '0',
                                        htype: details['htype'] ?? '',
                                        rent: details['rent'] ?? '0',
                                        ext3: details['ext3'] ?? '0',
                                        ext4: details['ext4'] ?? '0',
                                        ext5: details['ext5'] ?? '0',
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    if (mounted){
                                      setState(() {
                                        isLoading = true;
                                        shouldRefetch = true;
                                      });
                                      bioRef = _dbRef.child(sharedData.userPlace).child('deddata');
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate back before starting the async task
           // Safe to navigate here before async task

          // Now perform the async task
          setState(() {
            isLoading = true;
          });

          try {
            await _dedall(); // Perform your async task
          } catch (error) {
            _showDialog("ERROR", error.toString());
          } finally {
            setState(() {
              isLoading = false;
              shouldRefetch = true;
            });
          }
          if(context.mounted) {
              Navigator.pop(context, true);
            }
          },
        child: Text(
          "ALL",
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold
          ),
        )
      ),
    );
  }

  void _showDialog(String title, String content) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      });
    }
  }
}

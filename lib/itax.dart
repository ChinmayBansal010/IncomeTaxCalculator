import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incometax/shared.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:universal_html/html.dart' show AnchorElement;
import 'dart:convert';


class ItaxPage extends StatefulWidget {
  const ItaxPage({super.key});

  @override
  State<ItaxPage> createState() => _ItaxPageState();
}

class _ItaxPageState extends State<ItaxPage> {
  final biometricIdController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = _dbRef.child(sharedData.userPlace);
  Map<String, Map<String, dynamic>> biometricData = {};
  Map<String, Map<String, dynamic>> filteredData = {}; // For storing filtered results
  bool isLoading = true;
  bool shouldRefetch = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  bool toLoad = false;

  Map<String?, dynamic> mainpgData = {};

  Map<String?, dynamic> marData = {};
  Map<String?, dynamic> aprData = {};
  Map<String?, dynamic> mayData = {};
  Map<String?, dynamic> junData = {};
  Map<String?, dynamic> julData = {};
  Map<String?, dynamic> augData = {};
  Map<String?, dynamic> septData = {};
  Map<String?, dynamic> octData = {};
  Map<String?, dynamic> novData = {};
  Map<String?, dynamic> decData = {};
  Map<String?, dynamic> janData = {};
  Map<String?, dynamic> febData = {};

  Map<String?, dynamic> arrearData = {};
  Map<String?, dynamic> dedData = {};
  Map<String?, dynamic> itfData = {};

  @override
  void initState(){
    super.initState();
    fetchData();
    searchController.addListener(_filterData);
  }

  @override
  void dispose(){
    biometricIdController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      DatabaseEvent event = await bioRef.child('maindata').once();
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

  Future<void> fetchmainpgData(String biometricId) async {
    try {
      DatabaseEvent event = await bioRef.child('maindata').child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String?, dynamic> data = rawData.cast<String, dynamic>();
        mainpgData = data;
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("No Data Available"),
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
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$error"),
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
  }

  Future<Map<String, Map<String?, dynamic>>> fetchAllMonthData(String biometricId) async {
    List<String> months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec'];
    Map<String, Map<String?, dynamic>> allMonthData = {};

    for (String month in months) {
      Map<String?, dynamic> data = await fetchMonthData(month, biometricId);
      allMonthData[month] = data;
    }

    return allMonthData;
  }

  Future<Map<String?, dynamic>> fetchMonthData(String month, String biometricId) async {
    try {

      DatabaseEvent event = await bioRef
          .child('monthdata')
          .child(month)
          .child(biometricId)
          .once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String?, dynamic> data = rawData.cast<String, dynamic>();

        return data;
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("No Data Available"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
        return{};
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$error"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      return {};
    }
  }



  Future<void> fetcharrearData(String biometricId) async {
    try {
      DatabaseEvent event = await bioRef.child('arrdata').child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String?, dynamic> data = rawData.cast<String, dynamic>();
        arrearData = data;
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("No Data Available"),
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
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$error"),
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
  }

  Future<void> fetchdedData(String biometricId) async {
    try {
      DatabaseEvent event = await bioRef.child('deddata').child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String?, dynamic> data = rawData.cast<String, dynamic>();
        dedData = data;
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("No Data Available"),
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
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Error Fetching Deduction Data \n$error"),
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
  }
  Future<void> fetchitaxData(String biometricId) async {
    try {
      DatabaseEvent event = await bioRef.child('itfdata').child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String?, dynamic> data = rawData.cast<String, dynamic>();
        itfData = data;
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("No Data Available"),
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
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Error Fetching Deduction Data \n$error"),
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
  }

  Future<void> updateitax(
      String? biometricId,
        int varBpgross,
        int varDagross,
        int varHragross,
        int varNpagross,
        int varSplpaygross,
        int varConvgross,
        int varPggross,
        int varAnnualgross,
        int varUniformgross,
        int varNursinggross,
        int varTagross,
        int varDaontagross,
        int varMedicalgross,
        int varDirtgross,
        int varWashinggross,
        int varTbgross,
        int varNightgross,
        int varDrivegross,
        int varCyclegross,
        int varPcagross,
        int varNpsempgross,
        int varOthergross,
        int varDaext1gross,
        int varDaext2gross,
        int varDaext3gross,
        int varDaext4gross,
        int varSalarygross,
        int varIncometaxgross,
        int varGisgross,
        int varGpfgross,
        int varNpsgross,
        int varSlfgross,
        int varSocietygross,
        int varRecoverygross,
        int varWfgross,
        int varOther2gross,
        int varDdext1gross,
        int varDdext2gross,
        int varDdext3gross,
        int varDdext4gross,
        int varTotaldedgross,
        int varNetsalarygross
      ) async{
    if (biometricId == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("BIOMETRIC ID CANNOT BE EMPTY"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      return;
    }
    try {
      await bioRef.child('itfdata').child(biometricId).set({
        'biometricid': biometricId,
        'tbp': varBpgross,
        'tda': varDagross,
        'thra': varHragross,
        'tnpa': varNpagross,
        'tsplpay': varSplpaygross,
        'tconv': varConvgross,
        'tpg': varPggross,
        'tannual': varAnnualgross,
        'tuniform': varUniformgross,
        'tnursing': varNursinggross,
        'tta': varTagross,
        'tdaonta': varDaontagross,
        'tmedical': varMedicalgross,
        'tdirt': varDirtgross,
        'twashing': varWashinggross,
        'ttb': varTbgross,
        'tnight': varNightgross,
        'tdrive': varDrivegross,
        'tcycle': varCyclegross,
        'tpca': varPcagross,
        'tnpsemp': varNpsempgross,
        'tother': varOthergross,
        'tgross': varSalarygross,
        'tincometax': varIncometaxgross,
        'tgis': varGisgross,
        'tgpf': varGpfgross,
        'tnps': varNpsgross,
        'tslf': varSlfgross,
        'tsociety': varSocietygross,
        'trecovery': varRecoverygross,
        'twf': varWfgross,
        'tother2': varOther2gross,

      });
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$error"),
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
  }

  Future<void> updateItaxnew(
      String? biometricId,
      int varTg,
      int varIfhp,
      int varAtee,
      int varGti,
      int varHli,
      int varSd,
      int varAtccd2,
      int varOther,
      int varTti,
      int varT1,
      int varT2,
      int varT3,
      int varT4,
      int varT5,
      int varT6,
      int varT7,
      int varTre,
      int varTtl,
      int varEc,
      int varTtp,
      int varTtpi,
      int varDeduct,
      int varNitp,
      int varInterest,
      int varRelief,
      int varNitpi,
      int varEp
      ) async{
    if (biometricId == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("BIOMETRIC ID CANNOT BE EMPTY"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      return;
    }
    try {
      await bioRef.child('itaxnew').child(biometricId).set({
        'biometricid': biometricId,
        'tg': varTg,
        'ifhp': varIfhp,
        'atee': varAtee,
        'gti': varGti,
        'hli': varHli,
        'sd': varSd,
        'atccd2': varAtccd2,
        'other': varOther,
        'tti': varTti,
        't1': varT1,
        't2': varT2,
        't3': varT3,
        't4': varT4,
        't5': varT5,
        't6': varT6,
        't7': varT7,
        'tre': varTre,
        'ttl': varTtl,
        'ec': varEc,
        'ttp': varTtp,
        'ttpi': varTtpi,
        'deduct': varDeduct,
        'nitp': varNitp,
        'interest': varInterest,
        'relief': varRelief,
        'nitpi': varNitpi,
        'ep': varEp
      });
    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$error"),
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
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    // Define maxWidth for the content layout
    double maxWidth = 800;
    double padding = 16.0;
    double fontSize = screenWidth > 600 ? 18 : 14;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home, size: 24, color: Colors.black),
            const SizedBox(width: 8),
            const Text('INOCME TAX', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: toLoad
          ?CircularProgressIndicator()
          : Stack(
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
                      Center(
                        child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWideScreen? 600 : 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _buildTextField('BiometricID', biometricIdController),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ElevatedButton(
                                    onPressed: createExcel,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                      elevation: 8.0,
                                    ),
                                    child: const Text(
                                      "EXPORT",
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ElevatedButton(
                                    onPressed: exportAll,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                      elevation: 8.0,
                                    ),
                                    child: const Text(
                                      "EXPORT ALL",
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            prefixIcon: Icon(Icons.search, color: Colors.blue),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Colors.blue))
                          : errorMessage.isNotEmpty
                          ? Center(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
                          : Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateColor.resolveWith(
                                      (states) => Colors.blue.shade100),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                    (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.blue.shade50; // Hover effect
                                  }
                                  return Colors.white;
                                },
                              ),
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade900,
                              ),
                              dataTextStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              border: TableBorder.all(
                                color: Colors.blue.shade300,
                                width: 2, // Bold borders
                              ),
                              columns: const [
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Biometric ID'),
                                  ),
                                ),
                                DataColumn(
                                  label: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Name'),
                                  ),
                                ),
                              ],
                              rows: filteredData.keys
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) {
                                  int index = entry.key;
                                  String biometricId = entry.value;
                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith(
                                          (Set<WidgetState> states) {
                                        if (index % 2 == 0) {
                                          return Colors.blue.shade50; // Alternate row color
                                        }
                                        return Colors.white;
                                      },
                                    ),
                                    cells: [
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(biometricId),
                                        ),
                                        onTap: () {
                                          biometricIdController.text =
                                              biometricId; // Set value to controller
                                        },
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            filteredData[biometricId]
                                            ?['name'] ??
                                                'N/A',
                                          ),
                                        ),
                                        onTap: () {
                                          biometricIdController.text =
                                              biometricId; // Set value to controller
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter> inputFormatters = const [],
      }) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: isWideScreen ? 32.0 : 16.0),
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: [
          ...inputFormatters,  // Add any custom formatters passed
        ],
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: isWideScreen ? 22.0 : 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 3),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[700]!, width: 4),
          ),
        ),
        style: TextStyle(fontSize: isWideScreen ? 16.0 : 14.0, fontWeight: FontWeight.w400, color: Colors.black87),
        onChanged: (value) {
          if (controller.text != value) {
            final cursorPosition = controller.selection;
            controller.value = TextEditingValue(
              text: value,
              selection: cursorPosition,
            );
          }
        },
      ),
    );
  }

  void addData(){
    debugPrint("a");
  }


  Future<void> createExcel({String? biometricId}) async {
    setState(() {
      toLoad = true;
    });
    biometricId = (biometricId == null || biometricId.isEmpty) ? biometricIdController.text : biometricId;


    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet itaxformSheet = workbook.worksheets[0];
    final xls.Worksheet computationSheet = workbook.worksheets.add();
    final xls.Worksheet itaxnewSheet = workbook.worksheets.add();

    itaxformSheet.name = "ITAX FORM";
    computationSheet.name = "COMPUTATION";
    itaxnewSheet.name = "ITAX CAL";


    //-------------styles-------------------
    final xls.Style formheaderStyle = workbook.styles.add('formheaderStyle');
    formheaderStyle.fontName = 'Calibri';
    formheaderStyle.fontSize = 14;
    formheaderStyle.fontColor = '#000000';
    formheaderStyle.bold = true;
    formheaderStyle.hAlign = xls.HAlignType.center;
    formheaderStyle.vAlign = xls.VAlignType.center;
    formheaderStyle.borders.all.color = '#000000';
    formheaderStyle.borders.all.lineStyle = xls.LineStyle.thick;
    formheaderStyle.wrapText = true;

    final xls.Style otherheaderStyle = workbook.styles.add('otherheaderStyle');
    otherheaderStyle.fontName = 'Calibri';
    otherheaderStyle.fontSize = 15;
    otherheaderStyle.fontColor = '#000000';
    otherheaderStyle.bold = true;
    otherheaderStyle.underline = true;
    otherheaderStyle.backColor = "#8EB4E2";
    otherheaderStyle.hAlign = xls.HAlignType.center;
    otherheaderStyle.vAlign = xls.VAlignType.center;
    otherheaderStyle.borders.all.color = '#000000';
    otherheaderStyle.borders.all.lineStyle = xls.LineStyle.thick;
    otherheaderStyle.wrapText = true;

    final xls.Style commontextStyle = workbook.styles.add('commontextStyle');
    commontextStyle.fontName = 'Calibri';
    commontextStyle.fontSize = 11;
    commontextStyle.fontColor = '#000000';
    commontextStyle.hAlign = xls.HAlignType.left;
    commontextStyle.vAlign = xls.VAlignType.center;
    commontextStyle.borders.all.color = '#000000';
    commontextStyle.borders.all.lineStyle = xls.LineStyle.thin;
    commontextStyle.wrapText = true;

    final xls.Style commontextStyleBold = workbook.styles.add('commontextStyleBold');
    commontextStyleBold.fontName = 'Calibri';
    commontextStyleBold.fontSize = 11;
    commontextStyleBold.bold = true;
    commontextStyleBold.fontColor = '#000000';
    commontextStyleBold.hAlign = xls.HAlignType.left;
    commontextStyleBold.vAlign = xls.VAlignType.center;
    commontextStyleBold.borders.all.color = '#000000';
    commontextStyleBold.borders.all.lineStyle = xls.LineStyle.thin;

    final xls.Style tableheadingStyle = workbook.styles.add('tableheadingStyle');
    tableheadingStyle.fontName = 'Calibri';
    tableheadingStyle.fontSize = 11;
    tableheadingStyle.bold = true;
    tableheadingStyle.fontColor = '#000000';
    tableheadingStyle.backColor = '#EEECE1';
    tableheadingStyle.hAlign = xls.HAlignType.center;
    tableheadingStyle.vAlign = xls.VAlignType.center;
    tableheadingStyle.borders.all.color = '#000000';
    tableheadingStyle.borders.all.lineStyle = xls.LineStyle.thin;
    tableheadingStyle.wrapText = true;

    final xls.Style totalrowStyle = workbook.styles.add('totalrowStyle');
    totalrowStyle.fontName = 'Calibri';
    totalrowStyle.fontSize = 11;
    totalrowStyle.bold = true;
    totalrowStyle.fontColor = '#000000';
    totalrowStyle.backColor = '#FABF8F';
    totalrowStyle.hAlign = xls.HAlignType.left;
    totalrowStyle.vAlign = xls.VAlignType.center;
    totalrowStyle.borders.all.color = '#000000';
    totalrowStyle.borders.all.lineStyle = xls.LineStyle.thin;
    totalrowStyle.wrapText = true;

    final xls.Style formlastrowStyle = workbook.styles.add('formlastrowStyle');
    formlastrowStyle.fontName = 'Calibri';
    formlastrowStyle.fontSize = 13;
    formlastrowStyle.bold = true;
    formlastrowStyle.fontColor = '#000000';
    formlastrowStyle.backColor = '#C4BD97';
    formlastrowStyle.hAlign = xls.HAlignType.left;
    formlastrowStyle.vAlign = xls.VAlignType.center;
    formlastrowStyle.borders.all.color = '#000000';
    formlastrowStyle.borders.all.lineStyle = xls.LineStyle.thick;
    formlastrowStyle.wrapText = true;

    final xls.Style specialcolStyle = workbook.styles.add('specialcolStyle');
    specialcolStyle.fontName = 'Calibri';
    specialcolStyle.fontSize = 11;
    specialcolStyle.bold = true;
    specialcolStyle.fontColor = '#000000';
    specialcolStyle.backColor = '#B9ECE0';
    specialcolStyle.hAlign = xls.HAlignType.left;
    specialcolStyle.vAlign = xls.VAlignType.center;
    specialcolStyle.borders.all.color = '#000000';
    specialcolStyle.borders.all.lineStyle = xls.LineStyle.thin;
    specialcolStyle.wrapText = true;

    final xls.Style speciallastrowStyle = workbook.styles.add('speciallastrowStyle');
    speciallastrowStyle.fontName = 'Calibri';
    speciallastrowStyle.fontSize = 13;
    speciallastrowStyle.bold = true;
    speciallastrowStyle.fontColor = '#000000';
    speciallastrowStyle.backColor = '#B9ECE0';
    speciallastrowStyle.hAlign = xls.HAlignType.left;
    speciallastrowStyle.vAlign = xls.VAlignType.center;
    speciallastrowStyle.borders.all.color = '#000000';
    speciallastrowStyle.borders.all.lineStyle = xls.LineStyle.thick;
    speciallastrowStyle.wrapText = true;

    final xls.Style specialtotalrowStyle = workbook.styles.add('specialtotalrowStyle');
    specialtotalrowStyle.fontName = 'Calibri';
    specialtotalrowStyle.fontSize = 11;
    specialtotalrowStyle.bold = true;
    specialtotalrowStyle.fontColor = '#000000';
    specialtotalrowStyle.backColor = '#FABF8F';
    specialtotalrowStyle.hAlign = xls.HAlignType.left;
    specialtotalrowStyle.vAlign = xls.VAlignType.center;
    specialtotalrowStyle.borders.all.color = '#000000';
    specialtotalrowStyle.borders.all.lineStyle = xls.LineStyle.thin;
    specialtotalrowStyle.wrapText = true;

    await fetchmainpgData(biometricId);
    Map<String, Map<String?, dynamic>> monthdata = await fetchAllMonthData(biometricId);
    await fetchdedData(biometricId);
    await fetcharrearData(biometricId);

    marData = monthdata['mar']!;
    aprData = monthdata['apr']!;
    mayData = monthdata['may']!;
    junData = monthdata['jun']!;
    julData = monthdata['jul']!;
    augData = monthdata['aug']!;
    septData = monthdata['sept']!;
    octData = monthdata['oct']!;
    novData = monthdata['nov']!;
    decData = monthdata['dec']!;
    janData = monthdata['jan']!;
    febData = monthdata['feb']!;

    await _itaxformPage(biometricId, itaxformSheet, formheaderStyle,commontextStyle, commontextStyleBold, tableheadingStyle, totalrowStyle, formlastrowStyle, specialcolStyle, specialtotalrowStyle, speciallastrowStyle);
    await fetchitaxData(biometricId);
    await _computationPage(biometricId, computationSheet, otherheaderStyle, commontextStyle, commontextStyleBold);
    await _itaxNewPage(biometricId, itaxnewSheet, otherheaderStyle, commontextStyle, commontextStyleBold);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb){
      AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download','$biometricId.xlsx')
        ..click();

    } else{
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = '$path/$biometricId.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }

    setState(() {
      toLoad = false;
    });
  }

  Future<void> _itaxformPage(
      String? biometricId,
      xls.Worksheet sheet,
      [
        xls.Style? formheaderStyle,
        xls.Style? commontextStyle,
        xls.Style? commontextStyleBold,
        xls.Style? tableheadingStyle,
        xls.Style? totalrowStyle,
        xls.Style? formlastrowStyle,
        xls.Style? specialcolStyle,
        xls.Style? specialtotalrowStyle,
        xls.Style? speciallastrowStyle,
      ])
  async{
    try{

      // --------------------- Itax Form ----------------------------
      sheet.getRangeByName('A1').setValue(sharedData.zone);
      sheet.getRangeByName('A1:K1').merge();
      sheet.getRangeByName('A1').rowHeight = 18.60;
      sheet.getRangeByName('A1').columnWidth = 13.33;
      sheet.getRangeByName('A1:K1').cellStyle = formheaderStyle!;

      sheet.getRangeByName('B1:K1').columnWidth = 8.89;

      sheet.getRangeByName('A2').setValue("BIOMETRIC ID");
      sheet.getRangeByName('B2').setValue(biometricId);
      sheet.getRangeByName('B2:C2').merge();

      sheet.getRangeByName('D2').setValue("NAME");
      sheet.getRangeByName('E2').setValue(mainpgData['name']);
      sheet.getRangeByName('E2:G2').merge();

      sheet.getRangeByName('H2').setValue("F/H NAME");
      sheet.getRangeByName('I2').setValue(mainpgData['fhname']);
      sheet.getRangeByName('I2:K2').merge();

      sheet.getRangeByName('A3').setValue("SEX");
      sheet.getRangeByName('B3').setValue(mainpgData['sex']);
      sheet.getRangeByName('B3:C3').merge();

      sheet.getRangeByName('D3').setValue("DESIGNATION");
      sheet.getRangeByName('D3:E3').merge();
      sheet.getRangeByName('F3').setValue(mainpgData['designation']);
      sheet.getRangeByName('F3:G3').merge();

      sheet.getRangeByName('H3').setValue("GROUP");
      sheet.getRangeByName('H3:I3').merge();
      sheet.getRangeByName('J3').setValue(mainpgData['group']);
      sheet.getRangeByName('J3:K3').merge();


      sheet.getRangeByName('A4').setValue("PAY SCALE");
      sheet.getRangeByName('B4').setValue(mainpgData['payscale']);
      sheet.getRangeByName('B4:C4').merge();

      sheet.getRangeByName('D4').setValue("EMPLOYEE TYPE");
      sheet.getRangeByName('D4:E4').merge();
      sheet.getRangeByName('F4').setValue(mainpgData['emptype']);
      sheet.getRangeByName('F4:G4').merge();

      sheet.getRangeByName('H4').setValue("DOB");
      sheet.getRangeByName('H4:I4').merge();
      sheet.getRangeByName('J4').setValue(mainpgData['dob']);
      sheet.getRangeByName('J4:K4').merge();

      sheet.getRangeByName('A5').setValue("PAN NO.");
      sheet.getRangeByName('B5').setValue(mainpgData['panno']);
      sheet.getRangeByName('B5:C5').merge();

      sheet.getRangeByName('D5').setValue("MOBILE");
      sheet.getRangeByName('D5:E5').merge();
      sheet.getRangeByName('F5').setValue(mainpgData['mobileno']);
      sheet.getRangeByName('F5:G5').merge();

      sheet.getRangeByName('H5').setValue("GPF NO.");
      sheet.getRangeByName('H5:I5').merge();
      sheet.getRangeByName('J5').setValue(mainpgData['gpfno']);
      sheet.getRangeByName('J5:K5').merge();

      sheet.getRangeByName('A6').setValue("NPS NO.");
      sheet.getRangeByName('B6').setValue(mainpgData['npsno']);
      sheet.getRangeByName('B6:C6').merge();

      sheet.getRangeByName('D6').setValue("LEVEL");
      sheet.getRangeByName('D6:E6').merge();
      sheet.getRangeByName('F6').setValue(mainpgData['level']);
      sheet.getRangeByName('F6:G6').merge();

      sheet.getRangeByName('H6').setValue("");
      sheet.getRangeByName('H6:K6').merge();

      sheet.getRangeByName('A7').setValue("PLACE OF DUTY");
      sheet.getRangeByName('B7').setValue(mainpgData['place']);
      sheet.getRangeByName('B7:K7').merge();

      sheet.getRangeByName('A8').setValue("ADDRESS");
      sheet.getRangeByName('B8').setValue(mainpgData['address']);
      sheet.getRangeByName('B8:K8').merge();

      sheet.getRangeByName("A2:A8").cellStyle = commontextStyleBold!;
      sheet.getRangeByName("B2:C6").cellStyle = commontextStyle!;
      sheet.getRangeByName("D2").cellStyle = commontextStyleBold;
      sheet.getRangeByName("D3:E6").cellStyle = commontextStyleBold;
      sheet.getRangeByName("E2:G2").cellStyle = commontextStyle;
      sheet.getRangeByName("F3:G6").cellStyle = commontextStyle;
      sheet.getRangeByName("H2").cellStyle = commontextStyleBold;
      sheet.getRangeByName("H3:I6").cellStyle = commontextStyleBold;
      sheet.getRangeByName("I2:K2").cellStyle = commontextStyle;
      sheet.getRangeByName("J3:K6").cellStyle = commontextStyle;
      sheet.getRangeByName("B7:K7").cellStyle = commontextStyle;
      sheet.getRangeByName("B8:K8").cellStyle = commontextStyle;


      sheet.getRangeByName("A9").setValue("MONTH");
      sheet.getRangeByName("A9:A10").merge();
      sheet.getRangeByName("A9:A10").cellStyle = tableheadingStyle!;

      sheet.getRangeByName('A10').rowHeight = 30.60;

      List<String> values = [
        "MAR - 24", "APR - 24", "MAY - 24", "ARREAR", "QTR - 1 TOTAL",
        "JUN - 24", "JUL - 24", "AUG - 24", "ARREAR", "QTR - 2 TOTAL",
        "SEPT - 24", "OCT - 24", "NOV - 24", "ARREAR", "QTR - 3 TOTAL",
        "DEC - 24", "JAN - 24", "FEB - 24", "ARREAR", "TUTION",
        "BONUS", "QTR - 4 TOTAL"
      ];

      for (int i = 0; i < values.length; i++) {
        String cell = "A${i + 11}";
        sheet.getRangeByName(cell).setValue(values[i]);
        if (values[i].contains("QTR")) {
          sheet.getRangeByName(cell).cellStyle = totalrowStyle!;
        } else {
          sheet.getRangeByName(cell).cellStyle = commontextStyleBold;
        }
      }

      sheet.getRangeByName("A33").setValue("GROSS TOTAL");
      sheet.getRangeByName("A33").cellStyle = formlastrowStyle!;


      // =============================== mar ===============================
      int varBpmar = int.tryParse(marData['bp']?.toString() ?? '0') ?? 0;
      int varDamar = int.tryParse(marData['da']?.toString() ?? '0') ?? 0;
      int varHramar = int.tryParse(marData['hra']?.toString() ?? '0') ?? 0;
      int varNpamar = int.tryParse(marData['npa']?.toString() ?? '0') ?? 0;
      int varSplpaymar = int.tryParse(marData['splpay']?.toString() ?? '0') ?? 0;
      int varConvmar = int.tryParse(marData['conv']?.toString() ?? '0') ?? 0;
      int varPgmar = int.tryParse(marData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualmar = int.tryParse(marData['annual']?.toString() ?? '0') ?? 0;
      int varUniformmar = int.tryParse(marData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingmar = int.tryParse(marData['nursing']?.toString() ?? '0') ?? 0;
      int varTamar = int.tryParse(marData['ta']?.toString() ?? '0') ?? 0;
      int varDaontamar = int.tryParse(marData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalmar = int.tryParse(marData['medical']?.toString() ?? '0') ?? 0;
      int varDirtmar = int.tryParse(marData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingmar = int.tryParse(marData['washing']?.toString() ?? '0') ?? 0;
      int varTbmar = int.tryParse(marData['tb']?.toString() ?? '0') ?? 0;
      int varNightmar = int.tryParse(marData['night']?.toString() ?? '0') ?? 0;
      int varDrivemar = int.tryParse(marData['drive']?.toString() ?? '0') ?? 0;
      int varCyclemar = int.tryParse(marData['cycle']?.toString() ?? '0') ?? 0;
      int varPcamar = int.tryParse(marData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempmar = 0;

      if ((marData['nps'] is int ? marData['nps'] : int.tryParse(marData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempmar = ([
          int.tryParse(marData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(marData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(marData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value)*0.14).round();
      }
      int varOthermar = int.tryParse('0') ?? 0;
      int varDaext1mar = int.tryParse(marData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2mar = int.tryParse(marData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3mar = int.tryParse(marData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4mar = int.tryParse(marData['daext4']?.toString() ?? '0') ?? 0;
      int varSalarymar = [
        varBpmar, varDamar, varHramar, varNpamar, varSplpaymar, varConvmar, varPgmar,
        varAnnualmar, varUniformmar, varNursingmar, varTamar, varDaontamar, varMedicalmar,
        varDirtmar, varWashingmar, varTbmar, varNightmar, varDrivemar, varCyclemar,
        varPcamar, varNpsempmar, varOthermar, varDaext1mar, varDaext2mar, varDaext3mar, varDaext4mar,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxmar = int.tryParse(marData['incometax']?.toString() ?? '0') ?? 0;
      int varGismar = int.tryParse(marData['gis']?.toString() ?? '0') ?? 0;
      int varGpfmar = int.tryParse(marData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsmar = int.tryParse(marData['nps']?.toString() ?? '0') ?? 0;
      int varSlfmar = int.tryParse(marData['slf']?.toString() ?? '0') ?? 0;
      int varSocietymar = int.tryParse(marData['society']?.toString() ?? '0') ?? 0;
      int varRecoverymar = int.tryParse(marData['recovery']?.toString() ?? '0') ?? 0;
      int varWfmar = int.tryParse(marData['wf']?.toString() ?? '0') ?? 0;
      int varOther2mar = int.tryParse(marData['other']?.toString() ?? '0') ?? 0;
      int varDdext1mar = int.tryParse(marData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2mar = int.tryParse(marData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3mar = int.tryParse(marData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4mar = int.tryParse(marData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedmar = int.tryParse(marData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalarymar = int.tryParse(marData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== apr ===============================
      int varBpapr = int.tryParse(aprData['bp']?.toString() ?? '0') ?? 0;
      int varDaapr = int.tryParse(aprData['da']?.toString() ?? '0') ?? 0;
      int varHraapr = int.tryParse(aprData['hra']?.toString() ?? '0') ?? 0;
      int varNpaapr = int.tryParse(aprData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayapr = int.tryParse(aprData['splpay']?.toString() ?? '0') ?? 0;
      int varConvapr = int.tryParse(aprData['conv']?.toString() ?? '0') ?? 0;
      int varPgapr = int.tryParse(aprData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualapr = int.tryParse(aprData['annual']?.toString() ?? '0') ?? 0;
      int varUniformapr = int.tryParse(aprData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingapr = int.tryParse(aprData['nursing']?.toString() ?? '0') ?? 0;
      int varTaapr = int.tryParse(aprData['ta']?.toString() ?? '0') ?? 0;
      int varDaontaapr = int.tryParse(aprData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalapr = int.tryParse(aprData['medical']?.toString() ?? '0') ?? 0;
      int varDirtapr = int.tryParse(aprData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingapr = int.tryParse(aprData['washing']?.toString() ?? '0') ?? 0;
      int varTbapr = int.tryParse(aprData['tb']?.toString() ?? '0') ?? 0;
      int varNightapr = int.tryParse(aprData['night']?.toString() ?? '0') ?? 0;
      int varDriveapr = int.tryParse(aprData['drive']?.toString() ?? '0') ?? 0;
      int varCycleapr = int.tryParse(aprData['cycle']?.toString() ?? '0') ?? 0;
      int varPcaapr = int.tryParse(aprData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempapr = 0;

      if ((aprData['nps'] is int ? aprData['nps'] : int.tryParse(aprData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempapr = (([
          int.tryParse(aprData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(aprData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(aprData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOtherapr = int.tryParse('0') ?? 0;
      int varDaext1apr = int.tryParse(aprData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2apr = int.tryParse(aprData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3apr = int.tryParse(aprData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4apr = int.tryParse(aprData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryapr = [
        varBpapr, varDaapr, varHraapr, varNpaapr, varSplpayapr, varConvapr, varPgapr,
        varAnnualapr, varUniformapr, varNursingapr, varTaapr, varDaontaapr, varMedicalapr,
        varDirtapr, varWashingapr, varTbapr, varNightapr, varDriveapr, varCycleapr,
        varPcaapr, varNpsempapr, varOtherapr, varDaext1apr, varDaext2apr, varDaext3apr, varDaext4apr,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxapr = int.tryParse(aprData['incometax']?.toString() ?? '0') ?? 0;
      int varGisapr = int.tryParse(aprData['gis']?.toString() ?? '0') ?? 0;
      int varGpfapr = int.tryParse(aprData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsapr = int.tryParse(aprData['nps']?.toString() ?? '0') ?? 0;
      int varSlfapr = int.tryParse(aprData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyapr = int.tryParse(aprData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryapr = int.tryParse(aprData['recovery']?.toString() ?? '0') ?? 0;
      int varWfapr = int.tryParse(aprData['wf']?.toString() ?? '0') ?? 0;
      int varOther2apr = int.tryParse(aprData['other']?.toString() ?? '0') ?? 0;
      int varDdext1apr = int.tryParse(aprData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2apr = int.tryParse(aprData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3apr = int.tryParse(aprData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4apr = int.tryParse(aprData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedapr = int.tryParse(aprData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryapr = int.tryParse(aprData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== may ===============================
      int varBpmay = int.tryParse(mayData['bp']?.toString() ?? '0') ?? 0;
      int varDamay = int.tryParse(mayData['da']?.toString() ?? '0') ?? 0;
      int varHramay = int.tryParse(mayData['hra']?.toString() ?? '0') ?? 0;
      int varNpamay = int.tryParse(mayData['npa']?.toString() ?? '0') ?? 0;
      int varSplpaymay = int.tryParse(mayData['splpay']?.toString() ?? '0') ?? 0;
      int varConvmay = int.tryParse(mayData['conv']?.toString() ?? '0') ?? 0;
      int varPgmay = int.tryParse(mayData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualmay = int.tryParse(mayData['annual']?.toString() ?? '0') ?? 0;
      int varUniformmay = int.tryParse(mayData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingmay = int.tryParse(mayData['nursing']?.toString() ?? '0') ?? 0;
      int varTamay = int.tryParse(mayData['ta']?.toString() ?? '0') ?? 0;
      int varDaontamay = int.tryParse(mayData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalmay = int.tryParse(mayData['medical']?.toString() ?? '0') ?? 0;
      int varDirtmay = int.tryParse(mayData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingmay = int.tryParse(mayData['washing']?.toString() ?? '0') ?? 0;
      int varTbmay = int.tryParse(mayData['tb']?.toString() ?? '0') ?? 0;
      int varNightmay = int.tryParse(mayData['night']?.toString() ?? '0') ?? 0;
      int varDrivemay = int.tryParse(mayData['drive']?.toString() ?? '0') ?? 0;
      int varCyclemay = int.tryParse(mayData['cycle']?.toString() ?? '0') ?? 0;
      int varPcamay = int.tryParse(mayData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempmay = 0;

      if ((mayData['nps'] is int ? mayData['nps'] : int.tryParse(mayData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempmay = (([
          int.tryParse(mayData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(mayData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(mayData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOthermay = int.tryParse('0') ?? 0;
      int varDaext1may = int.tryParse(mayData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2may = int.tryParse(mayData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3may = int.tryParse(mayData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4may = int.tryParse(mayData['daext4']?.toString() ?? '0') ?? 0;
      int varSalarymay = [
        varBpmay, varDamay, varHramay, varNpamay, varSplpaymay, varConvmay, varPgmay,
        varAnnualmay, varUniformmay, varNursingmay, varTamay, varDaontamay, varMedicalmay,
        varDirtmay, varWashingmay, varTbmay, varNightmay, varDrivemay, varCyclemay,
        varPcamay, varNpsempmay, varOthermay, varDaext1may, varDaext2may, varDaext3may, varDaext4may,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxmay = int.tryParse(mayData['incometax']?.toString() ?? '0') ?? 0;
      int varGismay = int.tryParse(mayData['gis']?.toString() ?? '0') ?? 0;
      int varGpfmay = int.tryParse(mayData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsmay = int.tryParse(mayData['nps']?.toString() ?? '0') ?? 0;
      int varSlfmay = int.tryParse(mayData['slf']?.toString() ?? '0') ?? 0;
      int varSocietymay = int.tryParse(mayData['society']?.toString() ?? '0') ?? 0;
      int varRecoverymay = int.tryParse(mayData['recovery']?.toString() ?? '0') ?? 0;
      int varWfmay = int.tryParse(mayData['wf']?.toString() ?? '0') ?? 0;
      int varOther2may = int.tryParse(mayData['other']?.toString() ?? '0') ?? 0;
      int varDdext1may = int.tryParse(mayData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2may = int.tryParse(mayData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3may = int.tryParse(mayData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4may = int.tryParse(mayData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedmay = int.tryParse(mayData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalarymay = int.tryParse(mayData['netsalary']?.toString() ?? '0') ?? 0;



    // ============================= arrearqtr1 ==============================
      int varBparrearqtr1 = int.tryParse('0') ?? 0;
      int varDaarrearqtr1 = int.tryParse(arrearData['mmda']?.toString() ?? '0') ?? 0;
      int varHraarrearqtr1 = int.tryParse(arrearData['mmhra']?.toString() ?? '0') ?? 0;
      int varNpaarrearqtr1 = int.tryParse(arrearData['mmnpa']?.toString() ?? '0') ?? 0;
      int varSplpayarrearqtr1 = int.tryParse('0') ?? 0;
      int varConvarrearqtr1 = int.tryParse('0') ?? 0;
      int varPgarrearqtr1 = int.tryParse('0') ?? 0;
      int varAnnualarrearqtr1 = int.tryParse('0')?? 0;
      int varUniformarrearqtr1 = int.tryParse('0') ?? 0;
      int varNursingarrearqtr1 = int.tryParse('0') ?? 0;
      int varTaarrearqtr1 = int.tryParse('0') ?? 0;
      int varDaontaarrearqtr1 = int.tryParse(arrearData['mmdaonta']?.toString() ?? '0') ?? 0;
      int varMedicalarrearqtr1 = int.tryParse('0') ?? 0;
      int varDirtarrearqtr1 = int.tryParse('0') ?? 0;
      int varWashingarrearqtr1 = int.tryParse('0') ?? 0;
      int varTbarrearqtr1 = int.tryParse('0') ?? 0;
      int varNightarrearqtr1 = int.tryParse('0') ?? 0;
      int varDrivearrearqtr1 = int.tryParse('0') ?? 0;
      int varCyclearrearqtr1 = int.tryParse('0') ?? 0;
      int varPcaarrearqtr1 = int.tryParse(arrearData['mmpca']?.toString() ?? '0') ?? 0;
      int varNpsemparrearqtr1 = int.tryParse('0') ?? 0;
      int varOtherarrearqtr1 = int.tryParse(arrearData['mmother']?.toString() ?? '0') ?? 0;
      int varDaext1arrearqtr1 = int.tryParse('0') ?? 0;
      int varDaext2arrearqtr1 = int.tryParse('0') ?? 0;
      int varDaext3arrearqtr1 = int.tryParse('0') ?? 0;
      int varDaext4arrearqtr1 = int.tryParse('0') ?? 0;
      int varSalaryarrearqtr1 = [
        varBparrearqtr1, varDaarrearqtr1, varHraarrearqtr1, varNpaarrearqtr1, varSplpayarrearqtr1, varConvarrearqtr1, varPgarrearqtr1,
        varAnnualarrearqtr1, varUniformarrearqtr1, varNursingarrearqtr1, varTaarrearqtr1, varDaontaarrearqtr1, varMedicalarrearqtr1,
        varDirtarrearqtr1, varWashingarrearqtr1, varTbarrearqtr1, varNightarrearqtr1, varDrivearrearqtr1, varCyclearrearqtr1,
        varPcaarrearqtr1, varNpsemparrearqtr1, varOtherarrearqtr1, varDaext1arrearqtr1, varDaext2arrearqtr1, varDaext3arrearqtr1, varDaext4arrearqtr1,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxarrearqtr1 = int.tryParse(arrearData['mmext1']?.toString() ?? '0') ?? 0;
      int varGisarrearqtr1 = int.tryParse('0') ?? 0;
      int varGpfarrearqtr1 = int.tryParse('0') ?? 0;
      int varNpsarrearqtr1 = int.tryParse('0') ?? 0;
      int varSlfarrearqtr1 = int.tryParse('0') ?? 0;
      int varSocietyarrearqtr1 = int.tryParse('0') ?? 0;
      int varRecoveryarrearqtr1 = int.tryParse('0') ?? 0;
      int varWfarrearqtr1 = int.tryParse('0') ?? 0;
      int varOther2arrearqtr1 = int.tryParse('0') ?? 0;
      int varDdext1arrearqtr1 = int.tryParse('0') ?? 0;
      int varDdext2arrearqtr1 = int.tryParse('0') ?? 0;
      int varDdext3arrearqtr1 = int.tryParse('0') ?? 0;
      int varDdext4arrearqtr1 = int.tryParse('0') ?? 0;
      int varTotaldedarrearqtr1 = int.tryParse('0') ?? 0;
      int varNetsalaryarrearqtr1 = int.tryParse('0') ?? 0;

      // =============================== qtr1 ===============================
      int varBpqtr1 = [varBpmar, varBpapr, varBpmay, varBparrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaqtr1 = [varDamar, varDaapr, varDamay, varDaarrearqtr1].fold(0, (sum, value) => sum + value);
      int varHraqtr1 = [varHramar, varHraapr, varHramay, varHraarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNpaqtr1 = [varNpamar, varNpaapr, varNpamay, varNpaarrearqtr1].fold(0, (sum, value) => sum + value);
      int varSplpayqtr1 = [varSplpaymar, varSplpayapr, varSplpaymay, varSplpayarrearqtr1].fold(0, (sum, value) => sum + value);
      int varConvqtr1 = [varConvmar, varConvapr, varConvmay, varConvarrearqtr1].fold(0, (sum, value) => sum + value);
      int varPgqtr1 = [varPgmar, varPgapr, varPgmay, varPgarrearqtr1].fold(0, (sum, value) => sum + value);
      int varAnnualqtr1 = [varAnnualmar, varAnnualapr, varAnnualmay, varAnnualarrearqtr1].fold(0, (sum, value) => sum + value);
      int varUniformqtr1 = [varUniformmar, varUniformapr, varUniformmay, varUniformarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNursingqtr1 = [varNursingmar, varNursingapr, varNursingmay, varNursingarrearqtr1].fold(0, (sum, value) => sum + value);
      int varTaqtr1 = [varTamar, varTaapr, varTamay, varTaarrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaontaqtr1 = [varDaontamar, varDaontaapr, varDaontamay, varDaontaarrearqtr1].fold(0, (sum, value) => sum + value);
      int varMedicalqtr1 = [varMedicalmar, varMedicalapr, varMedicalmay, varMedicalarrearqtr1].fold(0, (sum, value) => sum + value);
      int varDirtqtr1 = [varDirtmar, varDirtapr, varDirtmay, varDirtarrearqtr1].fold(0, (sum, value) => sum + value);
      int varWashingqtr1 = [varWashingmar, varWashingapr, varWashingmay, varWashingarrearqtr1].fold(0, (sum, value) => sum + value);
      int varTbqtr1 = [varTbmar, varTbapr, varTbmay, varTbarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNightqtr1 = [varNightmar, varNightapr, varNightmay, varNightarrearqtr1].fold(0, (sum, value) => sum + value);
      int varDriveqtr1 = [varDrivemar, varDriveapr, varDrivemay, varDrivearrearqtr1].fold(0, (sum, value) => sum + value);
      int varCycleqtr1 = [varCyclemar, varCycleapr, varCyclemay, varCyclearrearqtr1].fold(0, (sum, value) => sum + value);
      int varPcaqtr1 = [varPcamar, varPcaapr, varPcamay, varPcaarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNpsempqtr1 = [varNpsempmar, varNpsempapr, varNpsempmay, varNpsemparrearqtr1].fold(0, (sum, value) => sum + value);
      int varOtherqtr1 = [varOthermar, varOtherapr, varOthermay, varOtherarrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaext1qtr1 = [varDaext1mar, varDaext1apr, varDaext1may, varDaext1arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaext2qtr1 = [varDaext2mar, varDaext2apr, varDaext2may, varDaext2arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaext3qtr1 = [varDaext3mar, varDaext3apr, varDaext3may, varDaext3arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDaext4qtr1 = [varDaext4mar, varDaext4apr, varDaext4may, varDaext4arrearqtr1].fold(0, (sum, value) => sum + value);
      int varSalaryqtr1 = [varBpqtr1, varDaqtr1, varHraqtr1, varNpaqtr1, varSplpayqtr1, varConvqtr1, varPgqtr1,
        varAnnualqtr1, varUniformqtr1, varNursingqtr1, varTaqtr1, varDaontaqtr1, varMedicalqtr1,
        varDirtqtr1, varWashingqtr1, varTbqtr1, varNightqtr1, varDriveqtr1, varCycleqtr1,
        varPcaqtr1, varNpsempqtr1, varOtherqtr1, varDaext1qtr1, varDaext2qtr1, varDaext3qtr1, varDaext4qtr1,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxqtr1 = [varIncometaxmar, varIncometaxapr, varIncometaxmay, varIncometaxarrearqtr1].fold(0, (sum, value) => sum + value);
      int varGisqtr1 = [varGismar, varGisapr, varGismay, varGisarrearqtr1].fold(0, (sum, value) => sum + value);
      int varGpfqtr1 = [varGpfmar, varGpfapr, varGpfmay, varGpfarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNpsqtr1 = [varNpsmar, varNpsapr, varNpsmay, varNpsarrearqtr1].fold(0, (sum, value) => sum + value);
      int varSlfqtr1 = [varSlfmar, varSlfapr, varSlfmay, varSlfarrearqtr1].fold(0, (sum, value) => sum + value);
      int varSocietyqtr1 = [varSocietymar, varSocietyapr, varSocietymay, varSocietyarrearqtr1].fold(0, (sum, value) => sum + value);
      int varRecoveryqtr1 = [varRecoverymar, varRecoveryapr, varRecoverymay, varRecoveryarrearqtr1].fold(0, (sum, value) => sum + value);
      int varWfqtr1 = [varWfmar, varWfapr, varWfmay, varWfarrearqtr1].fold(0, (sum, value) => sum + value);
      int varOther2qtr1 = [varOther2mar, varOther2apr, varOther2may, varOther2arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDdext1qtr1 = [varDdext1mar, varDdext1apr, varDdext1may, varDdext1arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDdext2qtr1 = [varDdext2mar, varDdext2apr, varDdext2may, varDdext2arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDdext3qtr1 = [varDdext3mar, varDdext3apr, varDdext3may, varDdext3arrearqtr1].fold(0, (sum, value) => sum + value);
      int varDdext4qtr1 = [varDdext4mar, varDdext4apr, varDdext4may, varDdext4arrearqtr1].fold(0, (sum, value) => sum + value);
      int varTotaldedqtr1 = [varTotaldedmar, varTotaldedapr, varTotaldedmay, varTotaldedarrearqtr1].fold(0, (sum, value) => sum + value);
      int varNetsalaryqtr1 = [varNetsalarymar, varNetsalaryapr, varNetsalarymay, varNetsalaryarrearqtr1].fold(0, (sum, value) => sum + value);

      // =============================== jun ===============================
      int varBpjun = int.tryParse(junData['bp']?.toString() ?? '0') ?? 0;
      int varDajun = int.tryParse(junData['da']?.toString() ?? '0') ?? 0;
      int varHrajun = int.tryParse(junData['hra']?.toString() ?? '0') ?? 0;
      int varNpajun = int.tryParse(junData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayjun = int.tryParse(junData['splpay']?.toString() ?? '0') ?? 0;
      int varConvjun = int.tryParse(junData['conv']?.toString() ?? '0') ?? 0;
      int varPgjun = int.tryParse(junData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualjun = int.tryParse(junData['annual']?.toString() ?? '0') ?? 0;
      int varUniformjun = int.tryParse(junData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingjun = int.tryParse(junData['nursing']?.toString() ?? '0') ?? 0;
      int varTajun = int.tryParse(junData['ta']?.toString() ?? '0') ?? 0;
      int varDaontajun = int.tryParse(junData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicaljun = int.tryParse(junData['medical']?.toString() ?? '0') ?? 0;
      int varDirtjun = int.tryParse(junData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingjun = int.tryParse(junData['washing']?.toString() ?? '0') ?? 0;
      int varTbjun = int.tryParse(junData['tb']?.toString() ?? '0') ?? 0;
      int varNightjun = int.tryParse(junData['night']?.toString() ?? '0') ?? 0;
      int varDrivejun = int.tryParse(junData['drive']?.toString() ?? '0') ?? 0;
      int varCyclejun = int.tryParse(junData['cycle']?.toString() ?? '0') ?? 0;
      int varPcajun = int.tryParse(junData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempjun = 0;

      if ((junData['nps'] is int ? junData['nps'] : int.tryParse(junData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempjun =(([
          int.tryParse(junData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(junData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(junData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOtherjun = int.tryParse('0') ?? 0;
      int varDaext1jun = int.tryParse(junData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2jun = int.tryParse(junData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3jun = int.tryParse(junData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4jun = int.tryParse(junData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryjun = [
        varBpjun, varDajun, varHrajun, varNpajun, varSplpayjun, varConvjun, varPgjun,
        varAnnualjun, varUniformjun, varNursingjun, varTajun, varDaontajun, varMedicaljun,
        varDirtjun, varWashingjun, varTbjun, varNightjun, varDrivejun, varCyclejun,
        varPcajun, varNpsempjun, varOtherjun, varDaext1jun, varDaext2jun, varDaext3jun, varDaext4jun,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxjun = int.tryParse(junData['incometax']?.toString() ?? '0') ?? 0;
      int varGisjun = int.tryParse(junData['gis']?.toString() ?? '0') ?? 0;
      int varGpfjun = int.tryParse(junData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsjun = int.tryParse(junData['nps']?.toString() ?? '0') ?? 0;
      int varSlfjun = int.tryParse(junData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyjun = int.tryParse(junData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryjun = int.tryParse(junData['recovery']?.toString() ?? '0') ?? 0;
      int varWfjun = int.tryParse(junData['wf']?.toString() ?? '0') ?? 0;
      int varOther2jun = int.tryParse(junData['other']?.toString() ?? '0') ?? 0;
      int varDdext1jun = int.tryParse(junData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2jun = int.tryParse(junData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3jun = int.tryParse(junData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4jun = int.tryParse(junData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedjun = int.tryParse(junData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryjun = int.tryParse(junData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== jul ===============================
      int varBpjul = int.tryParse(julData['bp']?.toString() ?? '0') ?? 0;
      int varDajul = int.tryParse(julData['da']?.toString() ?? '0') ?? 0;
      int varHrajul = int.tryParse(julData['hra']?.toString() ?? '0') ?? 0;
      int varNpajul = int.tryParse(julData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayjul = int.tryParse(julData['splpay']?.toString() ?? '0') ?? 0;
      int varConvjul = int.tryParse(julData['conv']?.toString() ?? '0') ?? 0;
      int varPgjul = int.tryParse(julData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualjul = int.tryParse(julData['annual']?.toString() ?? '0') ?? 0;
      int varUniformjul = int.tryParse(julData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingjul = int.tryParse(julData['nursing']?.toString() ?? '0') ?? 0;
      int varTajul = int.tryParse(julData['ta']?.toString() ?? '0') ?? 0;
      int varDaontajul = int.tryParse(julData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicaljul = int.tryParse(julData['medical']?.toString() ?? '0') ?? 0;
      int varDirtjul = int.tryParse(julData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingjul = int.tryParse(julData['washing']?.toString() ?? '0') ?? 0;
      int varTbjul = int.tryParse(julData['tb']?.toString() ?? '0') ?? 0;
      int varNightjul = int.tryParse(julData['night']?.toString() ?? '0') ?? 0;
      int varDrivejul = int.tryParse(julData['drive']?.toString() ?? '0') ?? 0;
      int varCyclejul = int.tryParse(julData['cycle']?.toString() ?? '0') ?? 0;
      int varPcajul = int.tryParse(julData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempjul = 0;

      if ((julData['nps'] is int ? julData['nps'] : int.tryParse(julData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempjul = (([
          int.tryParse(julData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(julData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(julData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOtherjul = int.tryParse('0') ?? 0;
      int varDaext1jul = int.tryParse(julData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2jul = int.tryParse(julData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3jul = int.tryParse(julData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4jul = int.tryParse(julData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryjul = [
        varBpjul, varDajul, varHrajul, varNpajul, varSplpayjul, varConvjul, varPgjul,
        varAnnualjul, varUniformjul, varNursingjul, varTajul, varDaontajul, varMedicaljul,
        varDirtjul, varWashingjul, varTbjul, varNightjul, varDrivejul, varCyclejul,
        varPcajul, varNpsempjul, varOtherjul, varDaext1jul, varDaext2jul, varDaext3jul, varDaext4jul,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxjul = int.tryParse(julData['incometax']?.toString() ?? '0') ?? 0;
      int varGisjul = int.tryParse(julData['gis']?.toString() ?? '0') ?? 0;
      int varGpfjul = int.tryParse(julData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsjul = int.tryParse(julData['nps']?.toString() ?? '0') ?? 0;
      int varSlfjul = int.tryParse(julData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyjul = int.tryParse(julData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryjul = int.tryParse(julData['recovery']?.toString() ?? '0') ?? 0;
      int varWfjul = int.tryParse(julData['wf']?.toString() ?? '0') ?? 0;
      int varOther2jul = int.tryParse(julData['other']?.toString() ?? '0') ?? 0;
      int varDdext1jul = int.tryParse(julData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2jul = int.tryParse(julData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3jul = int.tryParse(julData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4jul = int.tryParse(julData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedjul = int.tryParse(julData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryjul = int.tryParse(julData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== aug ===============================
      int varBpaug = int.tryParse(augData['bp']?.toString() ?? '0') ?? 0;
      int varDaaug = int.tryParse(augData['da']?.toString() ?? '0') ?? 0;
      int varHraaug = int.tryParse(augData['hra']?.toString() ?? '0') ?? 0;
      int varNpaaug = int.tryParse(augData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayaug = int.tryParse(augData['splpay']?.toString() ?? '0') ?? 0;
      int varConvaug = int.tryParse(augData['conv']?.toString() ?? '0') ?? 0;
      int varPgaug = int.tryParse(augData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualaug = int.tryParse(augData['annual']?.toString() ?? '0') ?? 0;
      int varUniformaug = int.tryParse(augData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingaug = int.tryParse(augData['nursing']?.toString() ?? '0') ?? 0;
      int varTaaug = int.tryParse(augData['ta']?.toString() ?? '0') ?? 0;
      int varDaontaaug = int.tryParse(augData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalaug = int.tryParse(augData['medical']?.toString() ?? '0') ?? 0;
      int varDirtaug = int.tryParse(augData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingaug = int.tryParse(augData['washing']?.toString() ?? '0') ?? 0;
      int varTbaug = int.tryParse(augData['tb']?.toString() ?? '0') ?? 0;
      int varNightaug = int.tryParse(augData['night']?.toString() ?? '0') ?? 0;
      int varDriveaug = int.tryParse(augData['drive']?.toString() ?? '0') ?? 0;
      int varCycleaug = int.tryParse(augData['cycle']?.toString() ?? '0') ?? 0;
      int varPcaaug = int.tryParse(augData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempaug = 0;

      if ((augData['nps'] is int ? augData['nps'] : int.tryParse(augData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempaug = (([
          int.tryParse(augData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(augData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(augData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOtheraug = int.tryParse('0') ?? 0;
      int varDaext1aug = int.tryParse(augData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2aug = int.tryParse(augData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3aug = int.tryParse(augData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4aug = int.tryParse(augData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryaug = [
        varBpaug, varDaaug, varHraaug, varNpaaug, varSplpayaug, varConvaug, varPgaug,
        varAnnualaug, varUniformaug, varNursingaug, varTaaug, varDaontaaug, varMedicalaug,
        varDirtaug, varWashingaug, varTbaug, varNightaug, varDriveaug, varCycleaug,
        varPcaaug, varNpsempaug, varOtheraug, varDaext1aug, varDaext2aug, varDaext3aug, varDaext4aug,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxaug = int.tryParse(augData['incometax']?.toString() ?? '0') ?? 0;
      int varGisaug = int.tryParse(augData['gis']?.toString() ?? '0') ?? 0;
      int varGpfaug = int.tryParse(augData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsaug = int.tryParse(augData['nps']?.toString() ?? '0') ?? 0;
      int varSlfaug = int.tryParse(augData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyaug = int.tryParse(augData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryaug = int.tryParse(augData['recovery']?.toString() ?? '0') ?? 0;
      int varWfaug = int.tryParse(augData['wf']?.toString() ?? '0') ?? 0;
      int varOther2aug = int.tryParse(augData['other']?.toString() ?? '0') ?? 0;
      int varDdext1aug = int.tryParse(augData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2aug = int.tryParse(augData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3aug = int.tryParse(augData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4aug = int.tryParse(augData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedaug = int.tryParse(augData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryaug = int.tryParse(augData['netsalary']?.toString() ?? '0') ?? 0;



      // ============================= arrearqtr2 ==============================
      int varBparrearqtr2 = int.tryParse('0') ?? 0;
      int varDaarrearqtr2 = int.tryParse(arrearData['jada']?.toString() ?? '0') ?? 0;
      int varHraarrearqtr2 = int.tryParse(arrearData['jahra']?.toString() ?? '0') ?? 0;
      int varNpaarrearqtr2 = int.tryParse(arrearData['janpa']?.toString() ?? '0') ?? 0;
      int varSplpayarrearqtr2 = int.tryParse('0') ?? 0;
      int varConvarrearqtr2 = int.tryParse('0') ?? 0;
      int varPgarrearqtr2 = int.tryParse('0') ?? 0;
      int varAnnualarrearqtr2 = int.tryParse('0')?? 0;
      int varUniformarrearqtr2 = int.tryParse('0') ?? 0;
      int varNursingarrearqtr2 = int.tryParse('0') ?? 0;
      int varTaarrearqtr2 = int.tryParse('0') ?? 0;
      int varDaontaarrearqtr2 = int.tryParse(arrearData['jadaonta']?.toString() ?? '0') ?? 0;
      int varMedicalarrearqtr2 = int.tryParse('0') ?? 0;
      int varDirtarrearqtr2 = int.tryParse('0') ?? 0;
      int varWashingarrearqtr2 = int.tryParse('0') ?? 0;
      int varTbarrearqtr2 = int.tryParse('0') ?? 0;
      int varNightarrearqtr2 = int.tryParse('0') ?? 0;
      int varDrivearrearqtr2 = int.tryParse('0') ?? 0;
      int varCyclearrearqtr2 = int.tryParse('0') ?? 0;
      int varPcaarrearqtr2 = int.tryParse(arrearData['japca']?.toString() ?? '0') ?? 0;
      int varNpsemparrearqtr2 = int.tryParse('0') ?? 0;
      int varOtherarrearqtr2 = int.tryParse(arrearData['jaother']?.toString() ?? '0') ?? 0;
      int varDaext1arrearqtr2 = int.tryParse('0') ?? 0;
      int varDaext2arrearqtr2 = int.tryParse('0') ?? 0;
      int varDaext3arrearqtr2 = int.tryParse('0') ?? 0;
      int varDaext4arrearqtr2 = int.tryParse('0') ?? 0;
      int varSalaryarrearqtr2 = [
        varBparrearqtr2, varDaarrearqtr2, varHraarrearqtr2, varNpaarrearqtr2, varSplpayarrearqtr2, varConvarrearqtr2, varPgarrearqtr2,
        varAnnualarrearqtr2, varUniformarrearqtr2, varNursingarrearqtr2, varTaarrearqtr2, varDaontaarrearqtr2, varMedicalarrearqtr2,
        varDirtarrearqtr2, varWashingarrearqtr2, varTbarrearqtr2, varNightarrearqtr2, varDrivearrearqtr2, varCyclearrearqtr2,
        varPcaarrearqtr2, varNpsemparrearqtr2, varOtherarrearqtr2, varDaext1arrearqtr2, varDaext2arrearqtr2, varDaext3arrearqtr2, varDaext4arrearqtr2,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxarrearqtr2 = int.tryParse(arrearData['jaext1']?.toString() ?? '0') ?? 0;
      int varGisarrearqtr2 = int.tryParse('0') ?? 0;
      int varGpfarrearqtr2 = int.tryParse('0') ?? 0;
      int varNpsarrearqtr2 = int.tryParse('0') ?? 0;
      int varSlfarrearqtr2 = int.tryParse('0') ?? 0;
      int varSocietyarrearqtr2 = int.tryParse('0') ?? 0;
      int varRecoveryarrearqtr2 = int.tryParse('0') ?? 0;
      int varWfarrearqtr2 = int.tryParse('0') ?? 0;
      int varOther2arrearqtr2 = int.tryParse('0') ?? 0;
      int varDdext1arrearqtr2 = int.tryParse('0') ?? 0;
      int varDdext2arrearqtr2 = int.tryParse('0') ?? 0;
      int varDdext3arrearqtr2 = int.tryParse('0') ?? 0;
      int varDdext4arrearqtr2 = int.tryParse('0') ?? 0;
      int varTotaldedarrearqtr2 = int.tryParse('0') ?? 0;
      int varNetsalaryarrearqtr2 = int.tryParse('0') ?? 0;

      // =============================== qtr2 ===============================
      int varBpqtr2 = [varBpjun, varBpjul, varBpaug, varBparrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaqtr2 = [varDajun, varDajul, varDaaug, varDaarrearqtr2].fold(0, (sum, value) => sum + value);
      int varHraqtr2 = [varHrajun, varHrajul, varHraaug, varHraarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNpaqtr2 = [varNpajun, varNpajul, varNpaaug, varNpaarrearqtr2].fold(0, (sum, value) => sum + value);
      int varSplpayqtr2 = [varSplpayjun, varSplpayjul, varSplpayaug, varSplpayarrearqtr2].fold(0, (sum, value) => sum + value);
      int varConvqtr2 = [varConvjun, varConvjul, varConvaug, varConvarrearqtr2].fold(0, (sum, value) => sum + value);
      int varPgqtr2 = [varPgjun, varPgjul, varPgaug, varPgarrearqtr2].fold(0, (sum, value) => sum + value);
      int varAnnualqtr2 = [varAnnualjun, varAnnualjul, varAnnualaug, varAnnualarrearqtr2].fold(0, (sum, value) => sum + value);
      int varUniformqtr2 = [varUniformjun, varUniformjul, varUniformaug, varUniformarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNursingqtr2 = [varNursingjun, varNursingjul, varNursingaug, varNursingarrearqtr2].fold(0, (sum, value) => sum + value);
      int varTaqtr2 = [varTajun, varTajul, varTaaug, varTaarrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaontaqtr2 = [varDaontajun, varDaontajul, varDaontaaug, varDaontaarrearqtr2].fold(0, (sum, value) => sum + value);
      int varMedicalqtr2 = [varMedicaljun, varMedicaljul, varMedicalaug, varMedicalarrearqtr2].fold(0, (sum, value) => sum + value);
      int varDirtqtr2 = [varDirtjun, varDirtjul, varDirtaug, varDirtarrearqtr2].fold(0, (sum, value) => sum + value);
      int varWashingqtr2 = [varWashingjun, varWashingjul, varWashingaug, varWashingarrearqtr2].fold(0, (sum, value) => sum + value);
      int varTbqtr2 = [varTbjun, varTbjul, varTbaug, varTbarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNightqtr2 = [varNightjun, varNightjul, varNightaug, varNightarrearqtr2].fold(0, (sum, value) => sum + value);
      int varDriveqtr2 = [varDrivejun, varDrivejul, varDriveaug, varDrivearrearqtr2].fold(0, (sum, value) => sum + value);
      int varCycleqtr2 = [varCyclejun, varCyclejul, varCycleaug, varCyclearrearqtr2].fold(0, (sum, value) => sum + value);
      int varPcaqtr2 = [varPcajun, varPcajul, varPcaaug, varPcaarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNpsempqtr2 = [varNpsempjun, varNpsempjul, varNpsempaug, varNpsemparrearqtr2].fold(0, (sum, value) => sum + value);
      int varOtherqtr2 = [varOtherjun, varOtherjul, varOtheraug, varOtherarrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaext1qtr2 = [varDaext1jun, varDaext1jul, varDaext1aug, varDaext1arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaext2qtr2 = [varDaext2jun, varDaext2jul, varDaext2aug, varDaext2arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaext3qtr2 = [varDaext3jun, varDaext3jul, varDaext3aug, varDaext3arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDaext4qtr2 = [varDaext4jun, varDaext4jul, varDaext4aug, varDaext4arrearqtr2].fold(0, (sum, value) => sum + value);
      int varSalaryqtr2 = [varBpqtr2, varDaqtr2, varHraqtr2, varNpaqtr2, varSplpayqtr2, varConvqtr2, varPgqtr2,
        varAnnualqtr2, varUniformqtr2, varNursingqtr2, varTaqtr2, varDaontaqtr2, varMedicalqtr2,
        varDirtqtr2, varWashingqtr2, varTbqtr2, varNightqtr2, varDriveqtr2, varCycleqtr2,
        varPcaqtr2, varNpsempqtr2, varOtherqtr2, varDaext1qtr2, varDaext2qtr2, varDaext3qtr2, varDaext4qtr2,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxqtr2 = [varIncometaxjun, varIncometaxjul, varIncometaxaug, varIncometaxarrearqtr2].fold(0, (sum, value) => sum + value);
      int varGisqtr2 = [varGisjun, varGisjul, varGisaug, varGisarrearqtr2].fold(0, (sum, value) => sum + value);
      int varGpfqtr2 = [varGpfjun, varGpfjul, varGpfaug, varGpfarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNpsqtr2 = [varNpsjun, varNpsjul, varNpsaug, varNpsarrearqtr2].fold(0, (sum, value) => sum + value);
      int varSlfqtr2 = [varSlfjun, varSlfjul, varSlfaug, varSlfarrearqtr2].fold(0, (sum, value) => sum + value);
      int varSocietyqtr2 = [varSocietyjun, varSocietyjul, varSocietyaug, varSocietyarrearqtr2].fold(0, (sum, value) => sum + value);
      int varRecoveryqtr2 = [varRecoveryjun, varRecoveryjul, varRecoveryaug, varRecoveryarrearqtr2].fold(0, (sum, value) => sum + value);
      int varWfqtr2 = [varWfjun, varWfjul, varWfaug, varWfarrearqtr2].fold(0, (sum, value) => sum + value);
      int varOther2qtr2 = [varOther2jun, varOther2jul, varOther2aug, varOther2arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDdext1qtr2 = [varDdext1jun, varDdext1jul, varDdext1aug, varDdext1arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDdext2qtr2 = [varDdext2jun, varDdext2jul, varDdext2aug, varDdext2arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDdext3qtr2 = [varDdext3jun, varDdext3jul, varDdext3aug, varDdext3arrearqtr2].fold(0, (sum, value) => sum + value);
      int varDdext4qtr2 = [varDdext4jun, varDdext4jul, varDdext4aug, varDdext4arrearqtr2].fold(0, (sum, value) => sum + value);
      int varTotaldedqtr2 = [varTotaldedjun, varTotaldedjul, varTotaldedaug, varTotaldedarrearqtr2].fold(0, (sum, value) => sum + value);
      int varNetsalaryqtr2 = [varNetsalaryjun, varNetsalaryjul, varNetsalaryaug, varNetsalaryarrearqtr2].fold(0, (sum, value) => sum + value);

      // =============================== sept ===============================
      int varBpsept = int.tryParse(septData['bp']?.toString() ?? '0') ?? 0;
      int varDasept = int.tryParse(septData['da']?.toString() ?? '0') ?? 0;
      int varHrasept = int.tryParse(septData['hra']?.toString() ?? '0') ?? 0;
      int varNpasept = int.tryParse(septData['npa']?.toString() ?? '0') ?? 0;
      int varSplpaysept = int.tryParse(septData['splpay']?.toString() ?? '0') ?? 0;
      int varConvsept = int.tryParse(septData['conv']?.toString() ?? '0') ?? 0;
      int varPgsept = int.tryParse(septData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualsept = int.tryParse(septData['annual']?.toString() ?? '0') ?? 0;
      int varUniformsept = int.tryParse(septData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingsept = int.tryParse(septData['nursing']?.toString() ?? '0') ?? 0;
      int varTasept = int.tryParse(septData['ta']?.toString() ?? '0') ?? 0;
      int varDaontasept = int.tryParse(septData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalsept = int.tryParse(septData['medical']?.toString() ?? '0') ?? 0;
      int varDirtsept = int.tryParse(septData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingsept = int.tryParse(septData['washing']?.toString() ?? '0') ?? 0;
      int varTbsept = int.tryParse(septData['tb']?.toString() ?? '0') ?? 0;
      int varNightsept = int.tryParse(septData['night']?.toString() ?? '0') ?? 0;
      int varDrivesept = int.tryParse(septData['drive']?.toString() ?? '0') ?? 0;
      int varCyclesept = int.tryParse(septData['cycle']?.toString() ?? '0') ?? 0;
      int varPcasept = int.tryParse(septData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempsept = 0;

      if ((septData['nps'] is int ? septData['nps'] : int.tryParse(septData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempsept = (([
          int.tryParse(septData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(septData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(septData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
      int varOthersept = int.tryParse('0') ?? 0;
      int varDaext1sept = int.tryParse(septData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2sept = int.tryParse(septData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3sept = int.tryParse(septData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4sept = int.tryParse(septData['daext4']?.toString() ?? '0') ?? 0;
      int varSalarysept = [
        varBpsept, varDasept, varHrasept, varNpasept, varSplpaysept, varConvsept, varPgsept,
        varAnnualsept, varUniformsept, varNursingsept, varTasept, varDaontasept, varMedicalsept,
        varDirtsept, varWashingsept, varTbsept, varNightsept, varDrivesept, varCyclesept,
        varPcasept, varNpsempsept, varOthersept, varDaext1sept, varDaext2sept, varDaext3sept, varDaext4sept,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxsept = int.tryParse(septData['incometax']?.toString() ?? '0') ?? 0;
      int varGissept = int.tryParse(septData['gis']?.toString() ?? '0') ?? 0;
      int varGpfsept = int.tryParse(septData['gpf']?.toString() ?? '0') ?? 0;
      int varNpssept = int.tryParse(septData['nps']?.toString() ?? '0') ?? 0;
      int varSlfsept = int.tryParse(septData['slf']?.toString() ?? '0') ?? 0;
      int varSocietysept = int.tryParse(septData['society']?.toString() ?? '0') ?? 0;
      int varRecoverysept = int.tryParse(septData['recovery']?.toString() ?? '0') ?? 0;
      int varWfsept = int.tryParse(septData['wf']?.toString() ?? '0') ?? 0;
      int varOther2sept = int.tryParse(septData['other']?.toString() ?? '0') ?? 0;
      int varDdext1sept = int.tryParse(septData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2sept = int.tryParse(septData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3sept = int.tryParse(septData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4sept = int.tryParse(septData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedsept = int.tryParse(septData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalarysept = int.tryParse(septData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== oct ===============================
      int varBpoct = int.tryParse(octData['bp']?.toString() ?? '0') ?? 0;
      int varDaoct = int.tryParse(octData['da']?.toString() ?? '0') ?? 0;
      int varHraoct = int.tryParse(octData['hra']?.toString() ?? '0') ?? 0;
      int varNpaoct = int.tryParse(octData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayoct = int.tryParse(octData['splpay']?.toString() ?? '0') ?? 0;
      int varConvoct = int.tryParse(octData['conv']?.toString() ?? '0') ?? 0;
      int varPgoct = int.tryParse(octData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualoct = int.tryParse(octData['annual']?.toString() ?? '0') ?? 0;
      int varUniformoct = int.tryParse(octData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingoct = int.tryParse(octData['nursing']?.toString() ?? '0') ?? 0;
      int varTaoct = int.tryParse(octData['ta']?.toString() ?? '0') ?? 0;
      int varDaontaoct = int.tryParse(octData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicaloct = int.tryParse(octData['medical']?.toString() ?? '0') ?? 0;
      int varDirtoct = int.tryParse(octData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingoct = int.tryParse(octData['washing']?.toString() ?? '0') ?? 0;
      int varTboct = int.tryParse(octData['tb']?.toString() ?? '0') ?? 0;
      int varNightoct = int.tryParse(octData['night']?.toString() ?? '0') ?? 0;
      int varDriveoct = int.tryParse(octData['drive']?.toString() ?? '0') ?? 0;
      int varCycleoct = int.tryParse(octData['cycle']?.toString() ?? '0') ?? 0;
      int varPcaoct = int.tryParse(octData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempoct = 0;

      if ((octData['nps'] is int ? octData['nps'] : int.tryParse(octData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempoct = (([
          int.tryParse(octData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(octData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(octData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
    int varOtheroct = int.tryParse('0') ?? 0;
      int varDaext1oct = int.tryParse(octData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2oct = int.tryParse(octData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3oct = int.tryParse(octData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4oct = int.tryParse(octData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryoct = [
        varBpoct, varDaoct, varHraoct, varNpaoct, varSplpayoct, varConvoct, varPgoct,
        varAnnualoct, varUniformoct, varNursingoct, varTaoct, varDaontaoct, varMedicaloct,
        varDirtoct, varWashingoct, varTboct, varNightoct, varDriveoct, varCycleoct,
        varPcaoct, varNpsempoct, varOtheroct, varDaext1oct, varDaext2oct, varDaext3oct, varDaext4oct,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxoct = int.tryParse(octData['incometax']?.toString() ?? '0') ?? 0;
      int varGisoct = int.tryParse(octData['gis']?.toString() ?? '0') ?? 0;
      int varGpfoct = int.tryParse(octData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsoct = int.tryParse(octData['nps']?.toString() ?? '0') ?? 0;
      int varSlfoct = int.tryParse(octData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyoct = int.tryParse(octData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryoct = int.tryParse(octData['recovery']?.toString() ?? '0') ?? 0;
      int varWfoct = int.tryParse(octData['wf']?.toString() ?? '0') ?? 0;
      int varOther2oct = int.tryParse(octData['other']?.toString() ?? '0') ?? 0;
      int varDdext1oct = int.tryParse(octData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2oct = int.tryParse(octData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3oct = int.tryParse(octData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4oct = int.tryParse(octData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedoct = int.tryParse(octData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryoct = int.tryParse(octData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== nov ===============================
      int varBpnov = int.tryParse(novData['bp']?.toString() ?? '0') ?? 0;
      int varDanov = int.tryParse(novData['da']?.toString() ?? '0') ?? 0;
      int varHranov = int.tryParse(novData['hra']?.toString() ?? '0') ?? 0;
      int varNpanov = int.tryParse(novData['npa']?.toString() ?? '0') ?? 0;
      int varSplpaynov = int.tryParse(novData['splpay']?.toString() ?? '0') ?? 0;
      int varConvnov = int.tryParse(novData['conv']?.toString() ?? '0') ?? 0;
      int varPgnov = int.tryParse(novData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualnov = int.tryParse(novData['annual']?.toString() ?? '0') ?? 0;
      int varUniformnov = int.tryParse(novData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingnov = int.tryParse(novData['nursing']?.toString() ?? '0') ?? 0;
      int varTanov = int.tryParse(novData['ta']?.toString() ?? '0') ?? 0;
      int varDaontanov = int.tryParse(novData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalnov = int.tryParse(novData['medical']?.toString() ?? '0') ?? 0;
      int varDirtnov = int.tryParse(novData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingnov = int.tryParse(novData['washing']?.toString() ?? '0') ?? 0;
      int varTbnov = int.tryParse(novData['tb']?.toString() ?? '0') ?? 0;
      int varNightnov = int.tryParse(novData['night']?.toString() ?? '0') ?? 0;
      int varDrivenov = int.tryParse(novData['drive']?.toString() ?? '0') ?? 0;
      int varCyclenov = int.tryParse(novData['cycle']?.toString() ?? '0') ?? 0;
      int varPcanov = int.tryParse(novData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempnov = 0;

      if ((novData['nps'] is int ? novData['nps'] : int.tryParse(novData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempnov = (([
          int.tryParse(novData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(novData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(novData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
    int varOthernov = int.tryParse('0') ?? 0;
      int varDaext1nov = int.tryParse(novData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2nov = int.tryParse(novData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3nov = int.tryParse(novData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4nov = int.tryParse(novData['daext4']?.toString() ?? '0') ?? 0;
      int varSalarynov = [
        varBpnov, varDanov, varHranov, varNpanov, varSplpaynov, varConvnov, varPgnov,
        varAnnualnov, varUniformnov, varNursingnov, varTanov, varDaontanov, varMedicalnov,
        varDirtnov, varWashingnov, varTbnov, varNightnov, varDrivenov, varCyclenov,
        varPcanov, varNpsempnov, varOthernov, varDaext1nov, varDaext2nov, varDaext3nov, varDaext4nov,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxnov = int.tryParse(novData['incometax']?.toString() ?? '0') ?? 0;
      int varGisnov = int.tryParse(novData['gis']?.toString() ?? '0') ?? 0;
      int varGpfnov = int.tryParse(novData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsnov = int.tryParse(novData['nps']?.toString() ?? '0') ?? 0;
      int varSlfnov = int.tryParse(novData['slf']?.toString() ?? '0') ?? 0;
      int varSocietynov = int.tryParse(novData['society']?.toString() ?? '0') ?? 0;
      int varRecoverynov = int.tryParse(novData['recovery']?.toString() ?? '0') ?? 0;
      int varWfnov = int.tryParse(novData['wf']?.toString() ?? '0') ?? 0;
      int varOther2nov = int.tryParse(novData['other']?.toString() ?? '0') ?? 0;
      int varDdext1nov = int.tryParse(novData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2nov = int.tryParse(novData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3nov = int.tryParse(novData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4nov = int.tryParse(novData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldednov = int.tryParse(novData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalarynov = int.tryParse(novData['netsalary']?.toString() ?? '0') ?? 0;



      // ============================= arrearqtr3 ==============================
      int varBparrearqtr3 = int.tryParse('0') ?? 0;
      int varDaarrearqtr3 = int.tryParse(arrearData['snda']?.toString() ?? '0') ?? 0;
      int varHraarrearqtr3 = int.tryParse(arrearData['snhra']?.toString() ?? '0') ?? 0;
      int varNpaarrearqtr3 = int.tryParse(arrearData['snnpa']?.toString() ?? '0') ?? 0;
      int varSplpayarrearqtr3 = int.tryParse('0') ?? 0;
      int varConvarrearqtr3 = int.tryParse('0') ?? 0;
      int varPgarrearqtr3 = int.tryParse('0') ?? 0;
      int varAnnualarrearqtr3 = int.tryParse('0')?? 0;
      int varUniformarrearqtr3 = int.tryParse('0') ?? 0;
      int varNursingarrearqtr3 = int.tryParse('0') ?? 0;
      int varTaarrearqtr3 = int.tryParse('0') ?? 0;
      int varDaontaarrearqtr3 = int.tryParse(arrearData['sndaonta']?.toString() ?? '0') ?? 0;
      int varMedicalarrearqtr3 = int.tryParse('0') ?? 0;
      int varDirtarrearqtr3 = int.tryParse('0') ?? 0;
      int varWashingarrearqtr3 = int.tryParse('0') ?? 0;
      int varTbarrearqtr3 = int.tryParse('0') ?? 0;
      int varNightarrearqtr3 = int.tryParse('0') ?? 0;
      int varDrivearrearqtr3 = int.tryParse('0') ?? 0;
      int varCyclearrearqtr3 = int.tryParse('0') ?? 0;
      int varPcaarrearqtr3 = int.tryParse(arrearData['snpca']?.toString() ?? '0') ?? 0;
      int varNpsemparrearqtr3 = int.tryParse('0') ?? 0;
      int varOtherarrearqtr3 = int.tryParse(arrearData['snother']?.toString() ?? '0') ?? 0;
      int varDaext1arrearqtr3 = int.tryParse('0') ?? 0;
      int varDaext2arrearqtr3 = int.tryParse('0') ?? 0;
      int varDaext3arrearqtr3 = int.tryParse('0') ?? 0;
      int varDaext4arrearqtr3 = int.tryParse('0') ?? 0;
      int varSalaryarrearqtr3 = [
        varBparrearqtr3, varDaarrearqtr3, varHraarrearqtr3, varNpaarrearqtr3, varSplpayarrearqtr3, varConvarrearqtr3, varPgarrearqtr3,
        varAnnualarrearqtr3, varUniformarrearqtr3, varNursingarrearqtr3, varTaarrearqtr3, varDaontaarrearqtr3, varMedicalarrearqtr3,
        varDirtarrearqtr3, varWashingarrearqtr3, varTbarrearqtr3, varNightarrearqtr3, varDrivearrearqtr3, varCyclearrearqtr3,
        varPcaarrearqtr3, varNpsemparrearqtr3, varOtherarrearqtr3, varDaext1arrearqtr3, varDaext2arrearqtr3, varDaext3arrearqtr3, varDaext4arrearqtr3,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxarrearqtr3 = int.tryParse(arrearData['snext1']?.toString() ?? '0') ?? 0;
      int varGisarrearqtr3 = int.tryParse('0') ?? 0;
      int varGpfarrearqtr3 = int.tryParse('0') ?? 0;
      int varNpsarrearqtr3 = int.tryParse('0') ?? 0;
      int varSlfarrearqtr3 = int.tryParse('0') ?? 0;
      int varSocietyarrearqtr3 = int.tryParse('0') ?? 0;
      int varRecoveryarrearqtr3 = int.tryParse('0') ?? 0;
      int varWfarrearqtr3 = int.tryParse('0') ?? 0;
      int varOther2arrearqtr3 = int.tryParse('0') ?? 0;
      int varDdext1arrearqtr3 = int.tryParse('0') ?? 0;
      int varDdext2arrearqtr3 = int.tryParse('0') ?? 0;
      int varDdext3arrearqtr3 = int.tryParse('0') ?? 0;
      int varDdext4arrearqtr3 = int.tryParse('0') ?? 0;
      int varTotaldedarrearqtr3 = int.tryParse('0') ?? 0;
      int varNetsalaryarrearqtr3 = int.tryParse('0') ?? 0;

      // =============================== qtr3 ===============================
      int varBpqtr3 = [varBpsept, varBpoct, varBpnov, varBparrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaqtr3 = [varDasept, varDaoct, varDanov, varDaarrearqtr3].fold(0, (sum, value) => sum + value);
      int varHraqtr3 = [varHrasept, varHraoct, varHranov, varHraarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNpaqtr3 = [varNpasept, varNpaoct, varNpanov, varNpaarrearqtr3].fold(0, (sum, value) => sum + value);
      int varSplpayqtr3 = [varSplpaysept, varSplpayoct, varSplpaynov, varSplpayarrearqtr3].fold(0, (sum, value) => sum + value);
      int varConvqtr3 = [varConvsept, varConvoct, varConvnov, varConvarrearqtr3].fold(0, (sum, value) => sum + value);
      int varPgqtr3 = [varPgsept, varPgoct, varPgnov, varPgarrearqtr3].fold(0, (sum, value) => sum + value);
      int varAnnualqtr3 = [varAnnualsept, varAnnualoct, varAnnualnov, varAnnualarrearqtr3].fold(0, (sum, value) => sum + value);
      int varUniformqtr3 = [varUniformsept, varUniformoct, varUniformnov, varUniformarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNursingqtr3 = [varNursingsept, varNursingoct, varNursingnov, varNursingarrearqtr3].fold(0, (sum, value) => sum + value);
      int varTaqtr3 = [varTasept, varTaoct, varTanov, varTaarrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaontaqtr3 = [varDaontasept, varDaontaoct, varDaontanov, varDaontaarrearqtr3].fold(0, (sum, value) => sum + value);
      int varMedicalqtr3 = [varMedicalsept, varMedicaloct, varMedicalnov, varMedicalarrearqtr3].fold(0, (sum, value) => sum + value);
      int varDirtqtr3 = [varDirtsept, varDirtoct, varDirtnov, varDirtarrearqtr3].fold(0, (sum, value) => sum + value);
      int varWashingqtr3 = [varWashingsept, varWashingoct, varWashingnov, varWashingarrearqtr3].fold(0, (sum, value) => sum + value);
      int varTbqtr3 = [varTbsept, varTboct, varTbnov, varTbarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNightqtr3 = [varNightsept, varNightoct, varNightnov, varNightarrearqtr3].fold(0, (sum, value) => sum + value);
      int varDriveqtr3 = [varDrivesept, varDriveoct, varDrivenov, varDrivearrearqtr3].fold(0, (sum, value) => sum + value);
      int varCycleqtr3 = [varCyclesept, varCycleoct, varCyclenov, varCyclearrearqtr3].fold(0, (sum, value) => sum + value);
      int varPcaqtr3 = [varPcasept, varPcaoct, varPcanov, varPcaarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNpsempqtr3 = [varNpsempsept, varNpsempoct, varNpsempnov, varNpsemparrearqtr3].fold(0, (sum, value) => sum + value);
      int varOtherqtr3 = [varOthersept, varOtheroct, varOthernov, varOtherarrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaext1qtr3 = [varDaext1sept, varDaext1oct, varDaext1nov, varDaext1arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaext2qtr3 = [varDaext2sept, varDaext2oct, varDaext2nov, varDaext2arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaext3qtr3 = [varDaext3sept, varDaext3oct, varDaext3nov, varDaext3arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDaext4qtr3 = [varDaext4sept, varDaext4oct, varDaext4nov, varDaext4arrearqtr3].fold(0, (sum, value) => sum + value);
      int varSalaryqtr3 = [varBpqtr3, varDaqtr3, varHraqtr3, varNpaqtr3, varSplpayqtr3, varConvqtr3, varPgqtr3,
        varAnnualqtr3, varUniformqtr3, varNursingqtr3, varTaqtr3, varDaontaqtr3, varMedicalqtr3,
        varDirtqtr3, varWashingqtr3, varTbqtr3, varNightqtr3, varDriveqtr3, varCycleqtr3,
        varPcaqtr3, varNpsempqtr3, varOtherqtr3, varDaext1qtr3, varDaext2qtr3, varDaext3qtr3, varDaext4qtr3,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxqtr3 = [varIncometaxsept, varIncometaxoct, varIncometaxnov, varIncometaxarrearqtr3].fold(0, (sum, value) => sum + value);
      int varGisqtr3 = [varGissept, varGisoct, varGisnov, varGisarrearqtr3].fold(0, (sum, value) => sum + value);
      int varGpfqtr3 = [varGpfsept, varGpfoct, varGpfnov, varGpfarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNpsqtr3 = [varNpssept, varNpsoct, varNpsnov, varNpsarrearqtr3].fold(0, (sum, value) => sum + value);
      int varSlfqtr3 = [varSlfsept, varSlfoct, varSlfnov, varSlfarrearqtr3].fold(0, (sum, value) => sum + value);
      int varSocietyqtr3 = [varSocietysept, varSocietyoct, varSocietynov, varSocietyarrearqtr3].fold(0, (sum, value) => sum + value);
      int varRecoveryqtr3 = [varRecoverysept, varRecoveryoct, varRecoverynov, varRecoveryarrearqtr3].fold(0, (sum, value) => sum + value);
      int varWfqtr3 = [varWfsept, varWfoct, varWfnov, varWfarrearqtr3].fold(0, (sum, value) => sum + value);
      int varOther2qtr3 = [varOther2sept, varOther2oct, varOther2nov, varOther2arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDdext1qtr3 = [varDdext1sept, varDdext1oct, varDdext1nov, varDdext1arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDdext2qtr3 = [varDdext2sept, varDdext2oct, varDdext2nov, varDdext2arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDdext3qtr3 = [varDdext3sept, varDdext3oct, varDdext3nov, varDdext3arrearqtr3].fold(0, (sum, value) => sum + value);
      int varDdext4qtr3 = [varDdext4sept, varDdext4oct, varDdext4nov, varDdext4arrearqtr3].fold(0, (sum, value) => sum + value);
      int varTotaldedqtr3 = [varTotaldedsept, varTotaldedoct, varTotaldednov, varTotaldedarrearqtr3].fold(0, (sum, value) => sum + value);
      int varNetsalaryqtr3 = [varNetsalarysept, varNetsalaryoct, varNetsalarynov, varNetsalaryarrearqtr3].fold(0, (sum, value) => sum + value);

      // =============================== dec ===============================
      int varBpdec = int.tryParse(decData['bp']?.toString() ?? '0') ?? 0;
      int varDadec = int.tryParse(decData['da']?.toString() ?? '0') ?? 0;
      int varHradec = int.tryParse(decData['hra']?.toString() ?? '0') ?? 0;
      int varNpadec = int.tryParse(decData['npa']?.toString() ?? '0') ?? 0;
      int varSplpaydec = int.tryParse(decData['splpay']?.toString() ?? '0') ?? 0;
      int varConvdec = int.tryParse(decData['conv']?.toString() ?? '0') ?? 0;
      int varPgdec = int.tryParse(decData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualdec = int.tryParse(decData['annual']?.toString() ?? '0') ?? 0;
      int varUniformdec = int.tryParse(decData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingdec = int.tryParse(decData['nursing']?.toString() ?? '0') ?? 0;
      int varTadec = int.tryParse(decData['ta']?.toString() ?? '0') ?? 0;
      int varDaontadec = int.tryParse(decData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicaldec = int.tryParse(decData['medical']?.toString() ?? '0') ?? 0;
      int varDirtdec = int.tryParse(decData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingdec = int.tryParse(decData['washing']?.toString() ?? '0') ?? 0;
      int varTbdec = int.tryParse(decData['tb']?.toString() ?? '0') ?? 0;
      int varNightdec = int.tryParse(decData['night']?.toString() ?? '0') ?? 0;
      int varDrivedec = int.tryParse(decData['drive']?.toString() ?? '0') ?? 0;
      int varCycledec = int.tryParse(decData['cycle']?.toString() ?? '0') ?? 0;
      int varPcadec = int.tryParse(decData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempdec = 0;
      if ((decData['nps'] is int ? decData['nps'] : int.tryParse(decData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempdec = (([
          int.tryParse(decData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(decData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(decData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
    int varOtherdec = int.tryParse('0') ?? 0;
      int varDaext1dec = int.tryParse(decData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2dec = int.tryParse(decData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3dec = int.tryParse(decData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4dec = int.tryParse(decData['daext4']?.toString() ?? '0') ?? 0;
      int varSalarydec = [
        varBpdec, varDadec, varHradec, varNpadec, varSplpaydec, varConvdec, varPgdec,
        varAnnualdec, varUniformdec, varNursingdec, varTadec, varDaontadec, varMedicaldec,
        varDirtdec, varWashingdec, varTbdec, varNightdec, varDrivedec, varCycledec,
        varPcadec, varNpsempdec, varOtherdec, varDaext1dec, varDaext2dec, varDaext3dec, varDaext4dec,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxdec = int.tryParse(decData['incometax']?.toString() ?? '0') ?? 0;
      int varGisdec = int.tryParse(decData['gis']?.toString() ?? '0') ?? 0;
      int varGpfdec = int.tryParse(decData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsdec = int.tryParse(decData['nps']?.toString() ?? '0') ?? 0;
      int varSlfdec = int.tryParse(decData['slf']?.toString() ?? '0') ?? 0;
      int varSocietydec = int.tryParse(decData['society']?.toString() ?? '0') ?? 0;
      int varRecoverydec = int.tryParse(decData['recovery']?.toString() ?? '0') ?? 0;
      int varWfdec = int.tryParse(decData['wf']?.toString() ?? '0') ?? 0;
      int varOther2dec = int.tryParse(decData['other']?.toString() ?? '0') ?? 0;
      int varDdext1dec = int.tryParse(decData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2dec = int.tryParse(decData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3dec = int.tryParse(decData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4dec = int.tryParse(decData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldeddec = int.tryParse(decData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalarydec = int.tryParse(decData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== jan ===============================
      int varBpjan = int.tryParse(janData['bp']?.toString() ?? '0') ?? 0;
      int varDajan = int.tryParse(janData['da']?.toString() ?? '0') ?? 0;
      int varHrajan = int.tryParse(janData['hra']?.toString() ?? '0') ?? 0;
      int varNpajan = int.tryParse(janData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayjan = int.tryParse(janData['splpay']?.toString() ?? '0') ?? 0;
      int varConvjan = int.tryParse(janData['conv']?.toString() ?? '0') ?? 0;
      int varPgjan = int.tryParse(janData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualjan = int.tryParse(janData['annual']?.toString() ?? '0') ?? 0;
      int varUniformjan = int.tryParse(janData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingjan = int.tryParse(janData['nursing']?.toString() ?? '0') ?? 0;
      int varTajan = int.tryParse(janData['ta']?.toString() ?? '0') ?? 0;
      int varDaontajan = int.tryParse(janData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicaljan = int.tryParse(janData['medical']?.toString() ?? '0') ?? 0;
      int varDirtjan = int.tryParse(janData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingjan = int.tryParse(janData['washing']?.toString() ?? '0') ?? 0;
      int varTbjan = int.tryParse(janData['tb']?.toString() ?? '0') ?? 0;
      int varNightjan = int.tryParse(janData['night']?.toString() ?? '0') ?? 0;
      int varDrivejan = int.tryParse(janData['drive']?.toString() ?? '0') ?? 0;
      int varCyclejan = int.tryParse(janData['cycle']?.toString() ?? '0') ?? 0;
      int varPcajan = int.tryParse(janData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempjan = 0;

      if ((janData['nps'] is int ? janData['nps'] : int.tryParse(janData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempjan = (([
          int.tryParse(janData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(janData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(janData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
    int varOtherjan = int.tryParse('0') ?? 0;
      int varDaext1jan = int.tryParse(janData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2jan = int.tryParse(janData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3jan = int.tryParse(janData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4jan = int.tryParse(janData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryjan = [
        varBpjan, varDajan, varHrajan, varNpajan, varSplpayjan, varConvjan, varPgjan,
        varAnnualjan, varUniformjan, varNursingjan, varTajan, varDaontajan, varMedicaljan,
        varDirtjan, varWashingjan, varTbjan, varNightjan, varDrivejan, varCyclejan,
        varPcajan, varNpsempjan, varOtherjan, varDaext1jan, varDaext2jan, varDaext3jan, varDaext4jan,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxjan = int.tryParse(janData['incometax']?.toString() ?? '0') ?? 0;
      int varGisjan = int.tryParse(janData['gis']?.toString() ?? '0') ?? 0;
      int varGpfjan = int.tryParse(janData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsjan = int.tryParse(janData['nps']?.toString() ?? '0') ?? 0;
      int varSlfjan = int.tryParse(janData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyjan = int.tryParse(janData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryjan = int.tryParse(janData['recovery']?.toString() ?? '0') ?? 0;
      int varWfjan = int.tryParse(janData['wf']?.toString() ?? '0') ?? 0;
      int varOther2jan = int.tryParse(janData['other']?.toString() ?? '0') ?? 0;
      int varDdext1jan = int.tryParse(janData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2jan = int.tryParse(janData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3jan = int.tryParse(janData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4jan = int.tryParse(janData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedjan = int.tryParse(janData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryjan = int.tryParse(janData['netsalary']?.toString() ?? '0') ?? 0;

      // =============================== feb ===============================
      int varBpfeb = int.tryParse(febData['bp']?.toString() ?? '0') ?? 0;
      int varDafeb = int.tryParse(febData['da']?.toString() ?? '0') ?? 0;
      int varHrafeb = int.tryParse(febData['hra']?.toString() ?? '0') ?? 0;
      int varNpafeb = int.tryParse(febData['npa']?.toString() ?? '0') ?? 0;
      int varSplpayfeb = int.tryParse(febData['splpay']?.toString() ?? '0') ?? 0;
      int varConvfeb = int.tryParse(febData['conv']?.toString() ?? '0') ?? 0;
      int varPgfeb = int.tryParse(febData['pg']?.toString() ?? '0') ?? 0;
      int varAnnualfeb = int.tryParse(febData['annual']?.toString() ?? '0') ?? 0;
      int varUniformfeb = int.tryParse(febData['uniform']?.toString() ?? '0') ?? 0;
      int varNursingfeb = int.tryParse(febData['nursing']?.toString() ?? '0') ?? 0;
      int varTafeb = int.tryParse(febData['ta']?.toString() ?? '0') ?? 0;
      int varDaontafeb = int.tryParse(febData['daonta']?.toString() ?? '0') ?? 0;
      int varMedicalfeb = int.tryParse(febData['medical']?.toString() ?? '0') ?? 0;
      int varDirtfeb = int.tryParse(febData['dirt']?.toString() ?? '0') ?? 0;
      int varWashingfeb = int.tryParse(febData['washing']?.toString() ?? '0') ?? 0;
      int varTbfeb = int.tryParse(febData['tb']?.toString() ?? '0') ?? 0;
      int varNightfeb = int.tryParse(febData['night']?.toString() ?? '0') ?? 0;
      int varDrivefeb = int.tryParse(febData['drive']?.toString() ?? '0') ?? 0;
      int varCyclefeb = int.tryParse(febData['cycle']?.toString() ?? '0') ?? 0;
      int varPcafeb = int.tryParse(febData['pca']?.toString() ?? '0') ?? 0;
      int varNpsempfeb = 0;
      if ((febData['nps'] is int ? febData['nps'] : int.tryParse(febData['nps']?.toString() ?? '0') ?? 0) > 0) {
        varNpsempfeb = (([
          int.tryParse(febData['da']?.toString() ?? '0') ?? 0,
          int.tryParse(febData['bp']?.toString() ?? '0') ?? 0,
          int.tryParse(febData['npa']?.toString() ?? '0') ?? 0
        ].fold(0, (sum, value) => sum + value))*0.14).round();
      }
    int varOtherfeb = int.tryParse('0') ?? 0;
      int varDaext1feb = int.tryParse(febData['daext1']?.toString() ?? '0') ?? 0;
      int varDaext2feb = int.tryParse(febData['daext2']?.toString() ?? '0') ?? 0;
      int varDaext3feb = int.tryParse(febData['daext3']?.toString() ?? '0') ?? 0;
      int varDaext4feb = int.tryParse(febData['daext4']?.toString() ?? '0') ?? 0;
      int varSalaryfeb = [
        varBpfeb, varDafeb, varHrafeb, varNpafeb, varSplpayfeb, varConvfeb, varPgfeb,
        varAnnualfeb, varUniformfeb, varNursingfeb, varTafeb, varDaontafeb, varMedicalfeb,
        varDirtfeb, varWashingfeb, varTbfeb, varNightfeb, varDrivefeb, varCyclefeb,
        varPcafeb, varNpsempfeb, varOtherfeb, varDaext1feb, varDaext2feb, varDaext3feb, varDaext4feb,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxfeb = int.tryParse(febData['incometax']?.toString() ?? '0') ?? 0;
      int varGisfeb = int.tryParse(febData['gis']?.toString() ?? '0') ?? 0;
      int varGpffeb = int.tryParse(febData['gpf']?.toString() ?? '0') ?? 0;
      int varNpsfeb = int.tryParse(febData['nps']?.toString() ?? '0') ?? 0;
      int varSlffeb = int.tryParse(febData['slf']?.toString() ?? '0') ?? 0;
      int varSocietyfeb = int.tryParse(febData['society']?.toString() ?? '0') ?? 0;
      int varRecoveryfeb = int.tryParse(febData['recovery']?.toString() ?? '0') ?? 0;
      int varWffeb = int.tryParse(febData['wf']?.toString() ?? '0') ?? 0;
      int varOther2feb = int.tryParse(febData['other']?.toString() ?? '0') ?? 0;
      int varDdext1feb = int.tryParse(febData['ddext1']?.toString() ?? '0') ?? 0;
      int varDdext2feb = int.tryParse(febData['ddext2']?.toString() ?? '0') ?? 0;
      int varDdext3feb = int.tryParse(febData['ddext3']?.toString() ?? '0') ?? 0;
      int varDdext4feb = int.tryParse(febData['ddext4']?.toString() ?? '0') ?? 0;
      int varTotaldedfeb = int.tryParse(febData['totalded']?.toString() ?? '0') ?? 0;
      int varNetsalaryfeb = int.tryParse(febData['netsalary']?.toString() ?? '0') ?? 0;



      // ============================= arrearqtr4 ==============================
      int varBparrearqtr4 = int.tryParse('0') ?? 0;
      int varDaarrearqtr4 = int.tryParse(arrearData['dfda']?.toString() ?? '0') ?? 0;
      int varHraarrearqtr4 = int.tryParse(arrearData['dfhra']?.toString() ?? '0') ?? 0;
      int varNpaarrearqtr4 = int.tryParse(arrearData['dfnpa']?.toString() ?? '0') ?? 0;
      int varSplpayarrearqtr4 = int.tryParse('0') ?? 0;
      int varConvarrearqtr4 = int.tryParse('0') ?? 0;
      int varPgarrearqtr4 = int.tryParse('0') ?? 0;
      int varAnnualarrearqtr4 = int.tryParse('0')?? 0;
      int varUniformarrearqtr4 = int.tryParse('0') ?? 0;
      int varNursingarrearqtr4 = int.tryParse('0') ?? 0;
      int varTaarrearqtr4 = int.tryParse('0') ?? 0;
      int varDaontaarrearqtr4 = int.tryParse(arrearData['dfdaonta']?.toString() ?? '0') ?? 0;
      int varMedicalarrearqtr4 = int.tryParse('0') ?? 0;
      int varDirtarrearqtr4 = int.tryParse('0') ?? 0;
      int varWashingarrearqtr4 = int.tryParse('0') ?? 0;
      int varTbarrearqtr4 = int.tryParse('0') ?? 0;
      int varNightarrearqtr4 = int.tryParse('0') ?? 0;
      int varDrivearrearqtr4 = int.tryParse('0') ?? 0;
      int varCyclearrearqtr4 = int.tryParse('0') ?? 0;
      int varPcaarrearqtr4 = int.tryParse(arrearData['dfpca']?.toString() ?? '0') ?? 0;
      int varNpsemparrearqtr4 = int.tryParse('0') ?? 0;
      int varOtherarrearqtr4 = int.tryParse(arrearData['dfother']?.toString() ?? '0') ?? 0;
      int varDaext1arrearqtr4 = int.tryParse('0') ?? 0;
      int varDaext2arrearqtr4 = int.tryParse('0') ?? 0;
      int varDaext3arrearqtr4 = int.tryParse('0') ?? 0;
      int varDaext4arrearqtr4 = int.tryParse('0') ?? 0;
      int varSalaryarrearqtr4 = [
        varBparrearqtr4, varDaarrearqtr4, varHraarrearqtr4, varNpaarrearqtr4, varSplpayarrearqtr4, varConvarrearqtr4, varPgarrearqtr4,
        varAnnualarrearqtr4, varUniformarrearqtr4, varNursingarrearqtr4, varTaarrearqtr4, varDaontaarrearqtr4, varMedicalarrearqtr4,
        varDirtarrearqtr4, varWashingarrearqtr4, varTbarrearqtr4, varNightarrearqtr4, varDrivearrearqtr4, varCyclearrearqtr4,
        varPcaarrearqtr4, varNpsemparrearqtr4, varOtherarrearqtr4, varDaext1arrearqtr4, varDaext2arrearqtr4, varDaext3arrearqtr4, varDaext4arrearqtr4,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxarrearqtr4 = int.tryParse(arrearData['dfext1']?.toString() ?? '0') ?? 0;
      int varGisarrearqtr4 = int.tryParse('0') ?? 0;
      int varGpfarrearqtr4 = int.tryParse('0') ?? 0;
      int varNpsarrearqtr4 = int.tryParse('0') ?? 0;
      int varSlfarrearqtr4 = int.tryParse('0') ?? 0;
      int varSocietyarrearqtr4 = int.tryParse('0') ?? 0;
      int varRecoveryarrearqtr4 = int.tryParse('0') ?? 0;
      int varWfarrearqtr4 = int.tryParse('0') ?? 0;
      int varOther2arrearqtr4 = int.tryParse('0') ?? 0;
      int varDdext1arrearqtr4 = int.tryParse('0') ?? 0;
      int varDdext2arrearqtr4 = int.tryParse('0') ?? 0;
      int varDdext3arrearqtr4 = int.tryParse('0') ?? 0;
      int varDdext4arrearqtr4 = int.tryParse('0') ?? 0;
      int varTotaldedarrearqtr4 = int.tryParse('0') ?? 0;
      int varNetsalaryarrearqtr4 = int.tryParse('0') ?? 0;

      //===========================tution & bonus===========================
      int varTution = [int.tryParse(arrearData['mmtution']?.toString() ?? '0') ?? 0, int.tryParse(arrearData['jatution']?.toString() ?? '0') ?? 0, int.tryParse(arrearData['sntution']?.toString() ?? '0') ?? 0, int.tryParse(arrearData['dftution']?.toString() ?? '0') ?? 0].fold(0, (sum, value) => sum + value);
      int varSalarytution = varTution;
      int varBonus = int.tryParse(arrearData['bonus']?.toString() ?? '0') ?? 0;
      int varSalarybonus = varBonus;

      // =============================== qtr4 ===============================
      int varBpqtr4 = [varBpdec, varBpjan, varBpfeb, varBparrearqtr4].fold(0, (sum, value) => sum + value);
      int varDaqtr4 = [varDadec, varDajan, varDafeb, varDaarrearqtr4].fold(0, (sum, value) => sum + value);
      int varHraqtr4 = [varHradec, varHrajan, varHrafeb, varHraarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNpaqtr4 = [varNpadec, varNpajan, varNpafeb, varNpaarrearqtr4].fold(0, (sum, value) => sum + value);
      int varSplpayqtr4 = [varSplpaydec, varSplpayjan, varSplpayfeb, varSplpayarrearqtr4].fold(0, (sum, value) => sum + value);
      int varConvqtr4 = [varConvdec, varConvjan, varConvfeb, varConvarrearqtr4].fold(0, (sum, value) => sum + value);
      int varPgqtr4 = [varPgdec, varPgjan, varPgfeb, varPgarrearqtr4].fold(0, (sum, value) => sum + value);
      int varAnnualqtr4 = [varAnnualdec, varAnnualjan, varAnnualfeb, varAnnualarrearqtr4].fold(0, (sum, value) => sum + value);
      int varUniformqtr4 = [varUniformdec, varUniformjan, varUniformfeb, varUniformarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNursingqtr4 = [varNursingdec, varNursingjan, varNursingfeb, varNursingarrearqtr4].fold(0, (sum, value) => sum + value);
      int varTaqtr4 = [varTadec, varTajan, varTafeb, varTaarrearqtr4].fold(0, (sum, value) => sum + value);
      int varDaontaqtr4 = [varDaontadec, varDaontajan, varDaontafeb, varDaontaarrearqtr4].fold(0, (sum, value) => sum + value);
      int varMedicalqtr4 = [varMedicaldec, varMedicaljan, varMedicalfeb, varMedicalarrearqtr4].fold(0, (sum, value) => sum + value);
      int varDirtqtr4 = [varDirtdec, varDirtjan, varDirtfeb, varDirtarrearqtr4].fold(0, (sum, value) => sum + value);
      int varWashingqtr4 = [varWashingdec, varWashingjan, varWashingfeb, varWashingarrearqtr4].fold(0, (sum, value) => sum + value);
      int varTbqtr4 = [varTbdec, varTbjan, varTbfeb, varTbarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNightqtr4 = [varNightdec, varNightjan, varNightfeb, varNightarrearqtr4].fold(0, (sum, value) => sum + value);
      int varDriveqtr4 = [varDrivedec, varDrivejan, varDrivefeb, varDrivearrearqtr4].fold(0, (sum, value) => sum + value);
      int varCycleqtr4 = [varCycledec, varCyclejan, varCyclefeb, varCyclearrearqtr4].fold(0, (sum, value) => sum + value);
      int varPcaqtr4 = [varPcadec, varPcajan, varPcafeb, varPcaarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNpsempqtr4 = [varNpsempdec, varNpsempjan, varNpsempfeb, varNpsemparrearqtr4].fold(0, (sum, value) => sum + value);
      int varOtherqtr4 = [varOtherdec, varOtherjan, varOtherfeb, varOtherarrearqtr4, varTution, varBonus].fold(0, (sum, value) => sum + value);
      int varDaext1qtr4 = [varDaext1dec, varDaext1jan, varDaext1feb, varDaext1arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDaext2qtr4 = [varDaext2dec, varDaext2jan, varDaext2feb, varDaext2arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDaext3qtr4 = [varDaext3dec, varDaext3jan, varDaext3feb, varDaext3arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDaext4qtr4 = [varDaext4dec, varDaext4jan, varDaext4feb, varDaext4arrearqtr4].fold(0, (sum, value) => sum + value);
      int varSalaryqtr4 = [varBpqtr4, varDaqtr4, varHraqtr4, varNpaqtr4, varSplpayqtr4, varConvqtr4, varPgqtr4,
        varAnnualqtr4, varUniformqtr4, varNursingqtr4, varTaqtr4, varDaontaqtr4, varMedicalqtr4,
        varDirtqtr4, varWashingqtr4, varTbqtr4, varNightqtr4, varDriveqtr4, varCycleqtr4,
        varPcaqtr4, varNpsempqtr4, varOtherqtr4, varDaext1qtr4, varDaext2qtr4, varDaext3qtr4, varDaext4qtr4,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxqtr4 = [varIncometaxdec, varIncometaxjan, varIncometaxfeb, varIncometaxarrearqtr4].fold(0, (sum, value) => sum + value);
      int varGisqtr4 = [varGisdec, varGisjan, varGisfeb, varGisarrearqtr4].fold(0, (sum, value) => sum + value);
      int varGpfqtr4 = [varGpfdec, varGpfjan, varGpffeb, varGpfarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNpsqtr4 = [varNpsdec, varNpsjan, varNpsfeb, varNpsarrearqtr4].fold(0, (sum, value) => sum + value);
      int varSlfqtr4 = [varSlfdec, varSlfjan, varSlffeb, varSlfarrearqtr4].fold(0, (sum, value) => sum + value);
      int varSocietyqtr4 = [varSocietydec, varSocietyjan, varSocietyfeb, varSocietyarrearqtr4].fold(0, (sum, value) => sum + value);
      int varRecoveryqtr4 = [varRecoverydec, varRecoveryjan, varRecoveryfeb, varRecoveryarrearqtr4].fold(0, (sum, value) => sum + value);
      int varWfqtr4 = [varWfdec, varWfjan, varWffeb, varWfarrearqtr4].fold(0, (sum, value) => sum + value);
      int varOther2qtr4 = [varOther2dec, varOther2jan, varOther2feb, varOther2arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDdext1qtr4 = [varDdext1dec, varDdext1jan, varDdext1feb, varDdext1arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDdext2qtr4 = [varDdext2dec, varDdext2jan, varDdext2feb, varDdext2arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDdext3qtr4 = [varDdext3dec, varDdext3jan, varDdext3feb, varDdext3arrearqtr4].fold(0, (sum, value) => sum + value);
      int varDdext4qtr4 = [varDdext4dec, varDdext4jan, varDdext4feb, varDdext4arrearqtr4].fold(0, (sum, value) => sum + value);
      int varTotaldedqtr4 = [varTotaldeddec, varTotaldedjan, varTotaldedfeb, varTotaldedarrearqtr4].fold(0, (sum, value) => sum + value);
      int varNetsalaryqtr4 = [varNetsalarydec, varNetsalaryjan, varNetsalaryfeb, varNetsalaryarrearqtr4].fold(0, (sum, value) => sum + value);

      // ============================================= gross total ==========================================
      int varBpgross = [varBpqtr1, varBpqtr2, varBpqtr3, varBpqtr4].fold(0, (sum, value) => sum + value);
      int varDagross = [varDaqtr1, varDaqtr2, varDaqtr3, varDaqtr4].fold(0, (sum, value) => sum + value);
      int varHragross = [varHraqtr1, varHraqtr2, varHraqtr3, varHraqtr4].fold(0, (sum, value) => sum + value);
      int varNpagross = [varNpaqtr1, varNpaqtr2, varNpaqtr3, varNpaqtr4].fold(0, (sum, value) => sum + value);
      int varSplpaygross = [varSplpayqtr1, varSplpayqtr2, varSplpayqtr3, varSplpayqtr4].fold(0, (sum, value) => sum + value);
      int varConvgross = [varConvqtr1, varConvqtr2, varConvqtr3, varConvqtr4].fold(0, (sum, value) => sum + value);
      int varPggross = [varPgqtr1, varPgqtr2, varPgqtr3, varPgqtr4].fold(0, (sum, value) => sum + value);
      int varAnnualgross = [varAnnualqtr1, varAnnualqtr2, varAnnualqtr3, varAnnualqtr4].fold(0, (sum, value) => sum + value);
      int varUniformgross = [varUniformqtr1, varUniformqtr2, varUniformqtr3, varUniformqtr4].fold(0, (sum, value) => sum + value);
      int varNursinggross = [varNursingqtr1, varNursingqtr2, varNursingqtr3, varNursingqtr4].fold(0, (sum, value) => sum + value);
      int varTagross = [varTaqtr1, varTaqtr2, varTaqtr3, varTaqtr4].fold(0, (sum, value) => sum + value);
      int varDaontagross = [varDaontaqtr1, varDaontaqtr2, varDaontaqtr3, varDaontaqtr4].fold(0, (sum, value) => sum + value);
      int varMedicalgross = [varMedicalqtr1, varMedicalqtr2, varMedicalqtr3, varMedicalqtr4].fold(0, (sum, value) => sum + value);
      int varDirtgross = [varDirtqtr1, varDirtqtr2, varDirtqtr3, varDirtqtr4].fold(0, (sum, value) => sum + value);
      int varWashinggross = [varWashingqtr1, varWashingqtr2, varWashingqtr3, varWashingqtr4].fold(0, (sum, value) => sum + value);
      int varTbgross = [varTbqtr1, varTbqtr2, varTbqtr3, varTbqtr4].fold(0, (sum, value) => sum + value);
      int varNightgross = [varNightqtr1, varNightqtr2, varNightqtr3, varNightqtr4].fold(0, (sum, value) => sum + value);
      int varDrivegross = [varDriveqtr1, varDriveqtr2, varDriveqtr3, varDriveqtr4].fold(0, (sum, value) => sum + value);
      int varCyclegross = [varCycleqtr1, varCycleqtr2, varCycleqtr3, varCycleqtr4].fold(0, (sum, value) => sum + value);
      int varPcagross = [varPcaqtr1, varPcaqtr2, varPcaqtr3, varPcaqtr4].fold(0, (sum, value) => sum + value);
      int varNpsempgross = [varNpsempqtr1, varNpsempqtr2, varNpsempqtr3, varNpsempqtr4].fold(0, (sum, value) => sum + value);
      int varOthergross = [varOtherqtr1, varOtherqtr2, varOtherqtr3, varOtherqtr4].fold(0, (sum, value) => sum + value);
      int varDaext1gross = [varDaext1qtr1, varDaext1qtr2, varDaext1qtr3, varDaext1qtr4].fold(0, (sum, value) => sum + value);
      int varDaext2gross = [varDaext2qtr1, varDaext2qtr2, varDaext2qtr3, varDaext2qtr4].fold(0, (sum, value) => sum + value);
      int varDaext3gross = [varDaext3qtr1, varDaext3qtr2, varDaext3qtr3, varDaext3qtr4].fold(0, (sum, value) => sum + value);
      int varDaext4gross = [varDaext4qtr1, varDaext4qtr2, varDaext4qtr3, varDaext4qtr4].fold(0, (sum, value) => sum + value);
      int varSalarygross = [varBpgross, varDagross, varHragross, varNpagross, varSplpaygross, varConvgross, varPggross,
        varAnnualgross, varUniformgross, varNursinggross, varTagross, varDaontagross, varMedicalgross,
        varDirtgross, varWashinggross, varTbgross, varNightgross, varDrivegross, varCyclegross,
        varPcagross, varNpsempgross, varOthergross, varDaext1gross, varDaext2gross, varDaext3gross, varDaext4gross,
      ].fold(0, (sum, value) => sum + value);
      int varIncometaxgross = [varIncometaxqtr1, varIncometaxqtr2, varIncometaxqtr3, varIncometaxqtr4].fold(0, (sum, value) => sum + value);
      int varGisgross = [varGisqtr1, varGisqtr2, varGisqtr3, varGisqtr4].fold(0, (sum, value) => sum + value);
      int varGpfgross = [varGpfqtr1, varGpfqtr2, varGpfqtr3, varGpfqtr4].fold(0, (sum, value) => sum + value);
      int varNpsgross = [varNpsqtr1, varNpsqtr2, varNpsqtr3, varNpsqtr4].fold(0, (sum, value) => sum + value);
      int varSlfgross = [varSlfqtr1, varSlfqtr2, varSlfqtr3, varSlfqtr4].fold(0, (sum, value) => sum + value);
      int varSocietygross = [varSocietyqtr1, varSocietyqtr2, varSocietyqtr3, varSocietyqtr4].fold(0, (sum, value) => sum + value);
      int varRecoverygross = [varRecoveryqtr1, varRecoveryqtr2, varRecoveryqtr3, varRecoveryqtr4].fold(0, (sum, value) => sum + value);
      int varWfgross = [varWfqtr1, varWfqtr2, varWfqtr3, varWfqtr4].fold(0, (sum, value) => sum + value);
      int varOther2gross = [varOther2qtr1, varOther2qtr2, varOther2qtr3, varOther2qtr4].fold(0, (sum, value) => sum + value);
      int varDdext1gross = [varDdext1qtr1, varDdext1qtr2, varDdext1qtr3, varDdext1qtr4].fold(0, (sum, value) => sum + value);
      int varDdext2gross = [varDdext2qtr1, varDdext2qtr2, varDdext2qtr3, varDdext2qtr4].fold(0, (sum, value) => sum + value);
      int varDdext3gross = [varDdext3qtr1, varDdext3qtr2, varDdext3qtr3, varDdext3qtr4].fold(0, (sum, value) => sum + value);
      int varDdext4gross = [varDdext4qtr1, varDdext4qtr2, varDdext4qtr3, varDdext4qtr4].fold(0, (sum, value) => sum + value);
      int varTotaldedgross = [varTotaldedqtr1, varTotaldedqtr2, varTotaldedqtr3, varTotaldedqtr4].fold(0, (sum, value) => sum + value);
      int varNetsalarygross = [varNetsalaryqtr1, varNetsalaryqtr2, varNetsalaryqtr3, varNetsalaryqtr4].fold(0, (sum, value) => sum + value);

      // ================================= Update Itax Form total value ==================================
      await updateitax(
        biometricId,
        varBpgross,
        varDagross,
        varHragross,
        varNpagross,
        varSplpaygross,
        varConvgross,
        varPggross,
        varAnnualgross,
        varUniformgross,
        varNursinggross,
        varTagross,
        varDaontagross,
        varMedicalgross,
        varDirtgross,
        varWashinggross,
        varTbgross,
        varNightgross,
        varDrivegross,
        varCyclegross,
        varPcagross,
        varNpsempgross,
        varOthergross,
        varDaext1gross,
        varDaext2gross,
        varDaext3gross,
        varDaext4gross,
        varSalarygross,
        varIncometaxgross,
        varGisgross,
        varGpfgross,
        varNpsgross,
        varSlfgross,
        varSocietygross,
        varRecoverygross,
        varWfgross,
        varOther2gross,
        varDdext1gross,
        varDdext2gross,
        varDdext3gross,
        varDdext4gross,
        varTotaldedgross,
        varNetsalarygross
      );

      //================================== excel formation =================================================
      List<String> columns = ['B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
      int end = 0;

      if (varBpgross > 0){
        end = end % columns.length;

        sheet.getRangeByName("${columns[end]}10").setValue("BP");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varBpmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varBpapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varBpmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varBparrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varBpqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varBpjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varBpjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varBpaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varBparrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varBpqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varBpsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varBpoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varBpnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varBparrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varBpqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varBpdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varBpjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varBpfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varBparrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varBpqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varBpgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varDagross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("DA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varDamar);
        sheet.getRangeByName("${columns[end]}12").setValue(varDaapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varDamay);
        sheet.getRangeByName("${columns[end]}14").setValue(varDaarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varDaqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varDajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varDajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varDaaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varDaarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varDaqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varDasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varDaoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varDanov);
        sheet.getRangeByName("${columns[end]}24").setValue(varDaarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varDaqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varDadec);
        sheet.getRangeByName("${columns[end]}27").setValue(varDajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varDafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varDaarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varDaqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varDagross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varHragross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("HRA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varHramar);
        sheet.getRangeByName("${columns[end]}12").setValue(varHraapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varHramay);
        sheet.getRangeByName("${columns[end]}14").setValue(varHraarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varHraqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varHrajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varHrajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varHraaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varHraarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varHraqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varHrasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varHraoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varHranov);
        sheet.getRangeByName("${columns[end]}24").setValue(varHraarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varHraqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varHradec);
        sheet.getRangeByName("${columns[end]}27").setValue(varHrajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varHrafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varHraarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varHraqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varHragross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varNpagross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("NPA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varNpamar);
        sheet.getRangeByName("${columns[end]}12").setValue(varNpaapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varNpamay);
        sheet.getRangeByName("${columns[end]}14").setValue(varNpaarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varNpaqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varNpajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varNpajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varNpaaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varNpaarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varNpaqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varNpasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varNpaoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varNpanov);
        sheet.getRangeByName("${columns[end]}24").setValue(varNpaarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varNpaqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varNpadec);
        sheet.getRangeByName("${columns[end]}27").setValue(varNpajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varNpafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varNpaarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varNpaqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varNpagross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varSplpaygross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("SPL PAY");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varSplpaymar);
        sheet.getRangeByName("${columns[end]}12").setValue(varSplpayapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varSplpaymay);
        sheet.getRangeByName("${columns[end]}14").setValue(varSplpayarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varSplpayqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varSplpayjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varSplpayjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varSplpayaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varSplpayarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varSplpayqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varSplpaysept);
        sheet.getRangeByName("${columns[end]}22").setValue(varSplpayoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varSplpaynov);
        sheet.getRangeByName("${columns[end]}24").setValue(varSplpayarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varSplpayqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varSplpaydec);
        sheet.getRangeByName("${columns[end]}27").setValue(varSplpayjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varSplpayfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varSplpayarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varSplpayqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varSplpaygross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varConvgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("CONVEYANCE");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varConvmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varConvapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varConvmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varConvarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varConvqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varConvjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varConvjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varConvaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varConvarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varConvqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varConvsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varConvoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varConvnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varConvarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varConvqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varConvdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varConvjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varConvfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varConvarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varConvqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varConvgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varPggross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("PG");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varPgmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varPgapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varPgmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varPgarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varPgqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varPgjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varPgjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varPgaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varPgarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varPgqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varPgsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varPgoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varPgnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varPgarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varPgqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varPgdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varPgjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varPgfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varPgarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varPgqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varPggross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varAnnualgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("ANNUAL");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varAnnualmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varAnnualapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varAnnualmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varAnnualarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varAnnualqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varAnnualjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varAnnualjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varAnnualaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varAnnualarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varAnnualqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varAnnualsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varAnnualoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varAnnualnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varAnnualarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varAnnualqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varAnnualdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varAnnualjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varAnnualfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varAnnualarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varAnnualqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varAnnualgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varUniformgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("UNIFORM");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varUniformmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varUniformapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varUniformmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varUniformarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varUniformqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varUniformjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varUniformjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varUniformaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varUniformarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varUniformqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varUniformsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varUniformoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varUniformnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varUniformarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varUniformqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varUniformdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varUniformjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varUniformfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varUniformarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varUniformqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varUniformgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varNursinggross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("NURSING");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varNursingmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varNursingapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varNursingmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varNursingarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varNursingqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varNursingjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varNursingjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varNursingaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varNursingarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varNursingqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varNursingsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varNursingoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varNursingnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varNursingarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varNursingqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varNursingdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varNursingjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varNursingfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varNursingarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varNursingqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varNursinggross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varTagross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("TA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varTamar);
        sheet.getRangeByName("${columns[end]}12").setValue(varTaapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varTamay);
        sheet.getRangeByName("${columns[end]}14").setValue(varTaarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varTaqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varTajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varTajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varTaaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varTaarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varTaqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varTasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varTaoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varTanov);
        sheet.getRangeByName("${columns[end]}24").setValue(varTaarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varTaqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varTadec);
        sheet.getRangeByName("${columns[end]}27").setValue(varTajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varTafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varTaarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varTaqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varTagross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varDaontagross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("DA ON TA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varDaontamar);
        sheet.getRangeByName("${columns[end]}12").setValue(varDaontaapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varDaontamay);
        sheet.getRangeByName("${columns[end]}14").setValue(varDaontaarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varDaontaqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varDaontajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varDaontajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varDaontaaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varDaontaarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varDaontaqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varDaontasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varDaontaoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varDaontanov);
        sheet.getRangeByName("${columns[end]}24").setValue(varDaontaarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varDaontaqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varDaontadec);
        sheet.getRangeByName("${columns[end]}27").setValue(varDaontajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varDaontafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varDaontaarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varDaontaqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varDaontagross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varMedicalgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("MEDICAL");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varMedicalmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varMedicalapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varMedicalmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varMedicalarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varMedicalqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varMedicaljun);
        sheet.getRangeByName("${columns[end]}17").setValue(varMedicaljul);
        sheet.getRangeByName("${columns[end]}18").setValue(varMedicalaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varMedicalarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varMedicalqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varMedicalsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varMedicaloct);
        sheet.getRangeByName("${columns[end]}23").setValue(varMedicalnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varMedicalarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varMedicalqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varMedicaldec);
        sheet.getRangeByName("${columns[end]}27").setValue(varMedicaljan);
        sheet.getRangeByName("${columns[end]}28").setValue(varMedicalfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varMedicalarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varMedicalqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varMedicalgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varDirtgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("DIRT");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varDirtmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varDirtapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varDirtmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varDirtarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varDirtqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varDirtjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varDirtjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varDirtaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varDirtarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varDirtqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varDirtsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varDirtoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varDirtnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varDirtarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varDirtqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varDirtdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varDirtjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varDirtfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varDirtarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varDirtqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varDirtgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varWashinggross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("WASHING");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varWashingmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varWashingapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varWashingmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varWashingarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varWashingqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varWashingjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varWashingjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varWashingaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varWashingarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varWashingqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varWashingsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varWashingoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varWashingnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varWashingarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varWashingqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varWashingdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varWashingjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varWashingfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varWashingarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varWashingqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varWashinggross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varTbgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("TB");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varTbmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varTbapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varTbmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varTbarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varTbqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varTbjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varTbjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varTbaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varTbarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varTbqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varTbsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varTboct);
        sheet.getRangeByName("${columns[end]}23").setValue(varTbnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varTbarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varTbqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varTbdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varTbjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varTbfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varTbarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varTbqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varTbgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varNightgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("NIGHT");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varNightmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varNightapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varNightmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varNightarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varNightqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varNightjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varNightjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varNightaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varNightarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varNightqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varNightsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varNightoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varNightnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varNightarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varNightqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varNightdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varNightjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varNightfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varNightarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varNightqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varNightgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varDrivegross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("CONTIGENCY");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varDrivemar);
        sheet.getRangeByName("${columns[end]}12").setValue(varDriveapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varDrivemay);
        sheet.getRangeByName("${columns[end]}14").setValue(varDrivearrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varDriveqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varDrivejun);
        sheet.getRangeByName("${columns[end]}17").setValue(varDrivejul);
        sheet.getRangeByName("${columns[end]}18").setValue(varDriveaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varDrivearrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varDriveqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varDrivesept);
        sheet.getRangeByName("${columns[end]}22").setValue(varDriveoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varDrivenov);
        sheet.getRangeByName("${columns[end]}24").setValue(varDrivearrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varDriveqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varDrivedec);
        sheet.getRangeByName("${columns[end]}27").setValue(varDrivejan);
        sheet.getRangeByName("${columns[end]}28").setValue(varDrivefeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varDrivearrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varDriveqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varDrivegross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varCyclegross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("CYCLE");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varCyclemar);
        sheet.getRangeByName("${columns[end]}12").setValue(varCycleapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varCyclemay);
        sheet.getRangeByName("${columns[end]}14").setValue(varCyclearrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varCycleqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varCyclejun);
        sheet.getRangeByName("${columns[end]}17").setValue(varCyclejul);
        sheet.getRangeByName("${columns[end]}18").setValue(varCycleaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varCyclearrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varCycleqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varCyclesept);
        sheet.getRangeByName("${columns[end]}22").setValue(varCycleoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varCyclenov);
        sheet.getRangeByName("${columns[end]}24").setValue(varCyclearrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varCycleqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varCycledec);
        sheet.getRangeByName("${columns[end]}27").setValue(varCyclejan);
        sheet.getRangeByName("${columns[end]}28").setValue(varCyclefeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varCyclearrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varCycleqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varCyclegross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varPcagross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("PCA");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varPcamar);
        sheet.getRangeByName("${columns[end]}12").setValue(varPcaapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varPcamay);
        sheet.getRangeByName("${columns[end]}14").setValue(varPcaarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varPcaqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varPcajun);
        sheet.getRangeByName("${columns[end]}17").setValue(varPcajul);
        sheet.getRangeByName("${columns[end]}18").setValue(varPcaaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varPcaarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varPcaqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varPcasept);
        sheet.getRangeByName("${columns[end]}22").setValue(varPcaoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varPcanov);
        sheet.getRangeByName("${columns[end]}24").setValue(varPcaarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varPcaqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varPcadec);
        sheet.getRangeByName("${columns[end]}27").setValue(varPcajan);
        sheet.getRangeByName("${columns[end]}28").setValue(varPcafeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varPcaarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varPcaqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varPcagross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varNpsempgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("NPS 14%");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varNpsempmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varNpsempapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varNpsempmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varNpsemparrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varNpsempqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varNpsempjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varNpsempjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varNpsempaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varNpsemparrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varNpsempqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varNpsempsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varNpsempoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varNpsempnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varNpsemparrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varNpsempqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varNpsempdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varNpsempjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varNpsempfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varNpsemparrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varNpsempqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varNpsempgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varOthergross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("OTHER");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varOthermar);
        sheet.getRangeByName("${columns[end]}12").setValue(varOtherapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varOthermay);
        sheet.getRangeByName("${columns[end]}14").setValue(varOtherarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varOtherqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varOtherjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varOtherjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varOtheraug);
        sheet.getRangeByName("${columns[end]}19").setValue(varOtherarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varOtherqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varOthersept);
        sheet.getRangeByName("${columns[end]}22").setValue(varOtheroct);
        sheet.getRangeByName("${columns[end]}23").setValue(varOthernov);
        sheet.getRangeByName("${columns[end]}24").setValue(varOtherarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varOtherqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varOtherdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varOtherjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varOtherfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varOtherarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue(varTution);
        sheet.getRangeByName("${columns[end]}31").setValue(varBonus);
        sheet.getRangeByName("${columns[end]}32").setValue(varOtherqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varOthergross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varSalarygross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("SALARY");
        sheet.getRangeByName("${columns[end]}10").columnWidth = 10;
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varSalarymar);
        sheet.getRangeByName("${columns[end]}12").setValue(varSalaryapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varSalarymay);
        sheet.getRangeByName("${columns[end]}14").setValue(varSalaryarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varSalaryqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varSalaryjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varSalaryjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varSalaryaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varSalaryarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varSalaryqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varSalarysept);
        sheet.getRangeByName("${columns[end]}22").setValue(varSalaryoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varSalarynov);
        sheet.getRangeByName("${columns[end]}24").setValue(varSalaryarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varSalaryqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varSalarydec);
        sheet.getRangeByName("${columns[end]}27").setValue(varSalaryjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varSalaryfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varSalaryarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue(varSalarytution);
        sheet.getRangeByName("${columns[end]}31").setValue(varSalarybonus);
        sheet.getRangeByName("${columns[end]}32").setValue(varSalaryqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varSalarygross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = specialcolStyle!;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = specialcolStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = specialcolStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = specialcolStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = specialtotalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = speciallastrowStyle!;

        end+=1;

      }
      if (end!=0){
        if(end > 2) {
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").merge();
          sheet.getRangeByName("${columns[0]}9").setValue("DETAILS OF ALLOWANCES");
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").cellStyle = commontextStyleBold;
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").cellStyle.hAlign = xls.HAlignType.center;
        } else{
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").merge();
          sheet.getRangeByName("${columns[0]}9").setValue("ALLOWANCES");
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").cellStyle = commontextStyleBold;
          sheet.getRangeByName("${columns[0]}9:${columns[end - 1]}9").cellStyle.hAlign = xls.HAlignType.center;
        }
      }

      int dstart = end;

      if (varIncometaxgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("INCOME TAX");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varIncometaxmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varIncometaxapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varIncometaxmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varIncometaxarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varIncometaxqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varIncometaxjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varIncometaxjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varIncometaxaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varIncometaxarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varIncometaxqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varIncometaxsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varIncometaxoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varIncometaxnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varIncometaxarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varIncometaxqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varIncometaxdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varIncometaxjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varIncometaxfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varIncometaxarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varIncometaxqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varIncometaxgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varGisgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("GIS");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varGismar);
        sheet.getRangeByName("${columns[end]}12").setValue(varGisapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varGismay);
        sheet.getRangeByName("${columns[end]}14").setValue(varGisarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varGisqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varGisjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varGisjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varGisaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varGisarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varGisqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varGissept);
        sheet.getRangeByName("${columns[end]}22").setValue(varGisoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varGisnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varGisarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varGisqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varGisdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varGisjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varGisfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varGisarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varGisqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varGisgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;
        
      }

      if (varGpfgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("GPF");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varGpfmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varGpfapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varGpfmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varGpfarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varGpfqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varGpfjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varGpfjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varGpfaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varGpfarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varGpfqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varGpfsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varGpfoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varGpfnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varGpfarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varGpfqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varGpfdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varGpfjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varGpffeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varGpfarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varGpfqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varGpfgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varNpsgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("NPS 10%");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varNpsmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varNpsapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varNpsmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varNpsarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varNpsqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varNpsjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varNpsjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varNpsaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varNpsarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varNpsqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varNpssept);
        sheet.getRangeByName("${columns[end]}22").setValue(varNpsoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varNpsnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varNpsarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varNpsqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varNpsdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varNpsjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varNpsfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varNpsarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varNpsqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varNpsgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varSlfgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("SLF");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varSlfmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varSlfapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varSlfmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varSlfarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varSlfqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varSlfjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varSlfjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varSlfaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varSlfarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varSlfqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varSlfsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varSlfoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varSlfnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varSlfarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varSlfqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varSlfdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varSlfjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varSlffeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varSlfarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varSlfqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varSlfgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varSocietygross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("SOCIETY");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varSocietymar);
        sheet.getRangeByName("${columns[end]}12").setValue(varSocietyapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varSocietymay);
        sheet.getRangeByName("${columns[end]}14").setValue(varSocietyarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varSocietyqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varSocietyjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varSocietyjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varSocietyaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varSocietyarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varSocietyqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varSocietysept);
        sheet.getRangeByName("${columns[end]}22").setValue(varSocietyoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varSocietynov);
        sheet.getRangeByName("${columns[end]}24").setValue(varSocietyarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varSocietyqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varSocietydec);
        sheet.getRangeByName("${columns[end]}27").setValue(varSocietyjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varSocietyfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varSocietyarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varSocietyqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varSocietygross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }


      if (varRecoverygross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("RECOVERY");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varRecoverymar);
        sheet.getRangeByName("${columns[end]}12").setValue(varRecoveryapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varRecoverymay);
        sheet.getRangeByName("${columns[end]}14").setValue(varRecoveryarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varRecoveryqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varRecoveryjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varRecoveryjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varRecoveryaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varRecoveryarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varRecoveryqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varRecoverysept);
        sheet.getRangeByName("${columns[end]}22").setValue(varRecoveryoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varRecoverynov);
        sheet.getRangeByName("${columns[end]}24").setValue(varRecoveryarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varRecoveryqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varRecoverydec);
        sheet.getRangeByName("${columns[end]}27").setValue(varRecoveryjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varRecoveryfeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varRecoveryarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varRecoveryqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varRecoverygross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varWfgross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("W/F FUND");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varWfmar);
        sheet.getRangeByName("${columns[end]}12").setValue(varWfapr);
        sheet.getRangeByName("${columns[end]}13").setValue(varWfmay);
        sheet.getRangeByName("${columns[end]}14").setValue(varWfarrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varWfqtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varWfjun);
        sheet.getRangeByName("${columns[end]}17").setValue(varWfjul);
        sheet.getRangeByName("${columns[end]}18").setValue(varWfaug);
        sheet.getRangeByName("${columns[end]}19").setValue(varWfarrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varWfqtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varWfsept);
        sheet.getRangeByName("${columns[end]}22").setValue(varWfoct);
        sheet.getRangeByName("${columns[end]}23").setValue(varWfnov);
        sheet.getRangeByName("${columns[end]}24").setValue(varWfarrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varWfqtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varWfdec);
        sheet.getRangeByName("${columns[end]}27").setValue(varWfjan);
        sheet.getRangeByName("${columns[end]}28").setValue(varWffeb);
        sheet.getRangeByName("${columns[end]}29").setValue(varWfarrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varWfqtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varWfgross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }

      if (varOther2gross > 0){

        sheet.getRangeByName("${columns[end]}10").setValue("OTHER 2");
        sheet.getRangeByName("${columns[end]}10").cellStyle = tableheadingStyle;

        sheet.getRangeByName("${columns[end]}11").setValue(varOther2mar);
        sheet.getRangeByName("${columns[end]}12").setValue(varOther2apr);
        sheet.getRangeByName("${columns[end]}13").setValue(varOther2may);
        sheet.getRangeByName("${columns[end]}14").setValue(varOther2arrearqtr1);
        sheet.getRangeByName("${columns[end]}15").setValue(varOther2qtr1);
        sheet.getRangeByName("${columns[end]}16").setValue(varOther2jun);
        sheet.getRangeByName("${columns[end]}17").setValue(varOther2jul);
        sheet.getRangeByName("${columns[end]}18").setValue(varOther2aug);
        sheet.getRangeByName("${columns[end]}19").setValue(varOther2arrearqtr2);
        sheet.getRangeByName("${columns[end]}20").setValue(varOther2qtr2);
        sheet.getRangeByName("${columns[end]}21").setValue(varOther2sept);
        sheet.getRangeByName("${columns[end]}22").setValue(varOther2oct);
        sheet.getRangeByName("${columns[end]}23").setValue(varOther2nov);
        sheet.getRangeByName("${columns[end]}24").setValue(varOther2arrearqtr3);
        sheet.getRangeByName("${columns[end]}25").setValue(varOther2qtr3);
        sheet.getRangeByName("${columns[end]}26").setValue(varOther2dec);
        sheet.getRangeByName("${columns[end]}27").setValue(varOther2jan);
        sheet.getRangeByName("${columns[end]}28").setValue(varOther2feb);
        sheet.getRangeByName("${columns[end]}29").setValue(varOther2arrearqtr4);
        sheet.getRangeByName("${columns[end]}30").setValue('0');
        sheet.getRangeByName("${columns[end]}31").setValue('0');
        sheet.getRangeByName("${columns[end]}32").setValue(varOther2qtr4);
        sheet.getRangeByName("${columns[end]}33").setValue(varOther2gross);

        sheet.getRangeByName("${columns[end]}11:${columns[end]}14").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}16:${columns[end]}19").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}21:${columns[end]}24").cellStyle = commontextStyle;
        sheet.getRangeByName("${columns[end]}26:${columns[end]}31").cellStyle = commontextStyle;

        List<String> qtrcolumns = ['15','20','25','32'];
        for (String cols in qtrcolumns){
          sheet.getRangeByName("${columns[end]}$cols").cellStyle = totalrowStyle!;
        }
        sheet.getRangeByName("${columns[end]}33").cellStyle = formlastrowStyle;

        end+=1;

      }
      if (dstart != end ){
        if((dstart - end) > 2) {
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").merge();
          sheet.getRangeByName("${columns[dstart]}9").setValue("DETAILS OF DEDUCTIONS");
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").cellStyle = commontextStyleBold;
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").cellStyle.hAlign = xls.HAlignType.center;
        } else{
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").merge();
          sheet.getRangeByName("${columns[dstart]}9").setValue("DEDUCTIONS");
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").cellStyle = commontextStyleBold;
          sheet.getRangeByName("${columns[dstart]}9:${columns[end - 1]}9").cellStyle.hAlign = xls.HAlignType.center;
        }
      }

    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed: \n$error"),
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
  }
  Future<void> _computationPage(
      String? biometricId,
      xls.Worksheet sheet,
      [
        xls.Style? otherheaderStyle,
        xls.Style? commontextStyle,
        xls.Style? commontextStyleBold,
      ])
  async{
    try{
      sheet.showGridlines = false;
      sheet.getRangeByName("A1").columnWidth = 4.11;
      sheet.getRangeByName("B1").columnWidth = 4.11;
      sheet.getRangeByName("C1").columnWidth = 54.11;
      sheet.getRangeByName("D1").columnWidth = 15.11;
      sheet.getRangeByName("B3:B52").rowHeight = 15.60;

      sheet.getRangeByName("C1").setValue(mainpgData['name']);
      sheet.getRangeByName("D1").setValue(biometricId);
      sheet.getRangeByName("C1:D1").cellStyle = commontextStyle!;


      sheet.getRangeByName("B2").rowHeight = 21.60;
      sheet.getRangeByName("B2:D2").merge();
      sheet.getRangeByName("B2").setValue("COMPUTATION OF TOTAL INCOME");
      sheet.getRangeByName("B2:D2").cellStyle = otherheaderStyle!;

      for (int i=1 ; i<=9; i++){
        sheet.getRangeByName("B${i+2}").setValue(i);
        sheet.getRangeByName("B${i+2}").cellStyle = commontextStyle;
        sheet.getRangeByName("B${i+2}").cellStyle.hAlign = xls.HAlignType.center;
      }

      for (int i=1 ; i<=17; i++){
        sheet.getRangeByName("B${i+20}").setValue(i);
        sheet.getRangeByName("B${i+20}").cellStyle = commontextStyle;
        sheet.getRangeByName("B${i+20}").cellStyle.hAlign = xls.HAlignType.center;
      }

      for(int i = 3; i<= 13; i++){
        sheet.getRangeByName("C$i").cellStyle = commontextStyle;
      }

      sheet.getRangeByName("C3").setValue("BASIC PAY");
      sheet.getRangeByName("C4").setValue("D.A.(WITH ARREAR)");
      sheet.getRangeByName("C5").setValue("H.R.A.");
      sheet.getRangeByName("C6").setValue("N.P.A / SPL PAY");
      sheet.getRangeByName("C7").setValue("NURSING ALLOWANCES");
      sheet.getRangeByName("C8").setValue("PATIENT CARE ALLOWANCE(WITH ARREAR)");
      sheet.getRangeByName("C9").setValue("TA & DA ON TA(WITH ARREAR)");
      sheet.getRangeByName("C10").setValue("NPS EMPLOYER (14%)");
      sheet.getRangeByName("C11").setValue("OTHER & UNIFORM,CONTIGENCY,CONVEYANCE ALLOWANCE");

      sheet.getRangeByName("B12:C12").merge();
      sheet.getRangeByName("B12").setValue("TOTAL GROSS SALARY");
      sheet.getRangeByName("B12:C12").cellStyle = commontextStyleBold!;

      sheet.getRangeByName("B13:C13").merge();
      sheet.getRangeByName("B13").rowHeight = 24.00;
      sheet.getRangeByName("B13").setValue("TOTAL SALARY BY ROUNDING OFF");
      sheet.getRangeByName("B13:C13").cellStyle = commontextStyleBold;
      sheet.getRangeByName("B13:C13").cellStyle.fontSize = 14;

      for(int i = 14; i<= 18; i++){
        sheet.getRangeByName("B$i:C$i").merge();
        sheet.getRangeByName("B$i:C$i").cellStyle = commontextStyle;
      }
      sheet.getRangeByName("B14").setValue("ACTUAL RENT PAID (YEARLY)");
      sheet.getRangeByName("B15").setValue("BASIC X 50%");
      sheet.getRangeByName("B16").setValue("RENT PAID - 10% BASIC");
      sheet.getRangeByName("B17").setValue("ACTUAL HRA PAID");
      sheet.getRangeByName("B18").setValue("HRA REBATE");

      sheet.getRangeByName("B20:D20").merge();
      sheet.getRangeByName("B20").setValue("DEDUCTION UNDER 80C,80CCC & 80CCD");
      sheet.getRangeByName("B20:D20").cellStyle = commontextStyleBold;
      sheet.getRangeByName("B20:D20").cellStyle.hAlign = xls.HAlignType.center;
      sheet.getRangeByName("B20:D20").cellStyle.borders.all.lineStyle = xls.LineStyle.thick;


      for (int i = 21; i<=35; i++){
        sheet.getRangeByName("C$i").cellStyle = commontextStyle;
      }
      sheet.getRangeByName("C21").setValue("POST OFFICE");
      sheet.getRangeByName("C22").setValue("PUBLIC PROVIDENT FUND");
      sheet.getRangeByName("C23").setValue("LIC");
      sheet.getRangeByName("C24").setValue("HOUSE LOAN PRINCIPAL");
      sheet.getRangeByName("C25").setValue("5 YEARS(FIXED DEPOSIT/TIME DEPOSITE SCHEME)");
      sheet.getRangeByName("C26").setValue("NSC");
      sheet.getRangeByName("C27").setValue("80C");
      sheet.getRangeByName("C28").setValue("NPS 80CCD(1)");
      sheet.getRangeByName("C29").setValue("GPF");
      sheet.getRangeByName("C30").setValue("GIS");
      sheet.getRangeByName("C31").setValue("ULIP");
      sheet.getRangeByName("C32").setValue("ELSS");
      sheet.getRangeByName("C33").setValue("SUKANYA SAMRIDHI YOJNA");
      sheet.getRangeByName("C34").setValue("TUTION FEES");
      sheet.getRangeByName("C35").setValue("OTHER");

      sheet.getRangeByName("C36").setValue("TOTAL SAVINGS");
      sheet.getRangeByName("C36").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C37").setValue("TOTAL SAVINGS DOES NOT EXCEED RS.150000/-");
      sheet.getRangeByName("C37").cellStyle = commontextStyleBold;

      sheet.getRangeByName("B39:D39").merge();
      sheet.getRangeByName("B39").setValue("EXPEMPTIONS");
      sheet.getRangeByName("B39:D39").cellStyle = commontextStyleBold;
      sheet.getRangeByName("B39:D39").cellStyle.hAlign = xls.HAlignType.center;
      sheet.getRangeByName("B39:D39").cellStyle.borders.all.lineStyle = xls.LineStyle.thick;

      for (int i = 40; i<=52; i++){
        sheet.getRangeByName("B$i:C$i").merge();
        sheet.getRangeByName("B$i:C$i").cellStyle = commontextStyle;
      }

      sheet.getRangeByName("B40").setValue("NPS 80CCD(2)");
      sheet.getRangeByName("B41").setValue("HOUSE LOAN INTEREST");
      sheet.getRangeByName("B42").setValue("DEDUCTION FOR DONATION U/S 80G");
      sheet.getRangeByName("B43").setValue("CEA");
      sheet.getRangeByName("B44").setValue("U/S 80 CCD(1B)");
      sheet.getRangeByName("B45").setValue("80D");
      sheet.getRangeByName("B46").setValue("80DP");
      sheet.getRangeByName("B47").setValue("80DPS");
      sheet.getRangeByName("B48").setValue("DEDUCTION FOR HANDICAPPED PERSON U/S 80U");
      sheet.getRangeByName("B49").setValue("80E (EDUCATION LOAN)");
      sheet.getRangeByName("B50").setValue("80EE");
      sheet.getRangeByName("B51").setValue("CONVEYANCE AND CONTIGENCY EXEMPTED");
      sheet.getRangeByName("B52").setValue("OTHER");



      for (int i = 3; i<=18; i++){
        sheet.getRangeByName("D$i").cellStyle = commontextStyle;
        sheet.getRangeByName("D$i").cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
      }

      sheet.getRangeByName("D3").setValue(int.tryParse(itfData['tbp']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D4").setValue(int.tryParse(itfData['tda']?.toString() ?? '0') ?? 0);
      int varHra = int.tryParse(itfData['thra']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("D5").setValue(varHra);
      sheet.getRangeByName("D6").setValue((int.tryParse(itfData['tnpa']?.toString() ?? '0') ?? 0) + (int.tryParse(itfData['tsplpay']?.toString() ?? '0') ?? 0));
      sheet.getRangeByName("D7").setValue(int.tryParse(itfData['tnursing']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D8").setValue(int.tryParse(itfData['tpca']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D9").setValue((int.tryParse(itfData['tta']?.toString() ??'0') ?? 0) + (int.tryParse(itfData['tdaonta']?.toString() ??'0') ?? 0));
      sheet.getRangeByName("D10").setValue(int.tryParse(itfData['tnpsemp']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D11").setValue((int.tryParse(itfData['tother']?.toString() ?? '0') ?? 0) + (int.tryParse(itfData['tuniform']?.toString() ?? '0') ?? 0) + (int.tryParse(itfData['tconv']?.toString() ?? '0') ?? 0) + (int.tryParse(itfData['tdrive']?.toString() ?? '0') ?? 0));

      sheet.getRangeByName("D12").setValue(int.tryParse(itfData['tgross']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D12").cellStyle = commontextStyleBold;

      sheet.getRangeByName("D13").setValue((int.tryParse(itfData['tgross']?.toString() ??'0') ?? 0).round());
      sheet.getRangeByName("D13").cellStyle = commontextStyleBold;
      sheet.getRangeByName("D13").cellStyle.fontSize = 14;

      int varArp = int.tryParse(dedData['hrr']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("D14").setValue(varArp);
      int varBasic = (((int.tryParse(itfData['tbp']?.toString() ??'0') ?? 0) + (int.tryParse(itfData['tda']?.toString() ?? '0') ?? 0) + (int.tryParse(itfData['tnpa']?.toString() ??'0') ?? 0))*0.5).round();
      sheet.getRangeByName("D15").setValue(varBasic);
      int varRpaid = max(0, (varArp - (varBasic * 0.2)).round());
      sheet.getRangeByName("D16").setValue(varRpaid);
      sheet.getRangeByName("D17").setValue(varHra);

      sheet.getRangeByName("D18").setValue([varBasic, varRpaid, varHra].reduce(min));
      sheet.getRangeByName("D18").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;

      for (int i = 21; i<=37; i++){
        sheet.getRangeByName("D$i").cellStyle = commontextStyle;
        sheet.getRangeByName("D$i").cellStyle.backColor = "#EEECE1";

      }

      sheet.getRangeByName("D21").setValue(int.tryParse(dedData['po']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D21").cellStyle.borders.top.lineStyle = xls.LineStyle.thick;

      sheet.getRangeByName("D22").setValue(int.tryParse(dedData['ppf']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D23").setValue(int.tryParse(dedData['lic']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D24").setValue(int.tryParse(dedData['hlp']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D25").setValue(int.tryParse(dedData['fd']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D26").setValue(int.tryParse(dedData['nsc']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D27").setValue(int.tryParse(dedData['80c']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D28").setValue(int.tryParse(dedData['80ccd1']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D29").setValue(int.tryParse(dedData['gpf']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D30").setValue(int.tryParse(dedData['gis']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D31").setValue(int.tryParse(dedData['ulip']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D32").setValue(int.tryParse(dedData['elss']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D33").setValue(int.tryParse(dedData['ssy']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D34").setValue(int.tryParse(dedData['tution']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D35").setValue(int.tryParse(dedData['ext3']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D36").setValue(int.tryParse(dedData['totalsav']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D36").cellStyle = commontextStyleBold;
      sheet.getRangeByName("D36").cellStyle.backColor = "#EEECE1";
      sheet.getRangeByName("D37").setValue(int.tryParse(dedData['maxsav']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D37").cellStyle = commontextStyleBold;
      sheet.getRangeByName("D37").cellStyle.backColor = "#EEECE1";

      for (int i = 40; i<=52; i++){
        sheet.getRangeByName("D$i").cellStyle = commontextStyle;
        sheet.getRangeByName("D$i").cellStyle.backColor = "#EEECE1";
      }

      sheet.getRangeByName("D40").setValue(int.tryParse(dedData['80ccd2']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D41").setValue(int.tryParse(dedData['hli']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D42").setValue(int.tryParse(dedData['80g']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D43").setValue(int.tryParse(dedData['cea']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D44").setValue(int.tryParse(dedData['80ccdnps']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D45").setValue(int.tryParse(dedData['80d']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D46").setValue(int.tryParse(dedData['80dp']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D47").setValue(int.tryParse(dedData['80dps']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D48").setValue(int.tryParse(dedData['80u']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D49").setValue(int.tryParse(dedData['80e']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D50").setValue(int.tryParse(dedData['80ee']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D51").setValue(int.tryParse(dedData['taexem']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("D52").setValue(int.tryParse(dedData['other']?.toString() ?? '0') ?? 0);

      for (int i = 3; i<=18; i++){
        xls.Range rangeValue = sheet.getRangeByName("D$i");
        xls.Range rangeNum = sheet.getRangeByName("B$i");
        rangeValue.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeValue.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.bottom.lineStyle = i != 18 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeValue.cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
        rangeNum.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeNum.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.bottom.lineStyle = i != 18 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeNum.cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      }

      for (int i = 21; i<=37; i++){
        xls.Range rangeValue = sheet.getRangeByName("D$i");
        xls.Range rangeNum = sheet.getRangeByName("B$i");
        rangeValue.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeValue.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.bottom.lineStyle = i != 37 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeValue.cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
        rangeNum.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeNum.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.bottom.lineStyle = i != 37 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeNum.cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      }

      for (int i = 40; i<=52; i++){
        xls.Range rangeValue = sheet.getRangeByName("D$i");
        xls.Range rangeNum = sheet.getRangeByName("B$i");
        rangeValue.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeValue.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.bottom.lineStyle = i != 52 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeValue.cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
        rangeNum.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeNum.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.bottom.lineStyle = i != 52 ? xls.LineStyle.thin : xls.LineStyle.thick;
        rangeNum.cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      }
      
      sheet.getRangeByName("C18").cellStyle.borders.all.lineStyle = xls.LineStyle.none;
      sheet.getRangeByName("C18").cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C18").cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C18").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;

      sheet.getRangeByName("C37").cellStyle.borders.all.lineStyle = xls.LineStyle.none;
      sheet.getRangeByName("C37").cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C37").cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C37").cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C37").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;

      sheet.getRangeByName("C52").cellStyle.borders.all.lineStyle = xls.LineStyle.none;
      sheet.getRangeByName("C52").cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C52").cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("C52").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;

    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed: \n$error"),
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
  }
  Future<void> _itaxNewPage(
      String? biometricId,
      xls.Worksheet sheet,
      [
        xls.Style? otherheaderStyle,
        xls.Style? commontextStyle,
        xls.Style? commontextStyleBold,
      ])
  async{
    try{
      sheet.showGridlines = false;
      sheet.getRangeByName("A1").columnWidth = 7.11;
      sheet.getRangeByName("B1:C1").columnWidth = 3.78;
      sheet.getRangeByName("D1").columnWidth = 5.78;
      sheet.getRangeByName("E1").columnWidth = 37.11;
      sheet.getRangeByName("F1").columnWidth = 17.33;
      sheet.getRangeByName("G1").columnWidth = 17.78;
      sheet.getRangeByName("A1:A46").rowHeight = 15.60;


      sheet.getRangeByName("B1:D1").merge();
      sheet.getRangeByName("B1").setValue(biometricId);
      sheet.getRangeByName("E1").setValue(mainpgData['name']);
      sheet.getRangeByName("F1").setValue(mainpgData['panno']);
      sheet.getRangeByName("G1").setValue(mainpgData['designation']);
      
      sheet.getRangeByName("B2").rowHeight = 40.80;
      sheet.getRangeByName("B2:G2").merge();
      sheet.getRangeByName("B2").setValue(sharedData.zone.toUpperCase());
      sheet.getRangeByName("B2:G2").cellStyle = otherheaderStyle!;

      for (int i = 1; i<=9; i++){
        sheet.getRangeByName("B${i+2}").setValue(i);
        sheet.getRangeByName("B${i+2}").cellStyle = commontextStyle!;
        sheet.getRangeByName("B${i+2}").cellStyle.hAlign = xls.HAlignType.center;
        sheet.getRangeByName("C${i+2}:F${i+2}").merge();
        sheet.getRangeByName("C${i+2}:F${i+2}").cellStyle = commontextStyle;
      }

      sheet.getRangeByName("B12").setValue(10);
      sheet.getRangeByName("B12:B19").merge();
      sheet.getRangeByName("B12:B19").cellStyle = commontextStyle!;
      sheet.getRangeByName("B12:B19").cellStyle.hAlign = xls.HAlignType.center;

      for (int i = 11; i<=21; i++){
        sheet.getRangeByName("B${i+9}").setValue(i);
        sheet.getRangeByName("B${i+9}").cellStyle = commontextStyle;
        sheet.getRangeByName("B${i+9}").cellStyle.hAlign = xls.HAlignType.center;
        sheet.getRangeByName("C${i+9}:F${i+9}").merge();
        sheet.getRangeByName("C${i+9}:F${i+9}").cellStyle = commontextStyle;

      }

      sheet.getRangeByName("C3").setValue("Total Gross Salary");
      sheet.getRangeByName("C3").cellStyle = commontextStyleBold!;
      sheet.getRangeByName("C3").rowHeight = 17.40;
      sheet.getRangeByName("C4").setValue("Income From House Property");
      sheet.getRangeByName("C5").setValue("Income From Other Sources");
      sheet.getRangeByName("C6").setValue("Gross Total Income");
      sheet.getRangeByName("C7").setValue("Housing Loan Interest");
      sheet.getRangeByName("C8").setValue("Standard deducion");
      sheet.getRangeByName("C9").setValue("U/S 80CCD (2)");
      sheet.getRangeByName("C10").setValue("Other & Conveyance & Contigency & Uniform Exempted ");
      sheet.getRangeByName("C11").setValue("Total Taxable Income (Round off)");
      sheet.getRangeByName("C11").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C11").rowHeight = 17.40;

      sheet.getRangeByName("C12:F12").merge();
      sheet.getRangeByName("C12:F12").cellStyle = commontextStyle;
      sheet.getRangeByName("C12:F12").cellStyle.hAlign = xls.HAlignType.center;
      sheet.getRangeByName("C12").setValue("Rate of Income Table Leviable");

      List<String> romanNumerals = ["i", "ii", "iii", "iv", "v", "vi", "vii"];

      for (int i = 0; i < romanNumerals.length; i++) {
        sheet.getRangeByName("C${i+13}").setValue(romanNumerals[i]);
        sheet.getRangeByName("D${i+13}:F${i+13}").merge();
        sheet.getRangeByName("C${i+13}:F${i+13}").cellStyle = commontextStyle;
      }
      sheet.getRangeByName("D13").setValue("Upto Rs. 3,00,000/-                                NIL");
      sheet.getRangeByName("D14").setValue("Rs. 3,00,001/- To 7,00,000                     5%");
      sheet.getRangeByName("D15").setValue("Rs. 7,00,001/- To Rs. 10,00,000            10%");
      sheet.getRangeByName("D16").setValue("Rs. 10,00,001/- To Rs. 12,00,000          15%");
      sheet.getRangeByName("D17").setValue("Rs. 12,00,001/- To Rs. 15,00,000          20%");
      sheet.getRangeByName("D18").setValue("ABOVE Rs. 15,00,001                                30%");
      sheet.getRangeByName("D19").setValue("SURCHARGE");

      sheet.getRangeByName("C20").setValue("Tax rebate (Sec.87A):if applicable");
      sheet.getRangeByName("C21").setValue("Total Tax Liability");
      sheet.getRangeByName("C21").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C21").rowHeight = 17.40;
      sheet.getRangeByName("C22").setValue("Education Cess  4%");
      sheet.getRangeByName("C22").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C22").rowHeight = 17.40;
      sheet.getRangeByName("C23").setValue("Total Tax Payble Rs.");
      sheet.getRangeByName("C23").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C23").rowHeight = 17.40;
      sheet.getRangeByName("C24").setValue("Total Tax Payble round off to the nearest Rs.");
      sheet.getRangeByName("C24").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C24").rowHeight = 17.40;
      sheet.getRangeByName("C25").setValue("Deduct :-Income Tax already Paid");
      sheet.getRangeByName("C26").setValue("Net Income Tax Payble");
      sheet.getRangeByName("C26").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C27").setValue("Interest, If Any");
      sheet.getRangeByName("C28").setValue("Relief u/s 89(i)");
      sheet.getRangeByName("C29").rowHeight = 19.80;
      sheet.getRangeByName("C29").setValue("Net Income Tax Payble with Interest");
      sheet.getRangeByName("C29").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C29").cellStyle.fontSize = 14;
      sheet.getRangeByName("C29").cellStyle.backColor = "#FBD4B4";
      sheet.getRangeByName("C30").setValue("Excess Paid");
      sheet.getRangeByName("C30").cellStyle = commontextStyleBold;
      sheet.getRangeByName("C30").rowHeight = 17.40;

      for (int i = 3; i<=30; i++){
        sheet.getRangeByName("G$i").cellStyle = commontextStyle;
        sheet.getRangeByName("G$i").cellStyle.backColor = "#EEECE1";
        sheet.getRangeByName("G$i").cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
      }

      int varTg = (int.tryParse(itfData['tgross']?.toString() ?? '0') ?? 0);
      sheet.getRangeByName("G3").setValue(varTg);

      int varIfhp = int.tryParse(dedData['rent']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("G4").setValue(varIfhp);

      int varAtee = int.tryParse(dedData['80ee']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("G5").setValue(varAtee);

      int varGti = varTg + varIfhp + varAtee;
      sheet.getRangeByName("G6").setValue(varGti);

      int varHli = 0;
      if (dedData['htype'] == "RENT"){
        varHli = int.tryParse(dedData['rent']?.toString() ?? '0') ?? 0;
      }
      sheet.getRangeByName("G7").setValue(varHli);

      int varSd = 75000;
      sheet.getRangeByName("G8").setValue(varSd);

      int varAtccd2 = int.tryParse(dedData['80ccd2']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("G9").setValue(varAtccd2);

      int varOther = [
        int.tryParse(dedData['taexem']?.toString() ?? '0') ?? 0,
        int.tryParse(dedData['other']?.toString() ?? '0') ?? 0
      ].fold(0, (sum, value) => sum + value);
      sheet.getRangeByName("G10").setValue(varOther);

      int varTti = varGti - varHli - varSd - varAtccd2 - varOther;
      if (varTti < 0){
        varTti = 0;
      }
      sheet.getRangeByName("G11").setValue(varTti);

      int varT1 = 0;
      int varT2 = 0;
      int varT3 = 0;
      int varT4 = 0;
      int varT5 = 0;
      int varT6 = 0;
      int varT7 = 0;

      if (varTti > 700000){
        varT2 = 20000;
      } else if (varTti > 300000 && varTti <= 700000){
        varT2 = ((varTti - 300000)*0.05).round();
      }
      if (varTti > 1000000){
        varT3 = 30000;
      } else if (varTti > 700000 && varTti <= 1000000){
        varT3 = ((varTti - 700000)*0.1).round();
      }
      if (varTti > 1200000){
        varT4 = 30000;
      } else if (varTti > 1000000 && varTti <= 1200000){
        varT4 = ((varTti - 1000000)*0.15).round();
      }
      if (varTti > 1500000){
        varT5 = 60000;
        varT6 = ((varTti - 1500000)*0.3).round();
      } else if (varTti > 1200000 && varTti <= 1500000){
        varT5 = ((varTti - 1200000)*0.2).round();
      }

      int varTre = 0;
      if (varTti<=700000){
        varTre = min(25000,(varT2+varT3));
      }

      int varTtl = 0;
      if((varT2+varT3+varT4+varT5+varT6-varTre)>=0){
        varTtl = varT2+varT3+varT4+varT5+varT6-varTre;
      }

      int varEc = 0;
      int varTtp = 0;
      if(varTti> 5000000){
        varT7 = (varTtl * 0.1).round();
        varEc = ((varTtl + varT7)*0.04).round();

        varTtp = varTtl + varEc + varT7;
        int excess = varTtp - 1190000;

        if ((varTti - 5000000) < excess){
          varT7 = (varTti - 5000000 - (varTtl - 1190000));
          if (varT7 > (varTtl * 0.1)){
            varT7 = (varTtl * 0.1).round();
          }
        }
      }

      sheet.getRangeByName("G13").setValue(varT1);
      sheet.getRangeByName("G14").setValue(varT2);
      sheet.getRangeByName("G15").setValue(varT3);
      sheet.getRangeByName("G16").setValue(varT4);
      sheet.getRangeByName("G17").setValue(varT5);
      sheet.getRangeByName("G18").setValue(varT6);
      sheet.getRangeByName("G19").setValue(varT7);
      sheet.getRangeByName("G20").setValue(varTre);
      sheet.getRangeByName("G21").setValue(varTtl);
      varEc = ((varTtl + varT7) * 0.04).round();
      sheet.getRangeByName("G22").setValue(varEc);
      varTtp = varTtl + varEc + varT7;
      sheet.getRangeByName("G23").setValue(varTtp);
      int lastDigit = varTtp % 10;
      int varTtpi = varTtp;
      if (lastDigit > 0){
        varTtpi = varTtp + (10- lastDigit);
      }
      sheet.getRangeByName("G24").setValue(varTtpi);

      int varDeduct = int.tryParse(itfData['tincometax']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("G25").setValue(varDeduct);

      int varNitp = varTtpi - varDeduct;
      if (varNitp < 0){
        varNitp = 0;
      }
      sheet.getRangeByName("G26").setValue(varNitp);

      int varInterest = 0;
      sheet.getRangeByName("G27").setValue(varInterest);

      int varRelief = int.tryParse(dedData['relief']?.toString() ?? '0') ?? 0;
      sheet.getRangeByName("G28").setValue(varRelief);

      int varNitpi = varTtpi - varDeduct - varRelief + varInterest;
      int varEp = 0;
      if (varNitpi < 0){
        varEp = varNitpi.abs();
        varNitpi = 0;
      }
      sheet.getRangeByName("G29").rowHeight = 19.80;
      sheet.getRangeByName("G29").setValue(varNitpi);
      sheet.getRangeByName("G29").cellStyle.fontSize = 14;

      sheet.getRangeByName("G30").setValue(varEp);

      await updateItaxnew(
        biometricId,
        varTg,
        varIfhp,
        varAtee,
        varGti,
        varHli,
        varSd,
        varAtccd2,
        varOther,
        varTti,
        varT1,
        varT2,
        varT3,
        varT4,
        varT5,
        varT6,
        varT7,
        varTre,
        varTtl,
        varEc,
        varTtp,
        varTtpi,
        varDeduct,
        varNitp,
        varInterest,
        varRelief,
        varNitpi,
        varEp
      );
      List<int> excludedNumbers = [3,11,21,22,23,24,26,29,30];
      for (int i = 3; i<=30; i++){
        xls.Range rangeValue = sheet.getRangeByName("G$i");
        xls.Range rangeNum = sheet.getRangeByName("B$i");
        rangeValue.cellStyle = !(excludedNumbers.contains(i))? commontextStyle: commontextStyleBold;
        rangeValue.cellStyle.backColor = "#EEECE1";
        rangeValue.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeValue.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.bottom.lineStyle = xls.LineStyle.thin;
        rangeValue.cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
        rangeNum.cellStyle = commontextStyle;
        rangeNum.cellStyle.borders.all.lineStyle = xls.LineStyle.none;
        rangeNum.cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.bottom.lineStyle = xls.LineStyle.thin;
        rangeNum.cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      }
      sheet.getRangeByName("B30:G30").cellStyle.borders.all.lineStyle = xls.LineStyle.none;
      sheet.getRangeByName("B30:G30").cellStyle.borders.top.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("G30").cellStyle.borders.right.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("C30:F30").cellStyle.borders.right.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("B30:G30").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("B30").cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("C30:F30").cellStyle.borders.left.lineStyle = xls.LineStyle.thin;
      sheet.getRangeByName("G29").cellStyle.fontSize = 14;

      sheet.getRangeByName("G32").setValue("A.O/A.A.O/D.D.O");
      sheet.getRangeByName("G32").cellStyle = commontextStyleBold;
      sheet.getRangeByName("G32").cellStyle.hAlign = xls.HAlignType.right;
      sheet.getRangeByName("G32").cellStyle.borders.all.lineStyle = xls.LineStyle.none;


      sheet.getRangeByName("B34:G34").merge();
      sheet.getRangeByName("B34:G34").setValue(sharedData.zone.toUpperCase());
      sheet.getRangeByName("B34:G34").cellStyle = commontextStyleBold;
      sheet.getRangeByName("B34:G34").cellStyle.borders.all.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("B34:G34").cellStyle.hAlign = xls.HAlignType.center;

      
      sheet.getRangeByName("B35:D35").merge();
      sheet.getRangeByName("B35:D35").cellStyle = commontextStyle;
      sheet.getRangeByName("B35").setValue(mainpgData["panno"]);

      sheet.getRangeByName("E35:G35").merge();
      sheet.getRangeByName("E35:G35").cellStyle = commontextStyle;
      sheet.getRangeByName("E35").setValue("Sub: INCOME TAX FOR THE FINANCIAL YEAR 2024-25");

      sheet.getRangeByName("B36:G36").merge();
      sheet.getRangeByName("B36:G36").cellStyle = commontextStyle;
      sheet.getRangeByName("B36").setFormula(
          r'=CONCATENATE("This is to certify that a sum of ₹ ",$G$29, " is to be recovered as Income Tax for the total income of ₹ ",$G$3," from Sh./Smt./Ms ",' "\"${mainpgData['name']}\"" r'," working as ",'"\"${mainpgData['designation']}\"" r'," in ",$B$33, " on the basis of details of Income furninshed by him / her , GPF / NPS deduction for the month of Feb. 2025 " )'
      );
      sheet.getRangeByName("B36:G36").rowHeight = 40.20;


      sheet.getRangeByName("B38:D38").merge();
      sheet.getRangeByName("B38:E38").cellStyle = commontextStyle;
      sheet.getRangeByName("B38").setValue("Tax Due: ");
      sheet.getRangeByName("E38").setFormula('=G21');

      sheet.getRangeByName("B39:D39").merge();
      sheet.getRangeByName("B39:E39").cellStyle = commontextStyle;
      sheet.getRangeByName("B39").setValue("Surcharge:");
      sheet.getRangeByName("E39").setFormula('=G19');

      sheet.getRangeByName("B40:D40").merge();
      sheet.getRangeByName("B40:E40").cellStyle = commontextStyle;
      sheet.getRangeByName("B40").setValue("Education Cess:");
      sheet.getRangeByName("E40").setFormula('=G22');

      sheet.getRangeByName("B41:D41").merge();
      sheet.getRangeByName("B41:E41").cellStyle = commontextStyle;
      sheet.getRangeByName("B41").setValue("Total Tax Due:");
      sheet.getRangeByName("E41").setFormula('=G24');

      sheet.getRangeByName("B42:D42").merge();
      sheet.getRangeByName("B42:E42").cellStyle = commontextStyle;
      sheet.getRangeByName("B42").setValue("Relief U/S 89(i):");
      sheet.getRangeByName("E42").setFormula('=G28');

      sheet.getRangeByName("B43:D43").merge();
      sheet.getRangeByName("B43:E43").cellStyle = commontextStyle;
      sheet.getRangeByName("B43").setValue("Already Paid:");
      sheet.getRangeByName("E43").setFormula('=G25');

      sheet.getRangeByName("B44:D44").merge();
      sheet.getRangeByName("B44:E44").cellStyle = commontextStyle;
      sheet.getRangeByName("B44").setValue("Balance:");
      sheet.getRangeByName("E44").setFormula('=G29');

      sheet.getRangeByName("B45:G45").merge();
      sheet.getRangeByName("B45:G45").cellStyle = commontextStyle;
      sheet.getRangeByName("B45").setFormula(
        r'=CONCATENATE("Income Tax",IF($G$30<>0,(" EXCESS PAID ₹ "&$G$30),(" TAX DUE ₹ "&$G$29)))'
      );


      sheet.getRangeByName("G43").setValue("A.O/A.A.O/D.D.O");
      sheet.getRangeByName("G43").cellStyle = commontextStyleBold;
      sheet.getRangeByName("G43").cellStyle.hAlign = xls.HAlignType.right;
      sheet.getRangeByName("G43").cellStyle.borders.all.lineStyle = xls.LineStyle.none;

      sheet.getRangeByName("B35:G45").cellStyle.borders.all.lineStyle = xls.LineStyle.none;
      sheet.getRangeByName("B35:B45").cellStyle.borders.left.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("B45:G45").cellStyle.borders.bottom.lineStyle = xls.LineStyle.thick;
      sheet.getRangeByName("G35:G45").cellStyle.borders.right.lineStyle = xls.LineStyle.thick;

    }catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed: \n$error"),
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
  }

  Future<void> exportAll() async{
    try{
      var sortedEntries = biometricData.entries.toList()
        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

      Map<String, dynamic> sortedBiometricData = Map.fromEntries(sortedEntries);
      List<String> biometricIds = sortedBiometricData.keys.toList();
      String inputId = biometricIdController.text.trim();

      int startIndex = (inputId.isNotEmpty && biometricIds.contains(inputId))
          ? biometricIds.indexOf(inputId)
          : 0;

      for (int i = startIndex; i < biometricIds.length; i++) {
        await createExcel(biometricId: biometricIds[i]);
      }

    } catch (error) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed: \n$error"),
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
  }
}

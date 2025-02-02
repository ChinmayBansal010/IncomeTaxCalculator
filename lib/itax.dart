import 'dart:io';
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

  Future<void> fetchmainpgData() async {
    try {
      DatabaseEvent event = await bioRef.child('maindata').child(biometricIdController.text).once();
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

  Future<Map<String, Map<String?, dynamic>>> fetchAllMonthData() async {
    List<String> months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec'];
    Map<String, Map<String?, dynamic>> allMonthData = {};

    for (String month in months) {
      Map<String?, dynamic> data = await fetchMonthData(month);
      allMonthData[month] = data;
    }

    return allMonthData;
  }

  Future<Map<String?, dynamic>> fetchMonthData(String month) async {
    try {

      DatabaseEvent event = await bioRef
          .child('monthdata')
          .child(month)
          .child(biometricIdController.text)
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



  Future<void> fetcharrearData() async {
    try {
      DatabaseEvent event = await bioRef.child('arreardata').child(biometricIdController.text).once();
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

  Future<void> fetchdedData() async {
    try {
      DatabaseEvent event = await bioRef.child('deddata').child(biometricIdController.text).once();
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

  Future<void> updateitax(
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
        int varGrossgross,
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
    try {
      await bioRef.child('itfdata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'tb': varBpgross,
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
        'tgross': varGrossgross,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out elements evenly
                      children: [
                        Expanded(
                          flex: 2, // TextField gets more space
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: _buildTextField('BiometricID', biometricIdController),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                createExcel();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWideScreen ? 32.0 : 24.0,
                                  vertical: isWideScreen ? 16.0 : 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isWideScreen ? 16.0 : 12.0),
                                ),
                                elevation: isWideScreen ? 10.0 : 8.0,
                              ),
                              child: Text(
                                "EXPORT",
                                style: TextStyle(
                                  fontSize: isWideScreen ? 20.0 : 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Add the second button's action here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWideScreen ? 32.0 : 24.0,
                                  vertical: isWideScreen ? 16.0 : 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isWideScreen ? 16.0 : 12.0),
                                ),
                                elevation: isWideScreen ? 10.0 : 8.0,
                              ),
                              child: Text(
                                "EXPORT ALL",
                                style: TextStyle(
                                  fontSize: isWideScreen ? 20.0 : 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            )
                                .toList(),
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


  Future<void> createExcel() async {
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet itaxformSheet = workbook.worksheets[0];
    final xls.Worksheet computationSheet = workbook.worksheets.add();
    final xls.Worksheet itaxoldSheet = workbook.worksheets.add();
    final xls.Worksheet itaxnewSheet = workbook.worksheets.add();


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
    tableheadingStyle.fontSize = 12;
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
    formlastrowStyle.borders.all.lineStyle = xls.LineStyle.thin;
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
    speciallastrowStyle.borders.all.lineStyle = xls.LineStyle.thin;
    speciallastrowStyle.wrapText = true;

    final xls.Style specialtotalrowStyle = workbook.styles.add('specialtotalrowStyle');
    specialtotalrowStyle.fontName = 'Calibri';
    specialtotalrowStyle.fontSize = 11;
    specialtotalrowStyle.bold = true;
    specialtotalrowStyle.fontColor = '#000000';
    specialtotalrowStyle.backColor = '#B9ECE0';
    specialtotalrowStyle.hAlign = xls.HAlignType.left;
    specialtotalrowStyle.vAlign = xls.VAlignType.center;
    specialtotalrowStyle.borders.all.color = '#000000';
    specialtotalrowStyle.borders.all.lineStyle = xls.LineStyle.thin;
    specialtotalrowStyle.wrapText = true;



    await _itaxformPage(itaxformSheet, formheaderStyle,commontextStyle, commontextStyleBold, tableheadingStyle, totalrowStyle, formlastrowStyle, specialcolStyle, specialtotalrowStyle, speciallastrowStyle);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb){
      AnchorElement(
          href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download','${biometricIdController.text}.xlsx')
        ..click();

    } else{
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = '$path/${biometricIdController.text}.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  Future<void> _itaxformPage(
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
    await fetchmainpgData();

    // --------------------- Itax Form ----------------------------
    sheet.getRangeByName('A1').setValue(sharedData.zone);
    sheet.getRangeByName('A1:K1').merge();
    sheet.getRangeByName('A1').rowHeight = 18.60;
    sheet.getRangeByName('A1').columnWidth = 13.33;
    sheet.getRangeByName('A1:K1').cellStyle = formheaderStyle!;

    sheet.getRangeByName('B1:K1').columnWidth = 8.89;

    sheet.getRangeByName('A2').setValue("BIOMETRIC ID");
    sheet.getRangeByName('B2').setValue(mainpgData['biometricid']);
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

    Map<String, Map<String?, dynamic>> monthdata = await fetchAllMonthData();

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





    // =============================== mar ===============================
    int varBpmar = int.tryParse(marData['bp']) ?? 0;
    int varDamar = int.tryParse(marData['da']) ?? 0;
    int varHramar = int.tryParse(marData['hra']) ?? 0;
    int varNpamar = int.tryParse(marData['npa']) ?? 0;
    int varSplpaymar = int.tryParse(marData['splpay']) ?? 0;
    int varConvmar = int.tryParse(marData['conv']) ?? 0;
    int varPgmar = int.tryParse(marData['pg']) ?? 0;
    int varAnnualmar = int.tryParse(marData['annual']) ?? 0;
    int varUniformmar = int.tryParse(marData['uniform']) ?? 0;
    int varNursingmar = int.tryParse(marData['nursing']) ?? 0;
    int varTamar = int.tryParse(marData['ta']) ?? 0;
    int varDaontamar = int.tryParse(marData['daonta']) ?? 0;
    int varMedicalmar = int.tryParse(marData['medical']) ?? 0;
    int varDirtmar = int.tryParse(marData['dirt']) ?? 0;
    int varWashingmar = int.tryParse(marData['washing']) ?? 0;
    int varTbmar = int.tryParse(marData['tb']) ?? 0;
    int varNightmar = int.tryParse(marData['night']) ?? 0;
    int varDrivemar = int.tryParse(marData['drive']) ?? 0;
    int varCyclemar = int.tryParse(marData['cycle']) ?? 0;
    int varPcamar = int.tryParse(marData['pca']) ?? 0;
    int varNpsempmar = int.tryParse(marData['npsemp']) ?? 0;
    int varOthermar = int.tryParse('0') ?? 0;
    int varDaext1mar = int.tryParse(marData['daext1']) ?? 0;
    int varDaext2mar = int.tryParse(marData['daext2']) ?? 0;
    int varDaext3mar = int.tryParse(marData['daext3']) ?? 0;
    int varDaext4mar = int.tryParse(marData['daext4']) ?? 0;
    int varGrossmar = int.tryParse(marData['gross']) ?? 0;
    int varSalarymar = [
      varBpmar, varDamar, varHramar, varNpamar, varSplpaymar, varConvmar, varPgmar,
      varAnnualmar, varUniformmar, varNursingmar, varTamar, varDaontamar, varMedicalmar,
      varDirtmar, varWashingmar, varTbmar, varNightmar, varDrivemar, varCyclemar,
      varPcamar, varNpsempmar, varOthermar, varDaext1mar, varDaext2mar, varDaext3mar, varDaext4mar, varGrossmar,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxmar = int.tryParse(marData['incometax']) ?? 0;
    int varGismar = int.tryParse(marData['gis']) ?? 0;
    int varGpfmar = int.tryParse(marData['gpf']) ?? 0;
    int varNpsmar = int.tryParse(marData['nps']) ?? 0;
    int varSlfmar = int.tryParse(marData['slf']) ?? 0;
    int varSocietymar = int.tryParse(marData['society']) ?? 0;
    int varRecoverymar = int.tryParse(marData['recovery']) ?? 0;
    int varWfmar = int.tryParse(marData['wf']) ?? 0;
    int varOther2mar = int.tryParse(marData['other']) ?? 0;
    int varDdext1mar = int.tryParse(marData['ddext1']) ?? 0;
    int varDdext2mar = int.tryParse(marData['ddext2']) ?? 0;
    int varDdext3mar = int.tryParse(marData['ddext3']) ?? 0;
    int varDdext4mar = int.tryParse(marData['ddext4']) ?? 0;
    int varTotaldedmar = int.tryParse(marData['totalded']) ?? 0;
    int varNetsalarymar = int.tryParse(marData['netsalary']) ?? 0;

    // =============================== apr ===============================
    int varBpapr = int.tryParse(aprData['bp']) ?? 0;
    int varDaapr = int.tryParse(aprData['da']) ?? 0;
    int varHraapr = int.tryParse(aprData['hra']) ?? 0;
    int varNpaapr = int.tryParse(aprData['npa']) ?? 0;
    int varSplpayapr = int.tryParse(aprData['splpay']) ?? 0;
    int varConvapr = int.tryParse(aprData['conv']) ?? 0;
    int varPgapr = int.tryParse(aprData['pg']) ?? 0;
    int varAnnualapr = int.tryParse(aprData['annual']) ?? 0;
    int varUniformapr = int.tryParse(aprData['uniform']) ?? 0;
    int varNursingapr = int.tryParse(aprData['nursing']) ?? 0;
    int varTaapr = int.tryParse(aprData['ta']) ?? 0;
    int varDaontaapr = int.tryParse(aprData['daonta']) ?? 0;
    int varMedicalapr = int.tryParse(aprData['medical']) ?? 0;
    int varDirtapr = int.tryParse(aprData['dirt']) ?? 0;
    int varWashingapr = int.tryParse(aprData['washing']) ?? 0;
    int varTbapr = int.tryParse(aprData['tb']) ?? 0;
    int varNightapr = int.tryParse(aprData['night']) ?? 0;
    int varDriveapr = int.tryParse(aprData['drive']) ?? 0;
    int varCycleapr = int.tryParse(aprData['cycle']) ?? 0;
    int varPcaapr = int.tryParse(aprData['pca']) ?? 0;
    int varNpsempapr = int.tryParse(aprData['npsemp']) ?? 0;
    int varOtherapr = int.tryParse('0') ?? 0;
    int varDaext1apr = int.tryParse(aprData['daext1']) ?? 0;
    int varDaext2apr = int.tryParse(aprData['daext2']) ?? 0;
    int varDaext3apr = int.tryParse(aprData['daext3']) ?? 0;
    int varDaext4apr = int.tryParse(aprData['daext4']) ?? 0;
    int varGrossapr = int.tryParse(aprData['gross']) ?? 0;
    int varSalaryapr = [
      varBpapr, varDaapr, varHraapr, varNpaapr, varSplpayapr, varConvapr, varPgapr,
      varAnnualapr, varUniformapr, varNursingapr, varTaapr, varDaontaapr, varMedicalapr,
      varDirtapr, varWashingapr, varTbapr, varNightapr, varDriveapr, varCycleapr,
      varPcaapr, varNpsempapr, varOtherapr, varDaext1apr, varDaext2apr, varDaext3apr, varDaext4apr, varGrossapr,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxapr = int.tryParse(aprData['incometax']) ?? 0;
    int varGisapr = int.tryParse(aprData['gis']) ?? 0;
    int varGpfapr = int.tryParse(aprData['gpf']) ?? 0;
    int varNpsapr = int.tryParse(aprData['nps']) ?? 0;
    int varSlfapr = int.tryParse(aprData['slf']) ?? 0;
    int varSocietyapr = int.tryParse(aprData['society']) ?? 0;
    int varRecoveryapr = int.tryParse(aprData['recovery']) ?? 0;
    int varWfapr = int.tryParse(aprData['wf']) ?? 0;
    int varOther2apr = int.tryParse(aprData['other']) ?? 0;
    int varDdext1apr = int.tryParse(aprData['ddext1']) ?? 0;
    int varDdext2apr = int.tryParse(aprData['ddext2']) ?? 0;
    int varDdext3apr = int.tryParse(aprData['ddext3']) ?? 0;
    int varDdext4apr = int.tryParse(aprData['ddext4']) ?? 0;
    int varTotaldedapr = int.tryParse(aprData['totalded']) ?? 0;
    int varNetsalaryapr = int.tryParse(aprData['netsalary']) ?? 0;

    // =============================== may ===============================
    int varBpmay = int.tryParse(mayData['bp']) ?? 0;
    int varDamay = int.tryParse(mayData['da']) ?? 0;
    int varHramay = int.tryParse(mayData['hra']) ?? 0;
    int varNpamay = int.tryParse(mayData['npa']) ?? 0;
    int varSplpaymay = int.tryParse(mayData['splpay']) ?? 0;
    int varConvmay = int.tryParse(mayData['conv']) ?? 0;
    int varPgmay = int.tryParse(mayData['pg']) ?? 0;
    int varAnnualmay = int.tryParse(mayData['annual']) ?? 0;
    int varUniformmay = int.tryParse(mayData['uniform']) ?? 0;
    int varNursingmay = int.tryParse(mayData['nursing']) ?? 0;
    int varTamay = int.tryParse(mayData['ta']) ?? 0;
    int varDaontamay = int.tryParse(mayData['daonta']) ?? 0;
    int varMedicalmay = int.tryParse(mayData['medical']) ?? 0;
    int varDirtmay = int.tryParse(mayData['dirt']) ?? 0;
    int varWashingmay = int.tryParse(mayData['washing']) ?? 0;
    int varTbmay = int.tryParse(mayData['tb']) ?? 0;
    int varNightmay = int.tryParse(mayData['night']) ?? 0;
    int varDrivemay = int.tryParse(mayData['drive']) ?? 0;
    int varCyclemay = int.tryParse(mayData['cycle']) ?? 0;
    int varPcamay = int.tryParse(mayData['pca']) ?? 0;
    int varNpsempmay = int.tryParse(mayData['npsemp']) ?? 0;
    int varOthermay = int.tryParse('0') ?? 0;
    int varDaext1may = int.tryParse(mayData['daext1']) ?? 0;
    int varDaext2may = int.tryParse(mayData['daext2']) ?? 0;
    int varDaext3may = int.tryParse(mayData['daext3']) ?? 0;
    int varDaext4may = int.tryParse(mayData['daext4']) ?? 0;
    int varGrossmay = int.tryParse(mayData['gross']) ?? 0;
    int varSalarymay = [
      varBpmay, varDamay, varHramay, varNpamay, varSplpaymay, varConvmay, varPgmay,
      varAnnualmay, varUniformmay, varNursingmay, varTamay, varDaontamay, varMedicalmay,
      varDirtmay, varWashingmay, varTbmay, varNightmay, varDrivemay, varCyclemay,
      varPcamay, varNpsempmay, varOthermay, varDaext1may, varDaext2may, varDaext3may, varDaext4may, varGrossmay,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxmay = int.tryParse(mayData['incometax']) ?? 0;
    int varGismay = int.tryParse(mayData['gis']) ?? 0;
    int varGpfmay = int.tryParse(mayData['gpf']) ?? 0;
    int varNpsmay = int.tryParse(mayData['nps']) ?? 0;
    int varSlfmay = int.tryParse(mayData['slf']) ?? 0;
    int varSocietymay = int.tryParse(mayData['society']) ?? 0;
    int varRecoverymay = int.tryParse(mayData['recovery']) ?? 0;
    int varWfmay = int.tryParse(mayData['wf']) ?? 0;
    int varOther2may = int.tryParse(mayData['other']) ?? 0;
    int varDdext1may = int.tryParse(mayData['ddext1']) ?? 0;
    int varDdext2may = int.tryParse(mayData['ddext2']) ?? 0;
    int varDdext3may = int.tryParse(mayData['ddext3']) ?? 0;
    int varDdext4may = int.tryParse(mayData['ddext4']) ?? 0;
    int varTotaldedmay = int.tryParse(mayData['totalded']) ?? 0;
    int varNetsalarymay = int.tryParse(mayData['netsalary']) ?? 0;



  // ============================= arrearqtr1 ==============================
    int varBparrearqtr1 = int.tryParse('0') ?? 0;
    int varDaarrearqtr1 = int.tryParse(arrearData['mmda']) ?? 0;
    int varHraarrearqtr1 = int.tryParse(arrearData['mmhra']) ?? 0;
    int varNpaarrearqtr1 = int.tryParse(arrearData['mmnpa']) ?? 0;
    int varSplpayarrearqtr1 = int.tryParse('0') ?? 0;
    int varConvarrearqtr1 = int.tryParse('0') ?? 0;
    int varPgarrearqtr1 = int.tryParse('0') ?? 0;
    int varAnnualarrearqtr1 = int.tryParse('0')?? 0;
    int varUniformarrearqtr1 = int.tryParse('0') ?? 0;
    int varNursingarrearqtr1 = int.tryParse('0') ?? 0;
    int varTaarrearqtr1 = int.tryParse('0') ?? 0;
    int varDaontaarrearqtr1 = int.tryParse(arrearData['mmdaonta']) ?? 0;
    int varMedicalarrearqtr1 = int.tryParse('0') ?? 0;
    int varDirtarrearqtr1 = int.tryParse('0') ?? 0;
    int varWashingarrearqtr1 = int.tryParse('0') ?? 0;
    int varTbarrearqtr1 = int.tryParse('0') ?? 0;
    int varNightarrearqtr1 = int.tryParse('0') ?? 0;
    int varDrivearrearqtr1 = int.tryParse('0') ?? 0;
    int varCyclearrearqtr1 = int.tryParse('0') ?? 0;
    int varPcaarrearqtr1 = int.tryParse(arrearData['mmpca']) ?? 0;
    int varNpsemparrearqtr1 = int.tryParse('0') ?? 0;
    int varOtherarrearqtr1 = int.tryParse(arrearData['mmother']) ?? 0;
    int varDaext1arrearqtr1 = int.tryParse('0') ?? 0;
    int varDaext2arrearqtr1 = int.tryParse('0') ?? 0;
    int varDaext3arrearqtr1 = int.tryParse('0') ?? 0;
    int varDaext4arrearqtr1 = int.tryParse('0') ?? 0;
    int varGrossarrearqtr1 = int.tryParse('0') ?? 0;
    int varSalaryarrearqtr1 = [
      varBparrearqtr1, varDaarrearqtr1, varHraarrearqtr1, varNpaarrearqtr1, varSplpayarrearqtr1, varConvarrearqtr1, varPgarrearqtr1,
      varAnnualarrearqtr1, varUniformarrearqtr1, varNursingarrearqtr1, varTaarrearqtr1, varDaontaarrearqtr1, varMedicalarrearqtr1,
      varDirtarrearqtr1, varWashingarrearqtr1, varTbarrearqtr1, varNightarrearqtr1, varDrivearrearqtr1, varCyclearrearqtr1,
      varPcaarrearqtr1, varNpsemparrearqtr1, varOtherarrearqtr1, varDaext1arrearqtr1, varDaext2arrearqtr1, varDaext3arrearqtr1, varDaext4arrearqtr1, varGrossarrearqtr1,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxarrearqtr1 = int.tryParse(arrearData['mmext1']) ?? 0;
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
    int varGrossqtr1 = [varGrossmar, varGrossapr, varGrossmay, varGrossarrearqtr1].fold(0, (sum, value) => sum + value);
    int varSalaryqtr1 = [varBpqtr1, varDaqtr1, varHraqtr1, varNpaqtr1, varSplpayqtr1, varConvqtr1, varPgqtr1,
      varAnnualqtr1, varUniformqtr1, varNursingqtr1, varTaqtr1, varDaontaqtr1, varMedicalqtr1,
      varDirtqtr1, varWashingqtr1, varTbqtr1, varNightqtr1, varDriveqtr1, varCycleqtr1,
      varPcaqtr1, varNpsempqtr1, varOtherqtr1, varDaext1qtr1, varDaext2qtr1, varDaext3qtr1, varDaext4qtr1, varGrossqtr1
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
    int varBpjun = int.tryParse(junData['bp']) ?? 0;
    int varDajun = int.tryParse(junData['da']) ?? 0;
    int varHrajun = int.tryParse(junData['hra']) ?? 0;
    int varNpajun = int.tryParse(junData['npa']) ?? 0;
    int varSplpayjun = int.tryParse(junData['splpay']) ?? 0;
    int varConvjun = int.tryParse(junData['conv']) ?? 0;
    int varPgjun = int.tryParse(junData['pg']) ?? 0;
    int varAnnualjun = int.tryParse(junData['annual']) ?? 0;
    int varUniformjun = int.tryParse(junData['uniform']) ?? 0;
    int varNursingjun = int.tryParse(junData['nursing']) ?? 0;
    int varTajun = int.tryParse(junData['ta']) ?? 0;
    int varDaontajun = int.tryParse(junData['daonta']) ?? 0;
    int varMedicaljun = int.tryParse(junData['medical']) ?? 0;
    int varDirtjun = int.tryParse(junData['dirt']) ?? 0;
    int varWashingjun = int.tryParse(junData['washing']) ?? 0;
    int varTbjun = int.tryParse(junData['tb']) ?? 0;
    int varNightjun = int.tryParse(junData['night']) ?? 0;
    int varDrivejun = int.tryParse(junData['drive']) ?? 0;
    int varCyclejun = int.tryParse(junData['cycle']) ?? 0;
    int varPcajun = int.tryParse(junData['pca']) ?? 0;
    int varNpsempjun = int.tryParse(junData['npsemp']) ?? 0;
    int varOtherjun = int.tryParse('0') ?? 0;
    int varDaext1jun = int.tryParse(junData['daext1']) ?? 0;
    int varDaext2jun = int.tryParse(junData['daext2']) ?? 0;
    int varDaext3jun = int.tryParse(junData['daext3']) ?? 0;
    int varDaext4jun = int.tryParse(junData['daext4']) ?? 0;
    int varGrossjun = int.tryParse(junData['gross']) ?? 0;
    int varSalaryjun = [
      varBpjun, varDajun, varHrajun, varNpajun, varSplpayjun, varConvjun, varPgjun,
      varAnnualjun, varUniformjun, varNursingjun, varTajun, varDaontajun, varMedicaljun,
      varDirtjun, varWashingjun, varTbjun, varNightjun, varDrivejun, varCyclejun,
      varPcajun, varNpsempjun, varOtherjun, varDaext1jun, varDaext2jun, varDaext3jun, varDaext4jun, varGrossjun,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxjun = int.tryParse(junData['incometax']) ?? 0;
    int varGisjun = int.tryParse(junData['gis']) ?? 0;
    int varGpfjun = int.tryParse(junData['gpf']) ?? 0;
    int varNpsjun = int.tryParse(junData['nps']) ?? 0;
    int varSlfjun = int.tryParse(junData['slf']) ?? 0;
    int varSocietyjun = int.tryParse(junData['society']) ?? 0;
    int varRecoveryjun = int.tryParse(junData['recovery']) ?? 0;
    int varWfjun = int.tryParse(junData['wf']) ?? 0;
    int varOther2jun = int.tryParse(junData['other']) ?? 0;
    int varDdext1jun = int.tryParse(junData['ddext1']) ?? 0;
    int varDdext2jun = int.tryParse(junData['ddext2']) ?? 0;
    int varDdext3jun = int.tryParse(junData['ddext3']) ?? 0;
    int varDdext4jun = int.tryParse(junData['ddext4']) ?? 0;
    int varTotaldedjun = int.tryParse(junData['totalded']) ?? 0;
    int varNetsalaryjun = int.tryParse(junData['netsalary']) ?? 0;

    // =============================== jul ===============================
    int varBpjul = int.tryParse(julData['bp']) ?? 0;
    int varDajul = int.tryParse(julData['da']) ?? 0;
    int varHrajul = int.tryParse(julData['hra']) ?? 0;
    int varNpajul = int.tryParse(julData['npa']) ?? 0;
    int varSplpayjul = int.tryParse(julData['splpay']) ?? 0;
    int varConvjul = int.tryParse(julData['conv']) ?? 0;
    int varPgjul = int.tryParse(julData['pg']) ?? 0;
    int varAnnualjul = int.tryParse(julData['annual']) ?? 0;
    int varUniformjul = int.tryParse(julData['uniform']) ?? 0;
    int varNursingjul = int.tryParse(julData['nursing']) ?? 0;
    int varTajul = int.tryParse(julData['ta']) ?? 0;
    int varDaontajul = int.tryParse(julData['daonta']) ?? 0;
    int varMedicaljul = int.tryParse(julData['medical']) ?? 0;
    int varDirtjul = int.tryParse(julData['dirt']) ?? 0;
    int varWashingjul = int.tryParse(julData['washing']) ?? 0;
    int varTbjul = int.tryParse(julData['tb']) ?? 0;
    int varNightjul = int.tryParse(julData['night']) ?? 0;
    int varDrivejul = int.tryParse(julData['drive']) ?? 0;
    int varCyclejul = int.tryParse(julData['cycle']) ?? 0;
    int varPcajul = int.tryParse(julData['pca']) ?? 0;
    int varNpsempjul = int.tryParse(julData['npsemp']) ?? 0;
    int varOtherjul = int.tryParse('0') ?? 0;
    int varDaext1jul = int.tryParse(julData['daext1']) ?? 0;
    int varDaext2jul = int.tryParse(julData['daext2']) ?? 0;
    int varDaext3jul = int.tryParse(julData['daext3']) ?? 0;
    int varDaext4jul = int.tryParse(julData['daext4']) ?? 0;
    int varGrossjul = int.tryParse(julData['gross']) ?? 0;
    int varSalaryjul = [
      varBpjul, varDajul, varHrajul, varNpajul, varSplpayjul, varConvjul, varPgjul,
      varAnnualjul, varUniformjul, varNursingjul, varTajul, varDaontajul, varMedicaljul,
      varDirtjul, varWashingjul, varTbjul, varNightjul, varDrivejul, varCyclejul,
      varPcajul, varNpsempjul, varOtherjul, varDaext1jul, varDaext2jul, varDaext3jul, varDaext4jul, varGrossjul,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxjul = int.tryParse(julData['incometax']) ?? 0;
    int varGisjul = int.tryParse(julData['gis']) ?? 0;
    int varGpfjul = int.tryParse(julData['gpf']) ?? 0;
    int varNpsjul = int.tryParse(julData['nps']) ?? 0;
    int varSlfjul = int.tryParse(julData['slf']) ?? 0;
    int varSocietyjul = int.tryParse(julData['society']) ?? 0;
    int varRecoveryjul = int.tryParse(julData['recovery']) ?? 0;
    int varWfjul = int.tryParse(julData['wf']) ?? 0;
    int varOther2jul = int.tryParse(julData['other']) ?? 0;
    int varDdext1jul = int.tryParse(julData['ddext1']) ?? 0;
    int varDdext2jul = int.tryParse(julData['ddext2']) ?? 0;
    int varDdext3jul = int.tryParse(julData['ddext3']) ?? 0;
    int varDdext4jul = int.tryParse(julData['ddext4']) ?? 0;
    int varTotaldedjul = int.tryParse(julData['totalded']) ?? 0;
    int varNetsalaryjul = int.tryParse(julData['netsalary']) ?? 0;

    // =============================== aug ===============================
    int varBpaug = int.tryParse(augData['bp']) ?? 0;
    int varDaaug = int.tryParse(augData['da']) ?? 0;
    int varHraaug = int.tryParse(augData['hra']) ?? 0;
    int varNpaaug = int.tryParse(augData['npa']) ?? 0;
    int varSplpayaug = int.tryParse(augData['splpay']) ?? 0;
    int varConvaug = int.tryParse(augData['conv']) ?? 0;
    int varPgaug = int.tryParse(augData['pg']) ?? 0;
    int varAnnualaug = int.tryParse(augData['annual']) ?? 0;
    int varUniformaug = int.tryParse(augData['uniform']) ?? 0;
    int varNursingaug = int.tryParse(augData['nursing']) ?? 0;
    int varTaaug = int.tryParse(augData['ta']) ?? 0;
    int varDaontaaug = int.tryParse(augData['daonta']) ?? 0;
    int varMedicalaug = int.tryParse(augData['medical']) ?? 0;
    int varDirtaug = int.tryParse(augData['dirt']) ?? 0;
    int varWashingaug = int.tryParse(augData['washing']) ?? 0;
    int varTbaug = int.tryParse(augData['tb']) ?? 0;
    int varNightaug = int.tryParse(augData['night']) ?? 0;
    int varDriveaug = int.tryParse(augData['drive']) ?? 0;
    int varCycleaug = int.tryParse(augData['cycle']) ?? 0;
    int varPcaaug = int.tryParse(augData['pca']) ?? 0;
    int varNpsempaug = int.tryParse(augData['npsemp']) ?? 0;
    int varOtheraug = int.tryParse('0') ?? 0;
    int varDaext1aug = int.tryParse(augData['daext1']) ?? 0;
    int varDaext2aug = int.tryParse(augData['daext2']) ?? 0;
    int varDaext3aug = int.tryParse(augData['daext3']) ?? 0;
    int varDaext4aug = int.tryParse(augData['daext4']) ?? 0;
    int varGrossaug = int.tryParse(augData['gross']) ?? 0;
    int varSalaryaug = [
      varBpaug, varDaaug, varHraaug, varNpaaug, varSplpayaug, varConvaug, varPgaug,
      varAnnualaug, varUniformaug, varNursingaug, varTaaug, varDaontaaug, varMedicalaug,
      varDirtaug, varWashingaug, varTbaug, varNightaug, varDriveaug, varCycleaug,
      varPcaaug, varNpsempaug, varOtheraug, varDaext1aug, varDaext2aug, varDaext3aug, varDaext4aug, varGrossaug,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxaug = int.tryParse(augData['incometax']) ?? 0;
    int varGisaug = int.tryParse(augData['gis']) ?? 0;
    int varGpfaug = int.tryParse(augData['gpf']) ?? 0;
    int varNpsaug = int.tryParse(augData['nps']) ?? 0;
    int varSlfaug = int.tryParse(augData['slf']) ?? 0;
    int varSocietyaug = int.tryParse(augData['society']) ?? 0;
    int varRecoveryaug = int.tryParse(augData['recovery']) ?? 0;
    int varWfaug = int.tryParse(augData['wf']) ?? 0;
    int varOther2aug = int.tryParse(augData['other']) ?? 0;
    int varDdext1aug = int.tryParse(augData['ddext1']) ?? 0;
    int varDdext2aug = int.tryParse(augData['ddext2']) ?? 0;
    int varDdext3aug = int.tryParse(augData['ddext3']) ?? 0;
    int varDdext4aug = int.tryParse(augData['ddext4']) ?? 0;
    int varTotaldedaug = int.tryParse(augData['totalded']) ?? 0;
    int varNetsalaryaug = int.tryParse(augData['netsalary']) ?? 0;



    // ============================= arrearqtr2 ==============================
    int varBparrearqtr2 = int.tryParse('0') ?? 0;
    int varDaarrearqtr2 = int.tryParse(arrearData['jada']) ?? 0;
    int varHraarrearqtr2 = int.tryParse(arrearData['jahra']) ?? 0;
    int varNpaarrearqtr2 = int.tryParse(arrearData['janpa']) ?? 0;
    int varSplpayarrearqtr2 = int.tryParse('0') ?? 0;
    int varConvarrearqtr2 = int.tryParse('0') ?? 0;
    int varPgarrearqtr2 = int.tryParse('0') ?? 0;
    int varAnnualarrearqtr2 = int.tryParse('0')?? 0;
    int varUniforjunrearqtr2 = int.tryParse('0') ?? 0;
    int varNursingarrearqtr2 = int.tryParse('0') ?? 0;
    int varTaarrearqtr2 = int.tryParse('0') ?? 0;
    int varDaontaarrearqtr2 = int.tryParse(arrearData['jadaonta']) ?? 0;
    int varMedicalarrearqtr2 = int.tryParse('0') ?? 0;
    int varDirtarrearqtr2 = int.tryParse('0') ?? 0;
    int varWashingarrearqtr2 = int.tryParse('0') ?? 0;
    int varTbarrearqtr2 = int.tryParse('0') ?? 0;
    int varNightarrearqtr2 = int.tryParse('0') ?? 0;
    int varDrivearrearqtr2 = int.tryParse('0') ?? 0;
    int varCyclearrearqtr2 = int.tryParse('0') ?? 0;
    int varPcaarrearqtr2 = int.tryParse(arrearData['japca']) ?? 0;
    int varNpsemparrearqtr2 = int.tryParse('0') ?? 0;
    int varOtherarrearqtr2 = int.tryParse(arrearData['jaother']) ?? 0;
    int varDaext1arrearqtr2 = int.tryParse('0') ?? 0;
    int varDaext2arrearqtr2 = int.tryParse('0') ?? 0;
    int varDaext3arrearqtr2 = int.tryParse('0') ?? 0;
    int varDaext4arrearqtr2 = int.tryParse('0') ?? 0;
    int varGrossarrearqtr2 = int.tryParse('0') ?? 0;
    int varSalaryarrearqtr2 = [
      varBparrearqtr2, varDaarrearqtr2, varHraarrearqtr2, varNpaarrearqtr2, varSplpayarrearqtr2, varConvarrearqtr2, varPgarrearqtr2,
      varAnnualarrearqtr2, varUniforjunrearqtr2, varNursingarrearqtr2, varTaarrearqtr2, varDaontaarrearqtr2, varMedicalarrearqtr2,
      varDirtarrearqtr2, varWashingarrearqtr2, varTbarrearqtr2, varNightarrearqtr2, varDrivearrearqtr2, varCyclearrearqtr2,
      varPcaarrearqtr2, varNpsemparrearqtr2, varOtherarrearqtr2, varDaext1arrearqtr2, varDaext2arrearqtr2, varDaext3arrearqtr2, varDaext4arrearqtr2, varGrossarrearqtr2,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxarrearqtr2 = int.tryParse(arrearData['jaext1']) ?? 0;
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
    int varUniformqtr2 = [varUniformjun, varUniformjul, varUniformaug, varUniforjunrearqtr2].fold(0, (sum, value) => sum + value);
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
    int varGrossqtr2 = [varGrossjun, varGrossjul, varGrossaug, varGrossarrearqtr2].fold(0, (sum, value) => sum + value);
    int varSalaryqtr2 = [varBpqtr2, varDaqtr2, varHraqtr2, varNpaqtr2, varSplpayqtr2, varConvqtr2, varPgqtr2,
      varAnnualqtr2, varUniformqtr2, varNursingqtr2, varTaqtr2, varDaontaqtr2, varMedicalqtr2,
      varDirtqtr2, varWashingqtr2, varTbqtr2, varNightqtr2, varDriveqtr2, varCycleqtr2,
      varPcaqtr2, varNpsempqtr2, varOtherqtr2, varDaext1qtr2, varDaext2qtr2, varDaext3qtr2, varDaext4qtr2, varGrossqtr2
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
    int varBpsept = int.tryParse(septData['bp']) ?? 0;
    int varDasept = int.tryParse(septData['da']) ?? 0;
    int varHrasept = int.tryParse(septData['hra']) ?? 0;
    int varNpasept = int.tryParse(septData['npa']) ?? 0;
    int varSplpaysept = int.tryParse(septData['splpay']) ?? 0;
    int varConvsept = int.tryParse(septData['conv']) ?? 0;
    int varPgsept = int.tryParse(septData['pg']) ?? 0;
    int varAnnualsept = int.tryParse(septData['annual']) ?? 0;
    int varUniformsept = int.tryParse(septData['uniform']) ?? 0;
    int varNursingsept = int.tryParse(septData['nursing']) ?? 0;
    int varTasept = int.tryParse(septData['ta']) ?? 0;
    int varDaontasept = int.tryParse(septData['daonta']) ?? 0;
    int varMedicalsept = int.tryParse(septData['medical']) ?? 0;
    int varDirtsept = int.tryParse(septData['dirt']) ?? 0;
    int varWashingsept = int.tryParse(septData['washing']) ?? 0;
    int varTbsept = int.tryParse(septData['tb']) ?? 0;
    int varNightsept = int.tryParse(septData['night']) ?? 0;
    int varDrivesept = int.tryParse(septData['drive']) ?? 0;
    int varCyclesept = int.tryParse(septData['cycle']) ?? 0;
    int varPcasept = int.tryParse(septData['pca']) ?? 0;
    int varNpsempsept = int.tryParse(septData['npsemp']) ?? 0;
    int varOthersept = int.tryParse('0') ?? 0;
    int varDaext1sept = int.tryParse(septData['daext1']) ?? 0;
    int varDaext2sept = int.tryParse(septData['daext2']) ?? 0;
    int varDaext3sept = int.tryParse(septData['daext3']) ?? 0;
    int varDaext4sept = int.tryParse(septData['daext4']) ?? 0;
    int varGrosssept = int.tryParse(septData['gross']) ?? 0;
    int varSalarysept = [
      varBpsept, varDasept, varHrasept, varNpasept, varSplpaysept, varConvsept, varPgsept,
      varAnnualsept, varUniformsept, varNursingsept, varTasept, varDaontasept, varMedicalsept,
      varDirtsept, varWashingsept, varTbsept, varNightsept, varDrivesept, varCyclesept,
      varPcasept, varNpsempsept, varOthersept, varDaext1sept, varDaext2sept, varDaext3sept, varDaext4sept, varGrosssept,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxsept = int.tryParse(septData['incometax']) ?? 0;
    int varGissept = int.tryParse(septData['gis']) ?? 0;
    int varGpfsept = int.tryParse(septData['gpf']) ?? 0;
    int varNpssept = int.tryParse(septData['nps']) ?? 0;
    int varSlfsept = int.tryParse(septData['slf']) ?? 0;
    int varSocietysept = int.tryParse(septData['society']) ?? 0;
    int varRecoverysept = int.tryParse(septData['recovery']) ?? 0;
    int varWfsept = int.tryParse(septData['wf']) ?? 0;
    int varOther2sept = int.tryParse(septData['other']) ?? 0;
    int varDdext1sept = int.tryParse(septData['ddext1']) ?? 0;
    int varDdext2sept = int.tryParse(septData['ddext2']) ?? 0;
    int varDdext3sept = int.tryParse(septData['ddext3']) ?? 0;
    int varDdext4sept = int.tryParse(septData['ddext4']) ?? 0;
    int varTotaldedsept = int.tryParse(septData['totalded']) ?? 0;
    int varNetsalarysept = int.tryParse(septData['netsalary']) ?? 0;

    // =============================== oct ===============================
    int varBpoct = int.tryParse(octData['bp']) ?? 0;
    int varDaoct = int.tryParse(octData['da']) ?? 0;
    int varHraoct = int.tryParse(octData['hra']) ?? 0;
    int varNpaoct = int.tryParse(octData['npa']) ?? 0;
    int varSplpayoct = int.tryParse(octData['splpay']) ?? 0;
    int varConvoct = int.tryParse(octData['conv']) ?? 0;
    int varPgoct = int.tryParse(octData['pg']) ?? 0;
    int varAnnualoct = int.tryParse(octData['annual']) ?? 0;
    int varUniformoct = int.tryParse(octData['uniform']) ?? 0;
    int varNursingoct = int.tryParse(octData['nursing']) ?? 0;
    int varTaoct = int.tryParse(octData['ta']) ?? 0;
    int varDaontaoct = int.tryParse(octData['daonta']) ?? 0;
    int varMedicaloct = int.tryParse(octData['medical']) ?? 0;
    int varDirtoct = int.tryParse(octData['dirt']) ?? 0;
    int varWashingoct = int.tryParse(octData['washing']) ?? 0;
    int varTboct = int.tryParse(octData['tb']) ?? 0;
    int varNightoct = int.tryParse(octData['night']) ?? 0;
    int varDriveoct = int.tryParse(octData['drive']) ?? 0;
    int varCycleoct = int.tryParse(octData['cycle']) ?? 0;
    int varPcaoct = int.tryParse(octData['pca']) ?? 0;
    int varNpsempoct = int.tryParse(octData['npsemp']) ?? 0;
    int varOtheroct = int.tryParse('0') ?? 0;
    int varDaext1oct = int.tryParse(octData['daext1']) ?? 0;
    int varDaext2oct = int.tryParse(octData['daext2']) ?? 0;
    int varDaext3oct = int.tryParse(octData['daext3']) ?? 0;
    int varDaext4oct = int.tryParse(octData['daext4']) ?? 0;
    int varGrossoct = int.tryParse(octData['gross']) ?? 0;
    int varSalaryoct = [
      varBpoct, varDaoct, varHraoct, varNpaoct, varSplpayoct, varConvoct, varPgoct,
      varAnnualoct, varUniformoct, varNursingoct, varTaoct, varDaontaoct, varMedicaloct,
      varDirtoct, varWashingoct, varTboct, varNightoct, varDriveoct, varCycleoct,
      varPcaoct, varNpsempoct, varOtheroct, varDaext1oct, varDaext2oct, varDaext3oct, varDaext4oct, varGrossoct,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxoct = int.tryParse(octData['incometax']) ?? 0;
    int varGisoct = int.tryParse(octData['gis']) ?? 0;
    int varGpfoct = int.tryParse(octData['gpf']) ?? 0;
    int varNpsoct = int.tryParse(octData['nps']) ?? 0;
    int varSlfoct = int.tryParse(octData['slf']) ?? 0;
    int varSocietyoct = int.tryParse(octData['society']) ?? 0;
    int varRecoveryoct = int.tryParse(octData['recovery']) ?? 0;
    int varWfoct = int.tryParse(octData['wf']) ?? 0;
    int varOther2oct = int.tryParse(octData['other']) ?? 0;
    int varDdext1oct = int.tryParse(octData['ddext1']) ?? 0;
    int varDdext2oct = int.tryParse(octData['ddext2']) ?? 0;
    int varDdext3oct = int.tryParse(octData['ddext3']) ?? 0;
    int varDdext4oct = int.tryParse(octData['ddext4']) ?? 0;
    int varTotaldedoct = int.tryParse(octData['totalded']) ?? 0;
    int varNetsalaryoct = int.tryParse(octData['netsalary']) ?? 0;

    // =============================== nov ===============================
    int varBpnov = int.tryParse(novData['bp']) ?? 0;
    int varDanov = int.tryParse(novData['da']) ?? 0;
    int varHranov = int.tryParse(novData['hra']) ?? 0;
    int varNpanov = int.tryParse(novData['npa']) ?? 0;
    int varSplpaynov = int.tryParse(novData['splpay']) ?? 0;
    int varConvnov = int.tryParse(novData['conv']) ?? 0;
    int varPgnov = int.tryParse(novData['pg']) ?? 0;
    int varAnnualnov = int.tryParse(novData['annual']) ?? 0;
    int varUniformnov = int.tryParse(novData['uniform']) ?? 0;
    int varNursingnov = int.tryParse(novData['nursing']) ?? 0;
    int varTanov = int.tryParse(novData['ta']) ?? 0;
    int varDaontanov = int.tryParse(novData['daonta']) ?? 0;
    int varMedicalnov = int.tryParse(novData['medical']) ?? 0;
    int varDirtnov = int.tryParse(novData['dirt']) ?? 0;
    int varWashingnov = int.tryParse(novData['washing']) ?? 0;
    int varTbnov = int.tryParse(novData['tb']) ?? 0;
    int varNightnov = int.tryParse(novData['night']) ?? 0;
    int varDrivenov = int.tryParse(novData['drive']) ?? 0;
    int varCyclenov = int.tryParse(novData['cycle']) ?? 0;
    int varPcanov = int.tryParse(novData['pca']) ?? 0;
    int varNpsempnov = int.tryParse(novData['npsemp']) ?? 0;
    int varOthernov = int.tryParse('0') ?? 0;
    int varDaext1nov = int.tryParse(novData['daext1']) ?? 0;
    int varDaext2nov = int.tryParse(novData['daext2']) ?? 0;
    int varDaext3nov = int.tryParse(novData['daext3']) ?? 0;
    int varDaext4nov = int.tryParse(novData['daext4']) ?? 0;
    int varGrossnov = int.tryParse(novData['gross']) ?? 0;
    int varSalarynov = [
      varBpnov, varDanov, varHranov, varNpanov, varSplpaynov, varConvnov, varPgnov,
      varAnnualnov, varUniformnov, varNursingnov, varTanov, varDaontanov, varMedicalnov,
      varDirtnov, varWashingnov, varTbnov, varNightnov, varDrivenov, varCyclenov,
      varPcanov, varNpsempnov, varOthernov, varDaext1nov, varDaext2nov, varDaext3nov, varDaext4nov, varGrossnov,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxnov = int.tryParse(novData['incometax']) ?? 0;
    int varGisnov = int.tryParse(novData['gis']) ?? 0;
    int varGpfnov = int.tryParse(novData['gpf']) ?? 0;
    int varNpsnov = int.tryParse(novData['nps']) ?? 0;
    int varSlfnov = int.tryParse(novData['slf']) ?? 0;
    int varSocietynov = int.tryParse(novData['society']) ?? 0;
    int varRecoverynov = int.tryParse(novData['recovery']) ?? 0;
    int varWfnov = int.tryParse(novData['wf']) ?? 0;
    int varOther2nov = int.tryParse(novData['other']) ?? 0;
    int varDdext1nov = int.tryParse(novData['ddext1']) ?? 0;
    int varDdext2nov = int.tryParse(novData['ddext2']) ?? 0;
    int varDdext3nov = int.tryParse(novData['ddext3']) ?? 0;
    int varDdext4nov = int.tryParse(novData['ddext4']) ?? 0;
    int varTotaldednov = int.tryParse(novData['totalded']) ?? 0;
    int varNetsalarynov = int.tryParse(novData['netsalary']) ?? 0;



    // ============================= arrearqtr3 ==============================
    int varBparrearqtr3 = int.tryParse('0') ?? 0;
    int varDaarrearqtr3 = int.tryParse(arrearData['snda']) ?? 0;
    int varHraarrearqtr3 = int.tryParse(arrearData['snhra']) ?? 0;
    int varNpaarrearqtr3 = int.tryParse(arrearData['snnpa']) ?? 0;
    int varSplpayarrearqtr3 = int.tryParse('0') ?? 0;
    int varConvarrearqtr3 = int.tryParse('0') ?? 0;
    int varPgarrearqtr3 = int.tryParse('0') ?? 0;
    int varAnnualarrearqtr3 = int.tryParse('0')?? 0;
    int varUniforseptrearqtr3 = int.tryParse('0') ?? 0;
    int varNursingarrearqtr3 = int.tryParse('0') ?? 0;
    int varTaarrearqtr3 = int.tryParse('0') ?? 0;
    int varDaontaarrearqtr3 = int.tryParse(arrearData['sndaonta']) ?? 0;
    int varMedicalarrearqtr3 = int.tryParse('0') ?? 0;
    int varDirtarrearqtr3 = int.tryParse('0') ?? 0;
    int varWashingarrearqtr3 = int.tryParse('0') ?? 0;
    int varTbarrearqtr3 = int.tryParse('0') ?? 0;
    int varNightarrearqtr3 = int.tryParse('0') ?? 0;
    int varDrivearrearqtr3 = int.tryParse('0') ?? 0;
    int varCyclearrearqtr3 = int.tryParse('0') ?? 0;
    int varPcaarrearqtr3 = int.tryParse(arrearData['snpca']) ?? 0;
    int varNpsemparrearqtr3 = int.tryParse('0') ?? 0;
    int varOtherarrearqtr3 = int.tryParse(arrearData['snother']) ?? 0;
    int varDaext1arrearqtr3 = int.tryParse('0') ?? 0;
    int varDaext2arrearqtr3 = int.tryParse('0') ?? 0;
    int varDaext3arrearqtr3 = int.tryParse('0') ?? 0;
    int varDaext4arrearqtr3 = int.tryParse('0') ?? 0;
    int varGrossarrearqtr3 = int.tryParse('0') ?? 0;
    int varSalaryarrearqtr3 = [
      varBparrearqtr3, varDaarrearqtr3, varHraarrearqtr3, varNpaarrearqtr3, varSplpayarrearqtr3, varConvarrearqtr3, varPgarrearqtr3,
      varAnnualarrearqtr3, varUniforseptrearqtr3, varNursingarrearqtr3, varTaarrearqtr3, varDaontaarrearqtr3, varMedicalarrearqtr3,
      varDirtarrearqtr3, varWashingarrearqtr3, varTbarrearqtr3, varNightarrearqtr3, varDrivearrearqtr3, varCyclearrearqtr3,
      varPcaarrearqtr3, varNpsemparrearqtr3, varOtherarrearqtr3, varDaext1arrearqtr3, varDaext2arrearqtr3, varDaext3arrearqtr3, varDaext4arrearqtr3, varGrossarrearqtr3,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxarrearqtr3 = int.tryParse(arrearData['snext1']) ?? 0;
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
    int varUniformqtr3 = [varUniformsept, varUniformoct, varUniformnov, varUniforseptrearqtr3].fold(0, (sum, value) => sum + value);
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
    int varGrossqtr3 = [varGrosssept, varGrossoct, varGrossnov, varGrossarrearqtr3].fold(0, (sum, value) => sum + value);
    int varSalaryqtr3 = [varBpqtr3, varDaqtr3, varHraqtr3, varNpaqtr3, varSplpayqtr3, varConvqtr3, varPgqtr3,
      varAnnualqtr3, varUniformqtr3, varNursingqtr3, varTaqtr3, varDaontaqtr3, varMedicalqtr3,
      varDirtqtr3, varWashingqtr3, varTbqtr3, varNightqtr3, varDriveqtr3, varCycleqtr3,
      varPcaqtr3, varNpsempqtr3, varOtherqtr3, varDaext1qtr3, varDaext2qtr3, varDaext3qtr3, varDaext4qtr3, varGrossqtr3
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
    int varBpdec = int.tryParse(decData['bp']) ?? 0;
    int varDadec = int.tryParse(decData['da']) ?? 0;
    int varHradec = int.tryParse(decData['hra']) ?? 0;
    int varNpadec = int.tryParse(decData['npa']) ?? 0;
    int varSplpaydec = int.tryParse(decData['splpay']) ?? 0;
    int varConvdec = int.tryParse(decData['conv']) ?? 0;
    int varPgdec = int.tryParse(decData['pg']) ?? 0;
    int varAnnualdec = int.tryParse(decData['annual']) ?? 0;
    int varUniformdec = int.tryParse(decData['uniform']) ?? 0;
    int varNursingdec = int.tryParse(decData['nursing']) ?? 0;
    int varTadec = int.tryParse(decData['ta']) ?? 0;
    int varDaontadec = int.tryParse(decData['daonta']) ?? 0;
    int varMedicaldec = int.tryParse(decData['medical']) ?? 0;
    int varDirtdec = int.tryParse(decData['dirt']) ?? 0;
    int varWashingdec = int.tryParse(decData['washing']) ?? 0;
    int varTbdec = int.tryParse(decData['tb']) ?? 0;
    int varNightdec = int.tryParse(decData['night']) ?? 0;
    int varDrivedec = int.tryParse(decData['drive']) ?? 0;
    int varCycledec = int.tryParse(decData['cycle']) ?? 0;
    int varPcadec = int.tryParse(decData['pca']) ?? 0;
    int varNpsempdec = int.tryParse(decData['npsemp']) ?? 0;
    int varOtherdec = int.tryParse('0') ?? 0;
    int varDaext1dec = int.tryParse(decData['daext1']) ?? 0;
    int varDaext2dec = int.tryParse(decData['daext2']) ?? 0;
    int varDaext3dec = int.tryParse(decData['daext3']) ?? 0;
    int varDaext4dec = int.tryParse(decData['daext4']) ?? 0;
    int varGrossdec = int.tryParse(decData['gross']) ?? 0;
    int varSalarydec = [
      varBpdec, varDadec, varHradec, varNpadec, varSplpaydec, varConvdec, varPgdec,
      varAnnualdec, varUniformdec, varNursingdec, varTadec, varDaontadec, varMedicaldec,
      varDirtdec, varWashingdec, varTbdec, varNightdec, varDrivedec, varCycledec,
      varPcadec, varNpsempdec, varOtherdec, varDaext1dec, varDaext2dec, varDaext3dec, varDaext4dec, varGrossdec,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxdec = int.tryParse(decData['incometax']) ?? 0;
    int varGisdec = int.tryParse(decData['gis']) ?? 0;
    int varGpfdec = int.tryParse(decData['gpf']) ?? 0;
    int varNpsdec = int.tryParse(decData['nps']) ?? 0;
    int varSlfdec = int.tryParse(decData['slf']) ?? 0;
    int varSocietydec = int.tryParse(decData['society']) ?? 0;
    int varRecoverydec = int.tryParse(decData['recovery']) ?? 0;
    int varWfdec = int.tryParse(decData['wf']) ?? 0;
    int varOther2dec = int.tryParse(decData['other']) ?? 0;
    int varDdext1dec = int.tryParse(decData['ddext1']) ?? 0;
    int varDdext2dec = int.tryParse(decData['ddext2']) ?? 0;
    int varDdext3dec = int.tryParse(decData['ddext3']) ?? 0;
    int varDdext4dec = int.tryParse(decData['ddext4']) ?? 0;
    int varTotaldeddec = int.tryParse(decData['totalded']) ?? 0;
    int varNetsalarydec = int.tryParse(decData['netsalary']) ?? 0;

    // =============================== jan ===============================
    int varBpjan = int.tryParse(janData['bp']) ?? 0;
    int varDajan = int.tryParse(janData['da']) ?? 0;
    int varHrajan = int.tryParse(janData['hra']) ?? 0;
    int varNpajan = int.tryParse(janData['npa']) ?? 0;
    int varSplpayjan = int.tryParse(janData['splpay']) ?? 0;
    int varConvjan = int.tryParse(janData['conv']) ?? 0;
    int varPgjan = int.tryParse(janData['pg']) ?? 0;
    int varAnnualjan = int.tryParse(janData['annual']) ?? 0;
    int varUniformjan = int.tryParse(janData['uniform']) ?? 0;
    int varNursingjan = int.tryParse(janData['nursing']) ?? 0;
    int varTajan = int.tryParse(janData['ta']) ?? 0;
    int varDaontajan = int.tryParse(janData['daonta']) ?? 0;
    int varMedicaljan = int.tryParse(janData['medical']) ?? 0;
    int varDirtjan = int.tryParse(janData['dirt']) ?? 0;
    int varWashingjan = int.tryParse(janData['washing']) ?? 0;
    int varTbjan = int.tryParse(janData['tb']) ?? 0;
    int varNightjan = int.tryParse(janData['night']) ?? 0;
    int varDrivejan = int.tryParse(janData['drive']) ?? 0;
    int varCyclejan = int.tryParse(janData['cycle']) ?? 0;
    int varPcajan = int.tryParse(janData['pca']) ?? 0;
    int varNpsempjan = int.tryParse(janData['npsemp']) ?? 0;
    int varOtherjan = int.tryParse('0') ?? 0;
    int varDaext1jan = int.tryParse(janData['daext1']) ?? 0;
    int varDaext2jan = int.tryParse(janData['daext2']) ?? 0;
    int varDaext3jan = int.tryParse(janData['daext3']) ?? 0;
    int varDaext4jan = int.tryParse(janData['daext4']) ?? 0;
    int varGrossjan = int.tryParse(janData['gross']) ?? 0;
    int varSalaryjan = [
      varBpjan, varDajan, varHrajan, varNpajan, varSplpayjan, varConvjan, varPgjan,
      varAnnualjan, varUniformjan, varNursingjan, varTajan, varDaontajan, varMedicaljan,
      varDirtjan, varWashingjan, varTbjan, varNightjan, varDrivejan, varCyclejan,
      varPcajan, varNpsempjan, varOtherjan, varDaext1jan, varDaext2jan, varDaext3jan, varDaext4jan, varGrossjan,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxjan = int.tryParse(janData['incometax']) ?? 0;
    int varGisjan = int.tryParse(janData['gis']) ?? 0;
    int varGpfjan = int.tryParse(janData['gpf']) ?? 0;
    int varNpsjan = int.tryParse(janData['nps']) ?? 0;
    int varSlfjan = int.tryParse(janData['slf']) ?? 0;
    int varSocietyjan = int.tryParse(janData['society']) ?? 0;
    int varRecoveryjan = int.tryParse(janData['recovery']) ?? 0;
    int varWfjan = int.tryParse(janData['wf']) ?? 0;
    int varOther2jan = int.tryParse(janData['other']) ?? 0;
    int varDdext1jan = int.tryParse(janData['ddext1']) ?? 0;
    int varDdext2jan = int.tryParse(janData['ddext2']) ?? 0;
    int varDdext3jan = int.tryParse(janData['ddext3']) ?? 0;
    int varDdext4jan = int.tryParse(janData['ddext4']) ?? 0;
    int varTotaldedjan = int.tryParse(janData['totalded']) ?? 0;
    int varNetsalaryjan = int.tryParse(janData['netsalary']) ?? 0;

    // =============================== feb ===============================
    int varBpfeb = int.tryParse(febData['bp']) ?? 0;
    int varDafeb = int.tryParse(febData['da']) ?? 0;
    int varHrafeb = int.tryParse(febData['hra']) ?? 0;
    int varNpafeb = int.tryParse(febData['npa']) ?? 0;
    int varSplpayfeb = int.tryParse(febData['splpay']) ?? 0;
    int varConvfeb = int.tryParse(febData['conv']) ?? 0;
    int varPgfeb = int.tryParse(febData['pg']) ?? 0;
    int varAnnualfeb = int.tryParse(febData['annual']) ?? 0;
    int varUniformfeb = int.tryParse(febData['uniform']) ?? 0;
    int varNursingfeb = int.tryParse(febData['nursing']) ?? 0;
    int varTafeb = int.tryParse(febData['ta']) ?? 0;
    int varDaontafeb = int.tryParse(febData['daonta']) ?? 0;
    int varMedicalfeb = int.tryParse(febData['medical']) ?? 0;
    int varDirtfeb = int.tryParse(febData['dirt']) ?? 0;
    int varWashingfeb = int.tryParse(febData['washing']) ?? 0;
    int varTbfeb = int.tryParse(febData['tb']) ?? 0;
    int varNightfeb = int.tryParse(febData['night']) ?? 0;
    int varDrivefeb = int.tryParse(febData['drive']) ?? 0;
    int varCyclefeb = int.tryParse(febData['cycle']) ?? 0;
    int varPcafeb = int.tryParse(febData['pca']) ?? 0;
    int varNpsempfeb = int.tryParse(febData['npsemp']) ?? 0;
    int varOtherfeb = int.tryParse('0') ?? 0;
    int varDaext1feb = int.tryParse(febData['daext1']) ?? 0;
    int varDaext2feb = int.tryParse(febData['daext2']) ?? 0;
    int varDaext3feb = int.tryParse(febData['daext3']) ?? 0;
    int varDaext4feb = int.tryParse(febData['daext4']) ?? 0;
    int varGrossfeb = int.tryParse(febData['gross']) ?? 0;
    int varSalaryfeb = [
      varBpfeb, varDafeb, varHrafeb, varNpafeb, varSplpayfeb, varConvfeb, varPgfeb,
      varAnnualfeb, varUniformfeb, varNursingfeb, varTafeb, varDaontafeb, varMedicalfeb,
      varDirtfeb, varWashingfeb, varTbfeb, varNightfeb, varDrivefeb, varCyclefeb,
      varPcafeb, varNpsempfeb, varOtherfeb, varDaext1feb, varDaext2feb, varDaext3feb, varDaext4feb, varGrossfeb,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxfeb = int.tryParse(febData['incometax']) ?? 0;
    int varGisfeb = int.tryParse(febData['gis']) ?? 0;
    int varGpffeb = int.tryParse(febData['gpf']) ?? 0;
    int varNpsfeb = int.tryParse(febData['nps']) ?? 0;
    int varSlffeb = int.tryParse(febData['slf']) ?? 0;
    int varSocietyfeb = int.tryParse(febData['society']) ?? 0;
    int varRecoveryfeb = int.tryParse(febData['recovery']) ?? 0;
    int varWffeb = int.tryParse(febData['wf']) ?? 0;
    int varOther2feb = int.tryParse(febData['other']) ?? 0;
    int varDdext1feb = int.tryParse(febData['ddext1']) ?? 0;
    int varDdext2feb = int.tryParse(febData['ddext2']) ?? 0;
    int varDdext3feb = int.tryParse(febData['ddext3']) ?? 0;
    int varDdext4feb = int.tryParse(febData['ddext4']) ?? 0;
    int varTotaldedfeb = int.tryParse(febData['totalded']) ?? 0;
    int varNetsalaryfeb = int.tryParse(febData['netsalary']) ?? 0;



    // ============================= arrearqtr4 ==============================
    int varBparrearqtr4 = int.tryParse('0') ?? 0;
    int varDaarrearqtr4 = int.tryParse(arrearData['dfda']) ?? 0;
    int varHraarrearqtr4 = int.tryParse(arrearData['dfhra']) ?? 0;
    int varNpaarrearqtr4 = int.tryParse(arrearData['dfnpa']) ?? 0;
    int varSplpayarrearqtr4 = int.tryParse('0') ?? 0;
    int varConvarrearqtr4 = int.tryParse('0') ?? 0;
    int varPgarrearqtr4 = int.tryParse('0') ?? 0;
    int varAnnualarrearqtr4 = int.tryParse('0')?? 0;
    int varUnifordecrearqtr4 = int.tryParse('0') ?? 0;
    int varNursingarrearqtr4 = int.tryParse('0') ?? 0;
    int varTaarrearqtr4 = int.tryParse('0') ?? 0;
    int varDaontaarrearqtr4 = int.tryParse(arrearData['dfdaonta']) ?? 0;
    int varMedicalarrearqtr4 = int.tryParse('0') ?? 0;
    int varDirtarrearqtr4 = int.tryParse('0') ?? 0;
    int varWashingarrearqtr4 = int.tryParse('0') ?? 0;
    int varTbarrearqtr4 = int.tryParse('0') ?? 0;
    int varNightarrearqtr4 = int.tryParse('0') ?? 0;
    int varDrivearrearqtr4 = int.tryParse('0') ?? 0;
    int varCyclearrearqtr4 = int.tryParse('0') ?? 0;
    int varPcaarrearqtr4 = int.tryParse(arrearData['dfpca']) ?? 0;
    int varNpsemparrearqtr4 = int.tryParse('0') ?? 0;
    int varOtherarrearqtr4 = int.tryParse(arrearData['dfother']) ?? 0;
    int varDaext1arrearqtr4 = int.tryParse('0') ?? 0;
    int varDaext2arrearqtr4 = int.tryParse('0') ?? 0;
    int varDaext3arrearqtr4 = int.tryParse('0') ?? 0;
    int varDaext4arrearqtr4 = int.tryParse('0') ?? 0;
    int varGrossarrearqtr4 = int.tryParse('0') ?? 0;
    int varSalaryarrearqtr4 = [
      varBparrearqtr4, varDaarrearqtr4, varHraarrearqtr4, varNpaarrearqtr4, varSplpayarrearqtr4, varConvarrearqtr4, varPgarrearqtr4,
      varAnnualarrearqtr4, varUnifordecrearqtr4, varNursingarrearqtr4, varTaarrearqtr4, varDaontaarrearqtr4, varMedicalarrearqtr4,
      varDirtarrearqtr4, varWashingarrearqtr4, varTbarrearqtr4, varNightarrearqtr4, varDrivearrearqtr4, varCyclearrearqtr4,
      varPcaarrearqtr4, varNpsemparrearqtr4, varOtherarrearqtr4, varDaext1arrearqtr4, varDaext2arrearqtr4, varDaext3arrearqtr4, varDaext4arrearqtr4, varGrossarrearqtr4,
    ].fold(0, (sum, value) => sum + value);
    int varIncometaxarrearqtr4 = int.tryParse(arrearData['dfext1']) ?? 0;
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
    int varTution = [int.tryParse(arrearData['mmtution']) ?? 0, int.tryParse(arrearData['jatution']) ?? 0, int.tryParse(arrearData['sntution']) ?? 0, int.tryParse(arrearData['dftutiom']) ?? 0].fold(0, (sum, value) => sum + value);
    int varBonus = int.tryParse(arrearData['bonus']) ?? 0;

    // =============================== qtr4 ===============================
    int varBpqtr4 = [varBpdec, varBpjan, varBpfeb, varBparrearqtr4].fold(0, (sum, value) => sum + value);
    int varDaqtr4 = [varDadec, varDajan, varDafeb, varDaarrearqtr4].fold(0, (sum, value) => sum + value);
    int varHraqtr4 = [varHradec, varHrajan, varHrafeb, varHraarrearqtr4].fold(0, (sum, value) => sum + value);
    int varNpaqtr4 = [varNpadec, varNpajan, varNpafeb, varNpaarrearqtr4].fold(0, (sum, value) => sum + value);
    int varSplpayqtr4 = [varSplpaydec, varSplpayjan, varSplpayfeb, varSplpayarrearqtr4].fold(0, (sum, value) => sum + value);
    int varConvqtr4 = [varConvdec, varConvjan, varConvfeb, varConvarrearqtr4].fold(0, (sum, value) => sum + value);
    int varPgqtr4 = [varPgdec, varPgjan, varPgfeb, varPgarrearqtr4].fold(0, (sum, value) => sum + value);
    int varAnnualqtr4 = [varAnnualdec, varAnnualjan, varAnnualfeb, varAnnualarrearqtr4].fold(0, (sum, value) => sum + value);
    int varUniformqtr4 = [varUniformdec, varUniformjan, varUniformfeb, varUnifordecrearqtr4].fold(0, (sum, value) => sum + value);
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
    int varGrossqtr4 = [varGrossdec, varGrossjan, varGrossfeb, varGrossarrearqtr4].fold(0, (sum, value) => sum + value);
    int varSalaryqtr4 = [varBpqtr4, varDaqtr4, varHraqtr4, varNpaqtr4, varSplpayqtr4, varConvqtr4, varPgqtr4,
      varAnnualqtr4, varUniformqtr4, varNursingqtr4, varTaqtr4, varDaontaqtr4, varMedicalqtr4,
      varDirtqtr4, varWashingqtr4, varTbqtr4, varNightqtr4, varDriveqtr4, varCycleqtr4,
      varPcaqtr4, varNpsempqtr4, varOtherqtr4, varDaext1qtr4, varDaext2qtr4, varDaext3qtr4, varDaext4qtr4, varGrossqtr4
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

    // ============================================= gross ==========================================
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
    int varGrossgross = [varGrossqtr1, varGrossqtr2, varGrossqtr3, varGrossqtr4].fold(0, (sum, value) => sum + value);
    int varSalarygross = [varBpgross, varDagross, varHragross, varNpagross, varSplpaygross, varConvgross, varPggross,
      varAnnualgross, varUniformgross, varNursinggross, varTagross, varDaontagross, varMedicalgross,
      varDirtgross, varWashinggross, varTbgross, varNightgross, varDrivegross, varCyclegross,
      varPcagross, varNpsempgross, varOthergross, varDaext1gross, varDaext2gross, varDaext3gross, varDaext4gross, varGrossgross
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
    await updateitax(
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
        varGrossgross,
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
  }

  List<String> columns = ['B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
  int start = 0;
}

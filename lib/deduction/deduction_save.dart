import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';


class DeductionUpdatePage extends StatefulWidget {
  final String biometricId;
  final String name;
  final String hrr;
  final String oname;
  final String opan;
  final String po;
  final String ppf;
  final String lic;
  final String hlp;
  final String hli;
  final String atg;
  final String tution;
  final String cea;
  final String fd;
  final String nsc;
  final String atc;
  final String ulip;
  final String atccd1;
  final String gpf;
  final String gis;
  final String elss;
  final String ssy;
  final String atccdnps;
  final String atd;
  final String atdp;
  final String atdps;
  final String atu;
  final String ate;
  final String relief;
  final String atee;
  final String rpaid;
  final String convcontuniform;
  final String ma;
  final String other;
  final String atccd2;
  final String totalsav;
  final String maxsav;
  final String htype;
  final String rent;
  final String ext3;
  final String ext4;
  final String ext5;

  const DeductionUpdatePage({
    super.key,
    required this.biometricId,
    required this.name,
    required this.hrr,
    required this.oname,
    required this.opan,
    required this.po,
    required this.ppf,
    required this.lic,
    required this.hlp,
    required this.hli,
    required this.atg,
    required this.tution,
    required this.cea,
    required this.fd,
    required this.nsc,
    required this.atc,
    required this.ulip,
    required this.atccd1,
    required this.gpf,
    required this.gis,
    required this.elss,
    required this.ssy,
    required this.atccdnps,
    required this.atd,
    required this.atdp,
    required this.atdps,
    required this.atu,
    required this.ate,
    required this.relief,
    required this.atee,
    required this.rpaid,
    required this.convcontuniform,
    required this.ma,
    required this.other,
    required this.atccd2,
    required this.totalsav,
    required this.maxsav,
    required this.htype,
    required this.rent,
    required this.ext3,
    required this.ext4,
    required this.ext5,

  });
  @override
  State<DeductionUpdatePage> createState() => DeductionUpdatePageState();
}

class DeductionUpdatePageState extends State<DeductionUpdatePage> {
  // Text controllers for form inputs
  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();
  final hrrController = TextEditingController();
  final onameController = TextEditingController();
  final opanController = TextEditingController();
  final poController = TextEditingController();
  final ppfController = TextEditingController();
  final licController = TextEditingController();
  final hlpController = TextEditingController();
  final hliController = TextEditingController();
  final atgController = TextEditingController();
  final tutionController = TextEditingController();
  final ceaController = TextEditingController();
  final fdController = TextEditingController();
  final nscController = TextEditingController();
  final atcController = TextEditingController();
  final ulipController = TextEditingController();
  final atccd1Controller = TextEditingController();
  final gpfController = TextEditingController();
  final gisController = TextEditingController();
  final elssController = TextEditingController();
  final ssyController = TextEditingController();
  final atccdnpsController = TextEditingController();
  final atdController = TextEditingController();
  final atdpController = TextEditingController();
  final atdpsController = TextEditingController();
  final atuController = TextEditingController();
  final ateController = TextEditingController();
  final reliefController = TextEditingController();
  final ateeController = TextEditingController();
  final rpaidController = TextEditingController();
  final convcontuniformController = TextEditingController();
  final maController = TextEditingController();
  final otherController = TextEditingController();
  final atccd2Controller = TextEditingController();
  final totalsavController = TextEditingController();
  final maxsavController = TextEditingController();
  late String htypeController = 'SELF';
  final rentController = TextEditingController();
  final ext3Controller = TextEditingController();
  final ext4Controller = TextEditingController();
  final ext5Controller = TextEditingController();

  int gis = 0, gpf = 0, atccd1 = 0, atccd2 = 0, taxexem = 0;
  bool isCea = false;
  bool isLoading = true;
  bool shouldRefetch = true;
  bool isEnabled = true;
  String errorMessage = '';
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);
  final List<String> months = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    htypeController = widget.htype;
  }



  Future<void> _initializeData() async {
    await Future.wait(months.map((month) => fetchMonthData(month)));

    await fetchArrData();

    setState(() {
      convcontuniformController.text = taxexem.toString();
      atccd1Controller.text = atccd1.toString();
      gpfController.text = gpf.toString();
      gisController.text = gis.toString();
      atccd2Controller.text = atccd2.toString();
    });

    biometricIdController.text = widget.biometricId;
    nameController.text = widget.name;
    hrrController.text = widget.hrr;
    onameController.text = widget.oname;
    opanController.text = widget.opan;
    poController.text = widget.po;
    ppfController.text = widget.ppf;
    licController.text = widget.lic;
    hlpController.text = widget.hlp;
    hliController.text = widget.hli;
    atgController.text = widget.atg;
    tutionController.text = widget.tution;
    ceaController.text = widget.cea;
    fdController.text = widget.fd;
    nscController.text = widget.nsc;
    atcController.text = widget.atc;
    ulipController.text = widget.ulip;
    elssController.text = widget.elss;
    ssyController.text = widget.ssy;
    atccdnpsController.text = widget.atccdnps;
    atdController.text = widget.atd;
    atdpController.text = widget.atdp;
    atdpsController.text = widget.atdps;
    atuController.text = widget.atu;
    ateController.text = widget.ate;
    reliefController.text = widget.relief;
    ateeController.text = widget.atee;
    rpaidController.text = widget.rpaid;
    convcontuniformController.text = widget.convcontuniform;
    maController.text = widget.ma;
    otherController.text = widget.other;
    totalsavController.text = widget.totalsav;
    maxsavController.text = widget.maxsav;
    htypeController = widget.htype;
    rentController.text = widget.rent;
    ext3Controller.text = widget.ext3;
    ext4Controller.text = widget.ext4;
    ext5Controller.text = widget.ext5;

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    biometricIdController.dispose();
    nameController.dispose();
    hrrController.dispose();
    onameController.dispose();
    opanController.dispose();
    poController.dispose();
    ppfController.dispose();
    licController.dispose();
    hlpController.dispose();
    hliController.dispose();
    atgController.dispose();
    tutionController.dispose();
    ceaController.dispose();
    fdController.dispose();
    nscController.dispose();
    atcController.dispose();
    ulipController.dispose();
    atccd1Controller.dispose();
    gpfController.dispose();
    gisController.dispose();
    elssController.dispose();
    ssyController.dispose();
    atccdnpsController.dispose();
    atdController.dispose();
    atdpController.dispose();
    atdpsController.dispose();
    atuController.dispose();
    ateController.dispose();
    reliefController.dispose();
    ateeController.dispose();
    rpaidController.dispose();
    convcontuniformController.dispose();
    maController.dispose();
    otherController.dispose();
    atccd2Controller.dispose();
    totalsavController.dispose();
    maxsavController.dispose();
    // htypeController.dispose();
    rentController.dispose();
    ext3Controller.dispose();
    ext4Controller.dispose();
    ext5Controller.dispose();

    super.dispose();
  }

  Future<void> fetchMonthData(var month) async {
    try {
      DatabaseEvent event = await database.child(sharedData.userPlace).child('monthdata').child(month).child(widget.biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> monthData = snapshot.value as Map<dynamic, dynamic>;

        // Parse values with default 0 if parsing fails
        final nps = int.tryParse(monthData['nps'] ?? '0') ?? 0;
        final bp = int.tryParse(monthData['bp'] ?? '0') ?? 0;
        final da = int.tryParse(monthData['da'] ?? '0') ?? 0;
        final npa = int.tryParse(monthData['npa'] ?? '0') ?? 0;
        final gisValue = int.tryParse(monthData['gis'] ?? '0') ?? 0;
        final gpfValue = int.tryParse(monthData['gpf'] ?? '0') ?? 0;
        final drive = int.tryParse(monthData['drive'] ?? '0') ?? 0;
        final conv = int.tryParse(monthData['conv'] ?? '0') ?? 0;
        final uniform = int.tryParse(monthData['uniform'] ?? '0') ?? 0;

        // Update fields conditionally
        if (nps > 0) {
          atccd2 += ((bp + da + npa)*0.14).round();
        }

        gis += gisValue;
        gpf += gpfValue;
        atccd1 += nps;
        taxexem += drive + conv + uniform;

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


  Future<void> fetchArrData() async {
    try {
      DatabaseEvent event = await database.child(sharedData.userPlace).child('arrdata').child(widget.biometricId).once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> arrData = snapshot.value as Map<dynamic, dynamic>;
        // Parse the values once and check for null
        final mmtution = int.tryParse(arrData['mmtution'] ?? '0') ?? 0;
        final jatution = int.tryParse(arrData['jatution'] ?? '0') ?? 0;
        final sntution = int.tryParse(arrData['sntution'] ?? '0') ?? 0;
        final dftution = int.tryParse(arrData['dftution'] ?? '0') ?? 0;

        // Set isCea based on the sum of values
        isCea = (mmtution + jatution + sntution + dftution) > 0;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEDUCTION DATA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        leading: BackButton(onPressed: () {
          Navigator.pop(context, true);
        }),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), // Box border
                  borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  children: [
                    Text(
                      'INFO',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    _buildTextBox(label: "BIOMETRIC ID", controller: biometricIdController),
                    _buildTextBox(label: "NAME", controller: nameController),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), // Box border
                  borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  children: [
                    Text(
                      'SAVINGS (80C)',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    _buildTextBox(label: "POST OFFICE", controller: poController),
                    _buildTextBox(label: "PPF", controller: ppfController),
                    _buildTextBox(label: "LIC", controller: licController),
                    _buildTextBox(label: "HOUSE LOAN PRINCIPLE", controller: hlpController),
                    _buildTextBox(label: "FD", controller: fdController),
                    _buildTextBox(label: "NSC", controller: nscController),
                    _buildTextBox(label: "80C", controller: atcController),
                    _buildTextBox(label: "ULIP", controller: ulipController),
                    _buildTextBox(label: "80CCD(1)NPS", controller: atccd1Controller),
                    _buildTextBox(label: "GPF", controller: gpfController),
                    _buildTextBox(label: "GIS", controller: gisController),
                    _buildTextBox(label: "ELSS", controller: elssController),
                    _buildTextBox(label: "SUKANYA SAMRIDHI YOJNA", controller: ssyController),
                    _buildTextBox(label: "TUTION FEES RECIEPT", controller: tutionController),
                    _buildTextBox(label: "OTHER", controller: ext3Controller),
                    _buildTextBox(label: "MAX SAVINGS", controller: maxsavController),
                    _buildTextBox(label: "TOTAL SAVINGS", controller: totalsavController),

                  ],
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), // Box border
                  borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EXEMPTIONS',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10,width: 10,),

                    _buildTextBox(label: "80CCD(2) NPS EMPLOYER", controller: atccd2Controller),
                    //
                    // _buildDropdown('SELECT HOUSE TYPE', htypeController, ['','SELF','RENT']),
                    //
                    // _buildTextBox(label: "RENT RECIEVED", controller: rentController),
                    _buildTextBox(label: "HOUSING LOAN INETREST", controller: hliController),
                    _buildTextBox(label: "80G", controller: atgController),
                    _buildTextBox(label: "CEA", controller: ceaController),
                    _buildTextBox(label: "80CCD(1B)", controller: atccdnpsController),
                    _buildTextBox(label: "80D", controller: atdController),
                    _buildTextBox(label: "80DP", controller: atdpController),
                    _buildTextBox(label: "80DPS", controller: atdpsController),
                    _buildTextBox(label: "80U", controller: atuController),
                    _buildTextBox(label: "80E", controller: ateController),
                    _buildTextBox(label: "80EE", controller: ateeController),
                    _buildTextBox(label: "CONVEYANCE & CONTIGENCY & UNIFORM", controller: convcontuniformController),
                    _buildTextBox(label: "MEDICAL ALLOWANCE", controller: maController),
                    _buildTextBox(label: "OTHER", controller: otherController),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), // Box border
                  borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  children: [
                    Text(
                      'HRA REBATE',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    _buildTextBox(label: "HOUSE RENT RECIEPT", controller: hrrController),
                    _buildTextBox(label: "OWNER NAME", controller: onameController),
                    _buildTextBox(label: "OWNER PAN NUMBER", controller: opanController),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2), // Box border
                  borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  children: [

                    _buildTextBox(label: "RELIEF U/S 89", controller: reliefController),
                    // _buildTextBox(label: "RENT PAID 80GG", controller: rpaidController),

                    Visibility(visible: false,
                      child: Column(
                        children: [
                          _buildTextBox(label: "EXT 4", controller: ext4Controller),
                          _buildTextBox(label: "EXT 5", controller: ext5Controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),

          SizedBox(height: 10),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity, // Optional background for button area
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center buttons horizontally
                  children: [
                    // First button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Button color
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 8.0,
                        ),
                        child: const Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTextBox({
    required String label,
    required TextEditingController controller,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    // Define responsive padding, font size, and height
    double horizontalPadding = isWideScreen ? 32.0 : 16.0;
    double fontSize = isWideScreen ? 22.0 : 18.0; // Adjusted font size for label
    double contentPaddingVertical = isWideScreen ? 18.0 : 14.0; // Reduced vertical padding
    double contentPaddingHorizontal = 25.0; // Constant horizontal padding
    double fieldWidth = isWideScreen ? 500.0 : screenWidth - 32.0;

    bool isEnabled = controller == rentController ? htypeController != 'SELF' : true;
    _validateValue(controller, controller.text);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
        child: SizedBox(
          width: fieldWidth,
          child: TextField(
            enabled: isEnabled,
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: fontSize, // Responsive font size for the label
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: contentPaddingVertical,
                horizontal: contentPaddingHorizontal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blueGrey,
                  width: 3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blueAccent,
                  width: 4,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blueGrey,
                  width: 3,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 3,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.red[700]!,
                  width: 4,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: fontSize,  // Adjusted font size for input text
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            onChanged: (value) {
              setState(() {
                if (!_validateValue(controller, value)) {
                  controller.text = controller.text;
                  controller.selection = TextSelection.collapsed(offset: controller.text.length);
                }
              });
            },
          ),
        )
    );
  }

  // Widget _buildDropdown(String label, String? value, List<String> items) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   bool isWideScreen = screenWidth > 600;
  //
  //   // Define a fixed width for the dropdown (you can adjust this value)
  //   double dropdownWidth = isWideScreen ? 500.0 : screenWidth - 32.0;
  //
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: isWideScreen ? 32.0 : 16.0),
  //     child: SizedBox(
  //       width: dropdownWidth,  // Set the width of the dropdown container
  //       child: DropdownButtonFormField<String?>(
  //         value: value,
  //         onChanged: (String? newValue) {
  //           setState(() {
  //             htypeController = newValue!;
  //             // Recalculate isEnabled every time htypeController changes
  //             isEnabled = htypeController != 'SELF';
  //           });
  //         },
  //         decoration: InputDecoration(
  //           labelText: label,
  //           labelStyle: TextStyle(fontSize: isWideScreen ? 22.0 : 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
  //           filled: true,
  //           fillColor: Colors.white,
  //           contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.blueGrey, width: 3),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.blueAccent, width: 4),
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.blueGrey, width: 3),
  //           ),
  //         ),
  //         items: items.map<DropdownMenuItem<String?>>((String value) {
  //           return DropdownMenuItem<String?>(
  //             value: value,
  //             child: Text(value),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }


  bool _validateValue(TextEditingController controller, String value) {
    final parsedValue = int.tryParse(value);

    if (controller == hliController && parsedValue != null && parsedValue > 200000) {
      controller.text = '200000';
      _showDialog("Excess","Value exceeds 200000");
      return false;
    } else if (controller == atccdnpsController || controller == atdpController || controller == atdpsController) {
      if (parsedValue != null && parsedValue > 50000) {
        controller.text = '50000';
        _showDialog("Excess","Value exceeds 50000");
        return false;
      }
    } else if (controller == atdController && parsedValue != null && parsedValue > 25000) {
      controller.text = '25000';
      _showDialog("Excess","Value exceeds 25000");
      return false;
    }

    return true;
  }

  Future<void> _saveData() async {
    if (biometricIdController.text.isEmpty) {
      _showDialog("Error", "Biometric ID cannot be blank.");
      return;
    }

    // if (htypeController == 'RENT' && rentController.text.isEmpty){
    //   _showDialog("Error", "RENT CANNONT BE BLANK WHEN HOUSE TYPE IS RENT");
    //   return;
    // }

    if (ceaController.text == '0' && isCea) {
      _showDialog("Error", "CEA cannot be blank when tuition fees are present.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300), // limit width for web
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Saving...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );


    _calculateData();

    try {
      await bioRef.child('deddata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'hrr': hrrController.text,
        'oname': onameController.text,
        'opan': opanController.text,
        'po': poController.text,
        'ppf': ppfController.text,
        'lic': licController.text,
        'hlp': hlpController.text,
        'hli': hliController.text,
        '80g': atgController.text,
        'tution': tutionController.text,
        'cea': ceaController.text,
        'fd': fdController.text,
        'nsc': nscController.text,
        '80c': atcController.text,
        'ulip': ulipController.text,
        '80ccd1': atccd1Controller.text,
        'gpf': gpfController.text,
        'gis': gisController.text,
        'elss': elssController.text,
        'ssy': ssyController.text,
        '80ccdnps': atccdnpsController.text,
        '80d': atdController.text,
        '80dp': atdpController.text,
        '80dps': atdpsController.text,
        '80u': atuController.text,
        '80e': ateController.text,
        'relief': reliefController.text,
        '80ee': ateeController.text,
        'rpaid': rpaidController.text,
        'taexem': convcontuniformController.text,
        'ma': maController.text,
        'other': otherController.text,
        '80ccd2': atccd2Controller.text,
        'totalsav': totalsavController.text,
        'maxsav': maxsavController.text,
        'htype': htypeController,
        'rent': rentController.text,
        'ext3': ext3Controller.text,
        'ext4': ext4Controller.text,
        'ext5': ext5Controller.text,
      });

      if (mounted) {
        Navigator.pop(context);
        _showDialog("Success", "Employee data has been successfully updated.");
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        _showDialog("Error", "Failed to add data: \n$error");
      }
    }
  }

  void _calculateData(){
    final po = int.tryParse(poController.text) ?? 0;
    final ppf = int.tryParse(ppfController.text) ?? 0;
    final lic = int.tryParse(licController.text) ?? 0;
    final hlp = int.tryParse(hlpController.text) ?? 0;
    final tution = int.tryParse(tutionController.text) ?? 0;
    final fd = int.tryParse(fdController.text) ?? 0;
    final nsc = int.tryParse(nscController.text) ?? 0;
    final atc = int.tryParse(atcController.text) ?? 0;
    final ulip = int.tryParse(ulipController.text) ?? 0;
    final atccd1 = int.tryParse(atccd1Controller.text) ?? 0;
    final gpf = int.tryParse(gpfController.text) ?? 0;
    final gis = int.tryParse(gisController.text) ?? 0;
    final elss = int.tryParse(elssController.text) ?? 0;
    final ssy = int.tryParse(ssyController.text) ?? 0;
    final ext3 = int.tryParse(ext3Controller.text) ?? 0;
    final totalsav = po + ppf + lic + hlp + tution + fd + nsc + atc + ulip + atccd1 + gpf + gis + elss + ssy + ext3;
    totalsavController.text = totalsav.toString();
    if (totalsav > 150000){
      maxsavController.text = '150000';
    } else {
      maxsavController.text = totalsavController.text;
    }
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

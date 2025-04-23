import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';


class ArrearUpdatePage extends StatefulWidget {
  final String biometricId;
  final String name;
  final String mmda;
  final String mmhra;
  final String mmdaonta;
  final String mmpca;
  final String mmnpa;
  final String mmtution;
  final String mmother;
  final String mmext1;
  final String mmext2;
  final String mmext3;
  final String jada;
  final String jahra;
  final String jadaonta;
  final String japca;
  final String janpa;
  final String jatution;
  final String jaother;
  final String jaext1;
  final String jaext2;
  final String jaext3;
  final String snda;
  final String snhra;
  final String sndaonta;
  final String snpca;
  final String snnpa;
  final String sntution;
  final String snother;
  final String snext1;
  final String snext2;
  final String snext3;
  final String dfda;
  final String dfhra;
  final String dfdaonta;
  final String dfpca;
  final String dfnpa;
  final String dftution;
  final String dfother;
  final String dfext1;
  final String dfext2;
  final String dfext3;
  final String bonus;

  const ArrearUpdatePage({
    super.key,
    required this.biometricId,
    required this.name,
    required this.mmda,
    required this.mmhra,
    required this.mmdaonta,
    required this.mmpca,
    required this.mmnpa,
    required this.mmtution,
    required this.mmother,
    required this.mmext1,
    required this.mmext2,
    required this.mmext3,
    required this.jada,
    required this.jahra,
    required this.jadaonta,
    required this.japca,
    required this.janpa,
    required this.jatution,
    required this.jaother,
    required this.jaext1,
    required this.jaext2,
    required this.jaext3,
    required this.snda,
    required this.snhra,
    required this.sndaonta,
    required this.snpca,
    required this.snnpa,
    required this.sntution,
    required this.snother,
    required this.snext1,
    required this.snext2,
    required this.snext3,
    required this.dfda,
    required this.dfhra,
    required this.dfdaonta,
    required this.dfpca,
    required this.dfnpa,
    required this.dftution,
    required this.dfother,
    required this.dfext1,
    required this.dfext2,
    required this.dfext3,
    required this.bonus,

  });
  @override
  State<ArrearUpdatePage> createState() => ArrearUpdatePageState();
}

class ArrearUpdatePageState extends State<ArrearUpdatePage> {
  // Text controllers for form inputs
  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();
  final mmdaController = TextEditingController();
  final mmhraController = TextEditingController();
  final mmdaontaController = TextEditingController();
  final mmpcaController = TextEditingController();
  final mmnpaController = TextEditingController();
  final mmtutionController = TextEditingController();
  final mmotherController = TextEditingController();
  final mmext1Controller = TextEditingController();
  final mmext2Controller = TextEditingController();
  final mmext3Controller = TextEditingController();
  final jadaController = TextEditingController();
  final jahraController = TextEditingController();
  final jadaontaController = TextEditingController();
  final japcaController = TextEditingController();
  final janpaController = TextEditingController();
  final jatutionController = TextEditingController();
  final jaotherController = TextEditingController();
  final jaext1Controller = TextEditingController();
  final jaext2Controller = TextEditingController();
  final jaext3Controller = TextEditingController();
  final sndaController = TextEditingController();
  final snhraController = TextEditingController();
  final sndaontaController = TextEditingController();
  final snpcaController = TextEditingController();
  final snnpaController = TextEditingController();
  final sntutionController = TextEditingController();
  final snotherController = TextEditingController();
  final snext1Controller = TextEditingController();
  final snext2Controller = TextEditingController();
  final snext3Controller = TextEditingController();
  final dfdaController = TextEditingController();
  final dfhraController = TextEditingController();
  final dfdaontaController = TextEditingController();
  final dfpcaController = TextEditingController();
  final dfnpaController = TextEditingController();
  final dftutionController = TextEditingController();
  final dfotherController = TextEditingController();
  final dfext1Controller = TextEditingController();
  final dfext2Controller = TextEditingController();
  final dfext3Controller = TextEditingController();
  final bonusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    biometricIdController.text = widget.biometricId;
    nameController.text = widget.name;
    mmdaController.text = widget.mmda;
    mmhraController.text = widget.mmhra;
    mmdaontaController.text = widget.mmdaonta;
    mmpcaController.text = widget.mmpca;
    mmnpaController.text = widget.mmnpa;
    mmtutionController.text = widget.mmtution;
    mmotherController.text = widget.mmother;
    mmext1Controller.text = widget.mmext1;
    mmext2Controller.text = widget.mmext2;
    mmext3Controller.text = widget.mmext3;
    jadaController.text = widget.jada;
    jahraController.text = widget.jahra;
    jadaontaController.text = widget.jadaonta;
    japcaController.text = widget.japca;
    janpaController.text = widget.janpa;
    jatutionController.text = widget.jatution;
    jaotherController.text = widget.jaother;
    jaext1Controller.text = widget.jaext1;
    jaext2Controller.text = widget.jaext2;
    jaext3Controller.text = widget.jaext3;
    sndaController.text = widget.snda;
    snhraController.text = widget.snhra;
    sndaontaController.text = widget.sndaonta;
    snpcaController.text = widget.snpca;
    snnpaController.text = widget.snnpa;
    sntutionController.text = widget.sntution;
    snotherController.text = widget.snother;
    snext1Controller.text = widget.snext1;
    snext2Controller.text = widget.snext2;
    snext3Controller.text = widget.snext3;
    dfdaController.text = widget.dfda;
    dfhraController.text = widget.dfhra;
    dfdaontaController.text = widget.dfdaonta;
    dfpcaController.text = widget.dfpca;
    dfnpaController.text = widget.dfnpa;
    dftutionController.text = widget.dftution;
    dfotherController.text = widget.dfother;
    dfext1Controller.text = widget.dfext1;
    dfext2Controller.text = widget.dfext2;
    dfext3Controller.text = widget.dfext3;
    bonusController.text = widget.bonus;

  }

  List<String> month = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];

  // String? npschk = '0',gpfchk = '0';

  // Reference to Firebase Database
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);

  @override
  void dispose() {
    biometricIdController.dispose();
    nameController.dispose();
    mmdaController.dispose();
    mmhraController.dispose();
    mmdaontaController.dispose();
    mmpcaController.dispose();
    mmnpaController.dispose();
    mmtutionController.dispose();
    mmotherController.dispose();
    mmext1Controller.dispose();
    mmext2Controller.dispose();
    mmext3Controller.dispose();
    jadaController.dispose();
    jahraController.dispose();
    jadaontaController.dispose();
    japcaController.dispose();
    janpaController.dispose();
    jatutionController.dispose();
    jaotherController.dispose();
    jaext1Controller.dispose();
    jaext2Controller.dispose();
    jaext3Controller.dispose();
    sndaController.dispose();
    snhraController.dispose();
    sndaontaController.dispose();
    snpcaController.dispose();
    snnpaController.dispose();
    sntutionController.dispose();
    snotherController.dispose();
    snext1Controller.dispose();
    snext2Controller.dispose();
    snext3Controller.dispose();
    dfdaController.dispose();
    dfhraController.dispose();
    dfdaontaController.dispose();
    dfpcaController.dispose();
    dfnpaController.dispose();
    dftutionController.dispose();
    dfotherController.dispose();
    dfext1Controller.dispose();
    dfext2Controller.dispose();
    dfext3Controller.dispose();
    bonusController.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARREAR DATA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        leading: BackButton(onPressed: () {
          Navigator.pop(context, true);
        }),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
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
                      'MARCH TO MAY',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    _buildTextBox(label: "DA", controller: mmdaController),
                    _buildTextBox(label: "HRA", controller: mmhraController),
                    _buildTextBox(label: "DA ON TA", controller: mmdaontaController),
                    _buildTextBox(label: "PCA", controller: mmpcaController),
                    _buildTextBox(label: "NPA", controller: mmnpaController),
                    _buildTextBox(label: "TUTION", controller: mmtutionController),
                    _buildTextBox(label: "OTHER", controller: mmotherController),
                    _buildTextBox(label: "TAX", controller: mmext1Controller),
                    Visibility(visible: false,
                      child: Column(
                        children: [
                          _buildTextBox(label: "EXT2", controller: mmext2Controller),
                          _buildTextBox(label: "EXT3", controller: mmext3Controller),
                        ],
                      ),
                    ),
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
                      'JUNE TO AUGUST',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    _buildTextBox(label: "DA", controller: jadaController),
                    _buildTextBox(label: "HRA", controller: jahraController),
                    _buildTextBox(label: "DA ON TA", controller: jadaontaController),
                    _buildTextBox(label: "PCA", controller: japcaController),
                    _buildTextBox(label: "NPA", controller: janpaController),
                    _buildTextBox(label: "TUTION", controller: jatutionController),
                    _buildTextBox(label: "OTHER", controller: jaotherController),
                    _buildTextBox(label: "TAX", controller: jaext1Controller),

                    Visibility(visible: false,
                      child: Column(
                        children: [
                          _buildTextBox(label: "EXT2", controller: jaext2Controller),
                          _buildTextBox(label: "EXT3", controller: jaext3Controller),
                        ],
                      ),
                    ),
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
                      'SEPTEMBER TO NOVEMBER',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    _buildTextBox(label: "DA", controller: sndaController),
                    _buildTextBox(label: "HRA", controller: snhraController),
                    _buildTextBox(label: "DA ON TA", controller: sndaontaController),
                    _buildTextBox(label: "PCA", controller: snpcaController),
                    _buildTextBox(label: "NPA", controller: snnpaController),
                    _buildTextBox(label: "TUTION", controller: sntutionController),
                    _buildTextBox(label: "OTHER", controller: snotherController),
                    _buildTextBox(label: "TAX", controller: snext1Controller),
                    Visibility(visible: false,
                      child: Column(
                        children: [
                          _buildTextBox(label: "EXT3", controller: snext3Controller),
                        ],
                      ),
                    ),
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
                      'DECEMBER TO FEBRUARY',  // The label text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    _buildTextBox(label: "DA", controller: dfdaController),
                    _buildTextBox(label: "HRA", controller: dfhraController),
                    _buildTextBox(label: "DA ON TA", controller: dfdaontaController),
                    _buildTextBox(label: "PCA", controller: dfpcaController),
                    _buildTextBox(label: "NPA", controller: dfnpaController),
                    _buildTextBox(label: "TUTION", controller: dftutionController),
                    _buildTextBox(label: "OTHER", controller: dfotherController),
                    _buildTextBox(label: "TAX", controller: dfext1Controller),
                    Visibility(visible: false,
                      child: Column(
                        children: [
                          _buildTextBox(label: "EXT2", controller: dfext2Controller),
                          _buildTextBox(label: "EXT3", controller: dfext3Controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              _buildTextBox(label: "BONUS", controller: bonusController),

              SizedBox(height: 10),

              // _buildTextBox(label: "INCOME FROM OTHER SOURCES", controller: snext2Controller),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
      child: SizedBox(
        width: fieldWidth,
        child: TextField(
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
              controller.value = TextEditingValue(
                  text: value,
                  selection: TextSelection.collapsed(offset: value.length),
              );
            });
          },
        ),
      )
    );
  }

  Future<void> _saveData() async {
    if (biometricIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Biometric ID cannot be blank."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
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


    try {
      await bioRef.child('arrdata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'mmda': mmdaController.text,
        'mmhra': mmhraController.text,
        'mmdaonta': mmdaontaController.text,
        'mmpca': mmpcaController.text,
        'mmnpa': mmnpaController.text,
        'mmtution': mmtutionController.text,
        'mmother': mmotherController.text,
        'mmext1': mmext1Controller.text,
        'mmext2': mmext2Controller.text,
        'mmext3': mmext3Controller.text,
        'jada': jadaController.text,
        'jahra': jahraController.text,
        'jadaonta': jadaontaController.text,
        'japca': japcaController.text,
        'janpa': janpaController.text,
        'jatution': jatutionController.text,
        'jaother': jaotherController.text,
        'jaext1': jaext1Controller.text,
        'jaext2': jaext2Controller.text,
        'jaext3': jaext3Controller.text,
        'snda': sndaController.text,
        'snhra': snhraController.text,
        'sndaonta': sndaontaController.text,
        'snpca': snpcaController.text,
        'snnpa': snnpaController.text,
        'sntution': sntutionController.text,
        'snother': snotherController.text,
        'snext1': snext1Controller.text,
        'snext2': snext2Controller.text,
        'snext3': snext3Controller.text,
        'dfda': dfdaController.text,
        'dfhra': dfhraController.text,
        'dfdaonta': dfdaontaController.text,
        'dfpca': dfpcaController.text,
        'dfnpa': dfnpaController.text,
        'dftution': dftutionController.text,
        'dfother': dfotherController.text,
        'dfext1': dfext1Controller.text,
        'dfext2': dfext2Controller.text,
        'dfext3': dfext3Controller.text,
        'bonus': bonusController.text,

      });
      if(mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Employee data has been successfully updated."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
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

}

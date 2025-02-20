// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';


class MainAddPage extends StatefulWidget {
  const MainAddPage({super.key,});
  @override
  State<MainAddPage> createState() => _MainAddPageState();
}

class _MainAddPageState extends State<MainAddPage> {
  // Text controllers for form inputs
  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();
  final fhNameController = TextEditingController();
  final designationController = TextEditingController();
  final dobController = TextEditingController();
  final doaController = TextEditingController();
  final dortController = TextEditingController();
  String? groupController;
  String? categoryController;
  String? sexController;
  final addressController = TextEditingController();
  final aadhaarController = TextEditingController(text: '0');
  final mobileController = TextEditingController(text: '0');
  final accountController = TextEditingController(text: '0');
  final branchController = TextEditingController();
  final micrController = TextEditingController(text: '0');
  final ifscController = TextEditingController();
  final panController = TextEditingController();
  final payScaleController = TextEditingController();
  final levelController = TextEditingController();
  final gpfNoController = TextEditingController(text: '0');
  final npsNoController = TextEditingController(text: '0');
  final emailController = TextEditingController();
  final cycleNoController = TextEditingController();
  final voterIdController = TextEditingController();
  final dojoController = TextEditingController();
  final placeController = TextEditingController();
  String? bloodGroupController;
  final emergencyNoController = TextEditingController(text: '0');
  final nicEmailController = TextEditingController();
  final dornController = TextEditingController();
  final educationController = TextEditingController();
  String? empTypeController;
  final bankNameController = TextEditingController();

  String? npschk = '0',gpfchk = '0';

  // Reference to Firebase Database
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);

  List<String> month = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];

  @override
  void dispose() {
    biometricIdController.dispose();
    nameController.dispose();
    fhNameController.dispose();
    designationController.dispose();
    dobController.dispose();
    doaController.dispose();
    dortController.dispose();
    // groupController.dispose();
    // categoryController.dispose();
    // sexController.dispose();
    addressController.dispose();
    aadhaarController.dispose();
    mobileController.dispose();
    accountController.dispose();
    branchController.dispose();
    micrController.dispose();
    ifscController.dispose();
    panController.dispose();
    payScaleController.dispose();
    levelController.dispose();
    gpfNoController.dispose();
    npsNoController.dispose();
    emailController.dispose();
    cycleNoController.dispose();
    voterIdController.dispose();
    dojoController.dispose();
    placeController.dispose();
    // bloodGroupController.dispose();
    emergencyNoController.dispose();
    nicEmailController.dispose();
    dornController.dispose();
    educationController.dispose();
    // empTypeController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  void addData() async {
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
    }else if(gpfNoController.text != '0' && npsNoController.text != '0'){
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Both NPS and GPF cannot coexist"),
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
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // Loading spinner
              SizedBox(width: 20),
              Text("Adding...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
    _getGpfNps();
    try {
      await bioRef.child('maindata').child(biometricIdController.text.trim()).set({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'fhname': fhNameController.text,
        'designation': designationController.text,
        'dob': dobController.text,
        'doa': doaController.text,
        'dort': dortController.text,
        'group': groupController,
        'category': categoryController,
        'sex': sexController,
        'address': addressController.text,
        'aadhaarno': aadhaarController.text,
        'mobileno': mobileController.text,
        'accountno': accountController.text,
        'branch': branchController.text,
        'micrno': micrController.text,
        'ifsc': ifscController.text,
        'panno': panController.text,
        'payscale': payScaleController.text,
        'level': levelController.text,
        'gpfno': gpfNoController.text,
        'npsno': npsNoController.text,
        'emailid': emailController.text,
        'cycleno': cycleNoController.text,
        'voterid': voterIdController.text,
        'dojo': dojoController.text,
        'place': placeController.text,
        'bloodgrp': bloodGroupController,
        'emergencyno': emergencyNoController.text,
        'nicemailid': nicEmailController.text,
        'dorn': dornController.text,
        'education': educationController.text,
        'emptype': empTypeController,
        'bname': bankNameController.text,
      });
      for (String months in month){
        await bioRef.child('monthdata').child(months).child(biometricIdController.text.trim()).set({
          'biometricid': biometricIdController.text,
          'name': nameController.text,
          'designation': designationController.text,
          'bp': '0',
          'da': '0',
          'hra': '0',
          'npa': '0',
          'splpay': '0',
          'conv': '0',
          'pg': '0',
          'annual': '0',
          'uniform': '0',
          'nursing': '0',
          'ta': '0',
          'daonta': '0',
          'medical': '0',
          'dirt': '0',
          'washing': '0',
          'tb': '0',
          'night': '0',
          'drive': '0',
          'cycle': '0',
          'pca': '0',
          'daext1': '0',
          'daext2': '0',
          'daext3': '0',
          'daext4': '0',
          'gross': '0',
          'incometax': '0',
          'gis': '0',
          'gpf': '0',
          'nps': '0',
          'slf': '0',
          'society': '0',
          'recovery': '0',
          'wf': '0',
          'other': '0',
          'ddext1': '0',
          'ddext2': '0',
          'ddext3': '0',
          'ddext4': '0',
          'totalded': '0',
          'netsalary': '0',
          'dap': '1',
          'hrap': '1',
          'tap': '1',
          'npap': '0',
          'gpfchk': gpfchk,
          'npschk': npschk,
        });
      }
      await bioRef.child('arrdata').child(biometricIdController.text.trim()).set({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'mmda':'0',
        'mmhra':'0',
        'mmdaonta':'0',
        'mmpca':'0',
        'mmnpa':'0',
        'mmtution':'0',
        'mmother':'0',
        'mmext1':'0',
        'mmext2':'0',
        'mmext3':'0',
        'jada':'0',
        'jahra':'0',
        'jadaonta':'0',
        'japca':'0',
        'janpa':'0',
        'jatution':'0',
        'jaother':'0',
        'jaext1':'0',
        'jaext2':'0',
        'jaext3':'0',
        'snda':'0',
        'snhra':'0',
        'sndaonta':'0',
        'snpca':'0',
        'snnpa':'0',
        'sntution':'0',
        'snother':'0',
        'snext1':'0',
        'snext2':'0',
        'snext3':'0',
        'dfda':'0',
        'dfhra':'0',
        'dfdaonta':'0',
        'dfpca':'0',
        'dfnpa':'0',
        'dftution':'0',
        'dfother':'0',
        'dfext1':'0',
        'dfext2':'0',
        'dfext3':'0',
        'bonus':'0',
      });
      await bioRef.child('deddata').child(biometricIdController.text.trim()).set({
      'biometricid': biometricIdController.text,
      'name': nameController.text,
        'hrr':'0',
        'oname':'',
        'opan':'',
        'po':'0',
        'ppf':'0',
        'lic':'0',
        'hlp':'0',
        'hli':'0',
        '80g':'0',
        'tution':'0',
        'cea':'0',
        'fd':'0',
        'nsc':'0',
        '80c':'0',
        'ulip':'0',
        '80ccd1':'0',
        'gpf':'0',
        'gis':'0',
        'elss':'0',
        'ssy':'0',
        '80ccdnps':'0',
        '80d':'0',
        '80dp':'0',
        '80dps':'0',
        '80u':'0',
        '80e':'0',
        'relief':'0',
        '80ee':'0',
        'rpaid':'0',
        'taexem':'0',
        'other':'0',
        '80ccd2':'0',
        'totalsav':'0',
        'maxsav':'0',
        'htype':'SELF',
        'rent':'0',
        'ext3':'0',
        'ext4':'0',
        'ext5':'0',
      });

      if(mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: const Text("Success"),
                content: const Text(
                    "Employee data has been successfully added."),
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
                onPressed: () => {
                  Navigator.pop(ctx),
                  Navigator.pop(context),
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _getGpfNps(){
    if (empTypeController == 'REGULAR'){
      if (npsNoController.text.trim() == '0' && gpfNoController.text.trim() != '0'){
        npschk = '0';
        gpfchk = '1';
      } else if(gpfNoController.text.trim() == '0' && npsNoController.text.trim() != '0'){
        npschk = '1';
        gpfchk = '0';
      } else{
        npschk = '0';
        gpfchk = '0';
      }
    } else if(['CONTRACTUAL','DAILY WAGER'].contains(empTypeController)){
      npschk = '0';
      gpfchk = '0';
    } else {
      npschk = '0';
      gpfchk = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADD DATA',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 32.0 : 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 800.0 : screenWidth * 0.95, // Max width for large screens
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField("BIOMETRIC ID", biometricIdController),
                        _buildTextField("NAME", nameController),
                        _buildTextField("FATHER/HUSBAND NAME", fhNameController),
                        _buildTextField("DESIGNATION", designationController),
                        _buildDropdown("EMPLOYEE TYPE", empTypeController, ['','REGULAR', 'CONTRACTUAL', 'DAILY WAGER']),
                        _buildTextField("DATE OF BIRTH", dobController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildTextField("DATE OF APPOINTMENT", doaController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildTextField("DATE OF RETIREMENT", dornController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildDropdown("GROUP", groupController, ['','A', 'B', 'C', 'D']),
                        _buildDropdown("CATEGORY", categoryController, ['','GENERAL', 'SC', 'ST', 'OBC']),
                        _buildDropdown("SEX", sexController, ['','MALE', 'FEMALE', 'OTHER']),
                        _buildTextField("ADDRESS", addressController),
                        _buildTextField("AADHAAR NUMBER", aadhaarController),
                        _buildTextField("MOBILE NUMBER", mobileController, keyboardType: TextInputType.phone, inputFormatters: [MobileNumberFormatter()]),
                        _buildTextField("ACCOUNT NUMBER", accountController),
                        _buildTextField("BRANCH", branchController),
                        _buildTextField("BANK NAME", bankNameController),
                        _buildTextField("MICR NUMBER", micrController),
                        _buildTextField("IFSC", ifscController),
                        _buildTextField("PAN NUMBER", panController),
                        _buildTextField("PAY SCALE", payScaleController),
                        _buildTextField("LEVEL", levelController),
                        _buildTextField("GPF NUMBER", gpfNoController),
                        _buildTextField("NPS NUMBER", npsNoController),
                        _buildTextField("EMAIL ID", emailController),
                        _buildTextField("CYCLE NUMBER", cycleNoController),
                        _buildTextField("VOTER ID", voterIdController),
                        _buildTextField("DATE OF JOINING OFFICE", dojoController, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                        _buildTextField("PLACE OF DUTY", placeController),
                        _buildDropdown("BLOOD GROUP", bloodGroupController, ['','A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
                        _buildTextField("EMERGENCY NUMBER", emergencyNoController, keyboardType: TextInputType.phone, inputFormatters: [MobileNumberFormatter()]),
                        _buildTextField("NIC EMAIL ID", nicEmailController),
                        _buildTextField("DATE OF RESIGNATION", dornController, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                        _buildTextField("EDUCATION QUALIFICATION", educationController),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 16.0 : 8.0),
          child: SizedBox(
            width: isWideScreen ? 400.0 : double.infinity, // Set width for wide screens
            child: ElevatedButton(
              onPressed: addData,
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
                "ADD DATA",
                style: TextStyle(
                  fontSize: isWideScreen ? 20.0 : 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
          UpperCaseTextFormatter(),
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

  Widget _buildDropdown(String label, String? value, List<String> items) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: isWideScreen ? 32.0 : 16.0),
      child: DropdownButtonFormField<String?>(
        value: value,
        onChanged: (String? newValue) {
          setState(() {
            value = newValue;
          });
        },
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
        ),
        items: items.map<DropdownMenuItem<String?>>((String value) {
          return DropdownMenuItem<String?>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Remove any non-numeric characters
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Add dashes after the appropriate positions
    if (newText.length >= 3) {
      newText = '${newText.substring(0, 2)}-${newText.substring(2)}';
    }
    if (newText.length >= 6) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }

    // Ensure the text length does not exceed 10 (dd-mm-yyyy)
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class MobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

    if (newText.length > 10) {
      newText = newText.substring(0, 10); // Limit to 10 digits
    }

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 6) {
        formattedText += '-';
      }
      formattedText += newText[i];
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
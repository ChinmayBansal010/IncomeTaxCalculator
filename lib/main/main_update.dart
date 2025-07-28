import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';


class MainUpdatePage extends StatefulWidget {
  final String biometricId;
  final String name;
  final String fhName;
  final String designation;
  final String dob;
  final String doa;
  final String dort;
  final String group;
  final String category;
  final String mincrement;
  final String sex;
  final String address;
  final String aadhaar;
  final String mobile;
  final String account;
  final String branch;
  final String micr;
  final String ifsc;
  final String pan;
  final String payScale;
  final String level;
  final String gpfNo;
  final String npsNo;
  final String epfNo;
  final String esiNo;
  final String email;
  final String cycleNo;
  final String voterId;
  final String dojo;
  final String place;
  final String bloodGroup;
  final String emergencyNo;
  final String nicEmail;
  final String dorn;
  final String education;
  final String empType;
  final String bankName;

  const MainUpdatePage({
    super.key,
    required this.biometricId,
    required this.name,
    required this.fhName,
    required this.designation,
    required this.dob,
    required this.doa,
    required this.dort,
    required this.group,
    required this.category,
    required this. mincrement,
    required this.sex,
    required this.address,
    required this.aadhaar,
    required this.mobile,
    required this.account,
    required this.branch,
    required this.micr,
    required this.ifsc,
    required this.pan,
    required this.payScale,
    required this.level,
    required this.gpfNo,
    required this.npsNo,
    required this.epfNo,
    required this.esiNo,
    required this.email,
    required this.cycleNo,
    required this.voterId,
    required this.dojo,
    required this.place,
    required this.bloodGroup,
    required this.emergencyNo,
    required this.nicEmail,
    required this.dorn,
    required this.education,
    required this.empType,
    required this.bankName
  });
  @override
  State<MainUpdatePage> createState() => MainUpdatePageState();
}

class MainUpdatePageState extends State<MainUpdatePage> {
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
  String? mincrementController;
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
  final epfNoController = TextEditingController(text: '0');
  final esiNoController = TextEditingController(text: '0');
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

  @override
  void initState() {
    super.initState();
    biometricIdController.text = widget.biometricId;
    nameController.text = widget.name;
    fhNameController.text = widget.fhName;
    designationController.text = widget.designation;
    dobController.text = widget.dob;
    doaController.text = widget.doa;
    dortController.text = widget.dort;
    groupController = widget.group;
    categoryController = widget.category;
    mincrementController = widget.mincrement;
    sexController = widget.sex;
    addressController.text = widget.address;
    aadhaarController.text = widget.aadhaar;
    mobileController.text = widget.mobile;
    accountController.text = widget.account;
    branchController.text = widget.branch;
    micrController.text = widget.micr;
    ifscController.text = widget.ifsc;
    panController.text = widget.pan;
    payScaleController.text = widget.payScale;
    levelController.text = widget.level;
    gpfNoController.text = widget.gpfNo;
    npsNoController.text = widget.npsNo;
    epfNoController.text = widget.epfNo;
    esiNoController.text = widget.esiNo;
    emailController.text = widget.email;
    cycleNoController.text = widget.cycleNo;
    voterIdController.text = widget.voterId;
    dojoController.text = widget.dojo;
    placeController.text = widget.place;
    bloodGroupController = widget.bloodGroup;
    emergencyNoController.text = widget.emergencyNo;
    nicEmailController.text = widget.nicEmail;
    dornController.text = widget.dorn;
    educationController.text = widget.education;
    empTypeController = widget.empType;
    bankNameController.text = widget.bankName;
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
    fhNameController.dispose();
    designationController.dispose();
    dobController.dispose();
    doaController.dispose();
    dortController.dispose();
    // groupController.dispose();
    // categoryController.dispose();
    // mincrementController.dispose();
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
    epfNoController.dispose();
    esiNoController.dispose();
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

  void updateData() async {
    if (biometricIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
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
    } if (dobController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Date of Birth cannot be blank."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    } if(gpfNoController.text != '0' && npsNoController.text != '0'){
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
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 300,
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
      ),
    );

    try {
      await bioRef.child('maindata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'fhname': fhNameController.text,
        'designation': designationController.text,
        'dob': dobController.text,
        'doa': doaController.text,
        'dort': dortController.text,
        'group': groupController,
        'category': categoryController,
        'mincrement': mincrementController,
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
        'epfno': epfNoController.text,
        'esino': esiNoController.text,
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
      await Future.wait([
        for (String m in month) _getGpfNps(m),
      ]);


      await bioRef.child('arrdata').child(biometricIdController.text.trim()).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
      });
      await bioRef.child('deddata').child(biometricIdController.text.trim()).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
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

  void deleteData() async {
    if (biometricIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) =>
        AlertDialog(
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes, Delete"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if(mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (ctx) => Dialog(
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Loading spinner
                  SizedBox(width: 20),
                  Text("Deleting...", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      await bioRef.child('maindata').child(biometricIdController.text).remove();
      for (String months in month){
        await bioRef.child('monthdata').child(months).child(biometricIdController.text).remove();
      }
      await bioRef.child('arrdata').child(biometricIdController.text).remove();
      await bioRef.child('deddata').child(biometricIdController.text).remove();

      if(mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text(
                "Employee data has been successfully deleted."),
            actions: [
              TextButton(
                onPressed: () => {
                  Navigator.pop(ctx),
                  Navigator.pop(context)
                },
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

  Future<void> _getGpfNps(months) async{
    try{
      Map<String, String> updates = {};

      String gpf = gpfNoController.text.trim();
      String nps = npsNoController.text.trim();
      String epf = epfNoController.text.trim();
      String esi = esiNoController.text.trim();

      if (empTypeController == 'REGULAR') {
        if (nps == '0' && gpf != '0') {
          updates.addAll({
            'npschk': '0',
            'nps': '0',
            'gpfchk': '1',
          });
        } else if (gpf == '0' && nps != '0') {
          updates.addAll({
            'npschk': '1',
            'gpfchk': '0',
            'gpf': '0',
          });
        } else {
          updates.addAll({
            'npschk': '0',
            'nps': '0',
            'gpfchk': '0',
            'gpf': '0',
          });
        }
      } else if (['CONTRACTUAL', 'DAILY WAGER'].contains(empTypeController)) {
        updates.addAll({
          'npschk': '0',
          'nps': '0',
          'gpfchk': '0',
          'gpf': '0',
        });
      }
      if (epf != '0') {
        updates['epfchk'] = '1';
      }

      if (esi != '0') {
        updates['esichk'] = '1';
      }

      if (updates.isNotEmpty) {
        await bioRef.child('monthdata').child(months).child(biometricIdController.text).update(updates);
      }
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
                        _buildDropdown("EMPLOYEE TYPE", empTypeController, ['','REGULAR', 'CONTRACTUAL', 'DAILY WAGER'],
                              (newValue) {
                            setState(() {
                              empTypeController = newValue;
                            });
                          },
                        ),
                        _buildTextField("DATE OF BIRTH", dobController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildTextField("DATE OF APPOINTMENT", doaController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildTextField("DATE OF RETIREMENT", dortController, keyboardType: TextInputType.number,inputFormatters: [DateInputFormatter()]),
                        _buildDropdown("GROUP", groupController, ['','A', 'B', 'C', 'D'],
                              (newValue) {
                            setState(() {
                              groupController = newValue;
                            });
                          },
                        ),
                        _buildDropdown("CATEGORY", categoryController, ['','GENERAL', 'SC', 'ST', 'OBC'],
                              (newValue) {
                            setState(() {
                              categoryController = newValue;
                            });
                          },
                        ),
                        _buildDropdown("INCREMENT MONTH", mincrementController, ['','JULY', 'JANUARY',],
                              (newValue) {
                            setState(() {
                              mincrementController = newValue;
                            });
                          },
                        ),
                        _buildDropdown("SEX", sexController, ['','MALE', 'FEMALE', 'OTHER'],
                              (newValue) {
                            setState(() {
                              sexController = newValue;
                            });
                          },
                        ),
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
                        _buildTextField("EPF NUMBER", epfNoController),
                        _buildTextField("ESI NUMBER", esiNoController),
                        _buildTextField("EMAIL ID", emailController),
                        _buildTextField("CYCLE NUMBER", cycleNoController),
                        _buildTextField("VOTER ID", voterIdController),
                        _buildTextField("DATE OF JOINING OFFICE", dojoController, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                        _buildTextField("PLACE OF DUTY", placeController),
                        _buildDropdown("BLOOD GROUP", bloodGroupController, ['','A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                              (newValue) {
                            setState(() {
                              bloodGroupController = newValue;
                            });
                          },),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isWideScreen ? 250: 200,
                child: ElevatedButton(
                  onPressed: updateData,
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
                    "UPDATE DATA",
                    style: TextStyle(
                      fontSize: isWideScreen ? 20.0 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isWideScreen ? 16.0 : 8.0), // Space between buttons
              SizedBox(
                width: isWideScreen ? 250: 200,
                child: ElevatedButton(
                  onPressed: deleteData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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
                    "DELETE DATA",
                    style: TextStyle(
                      fontSize: isWideScreen ? 20.0 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildDropdown(String label, String? currentValue, List<String> items, void Function(String?) onChangedCallback) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: isWideScreen ? 32.0 : 16.0),
      child: DropdownButtonFormField<String?>(
        value: currentValue,
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
        onChanged: onChangedCallback,
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




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
    required this.mincrement,
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

class MainUpdatePageState extends State<MainUpdatePage> with SingleTickerProviderStateMixin {
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

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceController.forward();

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

  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);

  @override
  void dispose() {
    _entranceController.dispose();
    biometricIdController.dispose();
    nameController.dispose();
    fhNameController.dispose();
    designationController.dispose();
    dobController.dispose();
    doaController.dispose();
    dortController.dispose();
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
    emergencyNoController.dispose();
    nicEmailController.dispose();
    dornController.dispose();
    educationController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  void updateData() async {
    if (biometricIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Error"),
          content: const Text("Biometric ID cannot be blank."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
      return;
    }
    if (dobController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Error"),
          content: const Text("Date of Birth cannot be blank."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
      return;
    }
    if(gpfNoController.text != '0' && npsNoController.text != '0'){
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Error"),
          content: const Text("Both NPS and GPF cannot coexist"),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  strokeWidth: 3,
                ),
                SizedBox(width: 24),
                Text(
                  "Updating...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text("Success"),
              ],
            ),
            content: const Text(
              "Employee data has been successfully updated.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text("Error"),
              ],
            ),
            content: Text(
              "Failed to update data: \n$error",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Error"),
          content: const Text("Biometric ID cannot be blank."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text("Are you sure you want to completely remove this employee's data?", style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Yes, Delete", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if(mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                    strokeWidth: 3,
                  ),
                  SizedBox(width: 24),
                  Text(
                    "Deleting...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
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
      await bioRef.child('itfdata').child(biometricIdController.text).remove();
      await bioRef.child('itaxnew').child(biometricIdController.text).remove();
      await bioRef.child('itaxold').child(biometricIdController.text).remove();

      if(mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.delete_sweep_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text("Deleted"),
              ],
            ),
            content: const Text(
              "Employee data has been successfully deleted.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text("Error"),
              ],
            ),
            content: Text(
              "Failed to delete data: \n$error",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Error"),
            content: Text("Failed to update data: \n$error"),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
          ),
        );
      }
    }
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final delay = (index * 0.15).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -40,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Update Employee",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${widget.biometricId}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAnimatedSection(
                            0,
                            _buildSectionCard(
                              "Identity & Personal Information",
                              Icons.person_rounded,
                              [
                                AnimatedInputField(label: "BIOMETRIC ID", controller: biometricIdController, icon: Icons.fingerprint_rounded, readOnly: true),
                                AnimatedInputField(label: "NAME", controller: nameController, icon: Icons.person_outline_rounded),
                                AnimatedInputField(label: "FATHER/HUSBAND NAME", controller: fhNameController, icon: Icons.people_alt_rounded),
                                AnimatedInputField(label: "DATE OF BIRTH", controller: dobController, icon: Icons.cake_rounded, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                                AnimatedDropdownField(label: "BLOOD GROUP", currentValue: bloodGroupController, items: const ['', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], icon: Icons.bloodtype_rounded, onChanged: (v) => setState(() => bloodGroupController = v)),
                                AnimatedDropdownField(label: "SEX", currentValue: sexController, items: const ['', 'MALE', 'FEMALE', 'OTHER'], icon: Icons.wc_rounded, onChanged: (v) => setState(() => sexController = v)),
                                AnimatedInputField(label: "EDUCATION QUALIFICATION", controller: educationController, icon: Icons.school_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            1,
                            _buildSectionCard(
                              "Employment Details",
                              Icons.work_rounded,
                              [
                                AnimatedInputField(label: "DESIGNATION", controller: designationController, icon: Icons.badge_rounded),
                                AnimatedDropdownField(label: "EMPLOYEE TYPE", currentValue: empTypeController, items: const ['', 'REGULAR', 'CONTRACTUAL', 'DAILY WAGER'], icon: Icons.work_outline_rounded, onChanged: (v) => setState(() => empTypeController = v)),
                                AnimatedDropdownField(label: "GROUP", currentValue: groupController, items: const ['', 'A', 'B', 'C', 'D'], icon: Icons.group_work_rounded, onChanged: (v) => setState(() => groupController = v)),
                                AnimatedDropdownField(label: "CATEGORY", currentValue: categoryController, items: const ['', 'GENERAL', 'SC', 'ST', 'OBC'], icon: Icons.category_rounded, onChanged: (v) => setState(() => categoryController = v)),
                                AnimatedInputField(label: "DATE OF APPOINTMENT", controller: doaController, icon: Icons.event_available_rounded, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                                AnimatedInputField(label: "DATE OF RETIREMENT", controller: dortController, icon: Icons.event_busy_rounded, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                                AnimatedInputField(label: "DATE OF JOINING OFFICE", controller: dojoController, icon: Icons.login_rounded, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                                AnimatedInputField(label: "DATE OF RESIGNATION", controller: dornController, icon: Icons.logout_rounded, keyboardType: TextInputType.number, inputFormatters: [DateInputFormatter()]),
                                AnimatedInputField(label: "PLACE OF DUTY", controller: placeController, icon: Icons.place_rounded),
                                AnimatedInputField(label: "PAY SCALE", controller: payScaleController, icon: Icons.payments_rounded),
                                AnimatedInputField(label: "LEVEL", controller: levelController, icon: Icons.trending_up_rounded),
                                AnimatedDropdownField(label: "INCREMENT MONTH", currentValue: mincrementController, items: const ['', 'JULY', 'JANUARY'], icon: Icons.event_note_rounded, onChanged: (v) => setState(() => mincrementController = v)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            2,
                            _buildSectionCard(
                              "Contact & Address",
                              Icons.contact_phone_rounded,
                              [
                                AnimatedInputField(label: "MOBILE NUMBER", controller: mobileController, icon: Icons.phone_android_rounded, keyboardType: TextInputType.number, inputFormatters: [MobileNumberFormatter()]),
                                AnimatedInputField(label: "EMERGENCY NUMBER", controller: emergencyNoController, icon: Icons.emergency_rounded, keyboardType: TextInputType.number, inputFormatters: [MobileNumberFormatter()]),
                                AnimatedInputField(label: "EMAIL ID", controller: emailController, icon: Icons.email_rounded),
                                AnimatedInputField(label: "NIC EMAIL ID", controller: nicEmailController, icon: Icons.alternate_email_rounded),
                                AnimatedInputField(label: "ADDRESS", controller: addressController, icon: Icons.home_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            3,
                            _buildSectionCard(
                              "Bank & Financial Info",
                              Icons.account_balance_rounded,
                              [
                                AnimatedInputField(label: "BANK NAME", controller: bankNameController, icon: Icons.account_balance_rounded),
                                AnimatedInputField(label: "BRANCH", controller: branchController, icon: Icons.store_rounded),
                                AnimatedInputField(label: "ACCOUNT NUMBER", controller: accountController, icon: Icons.account_balance_wallet_rounded),
                                AnimatedInputField(label: "IFSC CODE", controller: ifscController, icon: Icons.account_tree_rounded),
                                AnimatedInputField(label: "MICR NUMBER", controller: micrController, icon: Icons.numbers_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            4,
                            _buildSectionCard(
                              "Identifications & Accounts",
                              Icons.assignment_ind_rounded,
                              [
                                AnimatedInputField(label: "AADHAAR NUMBER", controller: aadhaarController, icon: Icons.fingerprint_rounded),
                                AnimatedInputField(label: "PAN NUMBER", controller: panController, icon: Icons.credit_card_rounded),
                                AnimatedInputField(label: "VOTER ID", controller: voterIdController, icon: Icons.how_to_vote_rounded),
                                AnimatedInputField(label: "CYCLE NUMBER", controller: cycleNoController, icon: Icons.pedal_bike_rounded),
                                AnimatedInputField(label: "GPF NUMBER", controller: gpfNoController, icon: Icons.savings_rounded),
                                AnimatedInputField(label: "NPS NUMBER", controller: npsNoController, icon: Icons.account_balance_wallet_rounded),
                                AnimatedInputField(label: "EPF NUMBER", controller: epfNoController, icon: Icons.volunteer_activism_rounded),
                                AnimatedInputField(label: "ESI NUMBER", controller: esiNoController, icon: Icons.health_and_safety_rounded),
                              ],
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AnimatedActionButton(
                            label: "UPDATE DATA",
                            icon: Icons.update_rounded,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            onPressed: updateData,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnimatedActionButton(
                            label: "DELETE",
                            icon: Icons.delete_outline_rounded,
                            gradientColors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
                            onPressed: deleteData,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                double spacing = 20.0;
                double itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 24.0,
                  children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool readOnly;

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.readOnly = false,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered && !widget.readOnly ? -2.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (_isHovered && !widget.readOnly)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  ...widget.inputFormatters,
                ],
                controller: widget.controller,
                style: TextStyle(
                  color: widget.readOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: widget.readOnly ? FontWeight.w700 : FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.readOnly
                      ? const Color(0xFFE2E8F0).withValues(alpha: 0.5)
                      : (_isHovered ? Colors.white : const Color(0xFFF8FAFC)),
                  prefixIcon: Icon(
                    widget.icon,
                    color: widget.readOnly
                        ? const Color(0xFF94A3B8)
                        : (_isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _isHovered && !widget.readOnly ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: widget.readOnly ? const Color(0xFFE2E8F0) : const Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  if (widget.controller.text != value) {
                    final cursorPosition = widget.controller.selection;
                    widget.controller.value = TextEditingValue(
                      text: value,
                      selection: cursorPosition,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDropdownField extends StatefulWidget {
  final String label;
  final String? currentValue;
  final List<String> items;
  final IconData icon;
  final void Function(String?) onChanged;

  const AnimatedDropdownField({
    super.key,
    required this.label,
    required this.currentValue,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  State<AnimatedDropdownField> createState() => _AnimatedDropdownFieldState();
}

class _AnimatedDropdownFieldState extends State<AnimatedDropdownField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: DropdownButtonFormField<String?>(
                initialValue: widget.currentValue,
                icon: Icon(
                  Icons.unfold_more_rounded,
                  color: _isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                ),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _isHovered ? Colors.white : const Color(0xFFF8FAFC),
                  prefixIcon: Icon(
                    widget.icon,
                    color: _isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _isHovered ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
                items: widget.items.map<DropdownMenuItem<String?>>((String value) {
                  return DropdownMenuItem<String?>(
                    value: value,
                    child: Text(value.isEmpty ? "SELECT" : value),
                  );
                }).toList(),
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: _isHovered ? 0.4 : 0.2),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length >= 3) {
      newText = '${newText.substring(0, 2)}-${newText.substring(2)}';
    }
    if (newText.length >= 6) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }
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
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
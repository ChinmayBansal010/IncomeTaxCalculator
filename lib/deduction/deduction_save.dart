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

class DeductionUpdatePageState extends State<DeductionUpdatePage> with SingleTickerProviderStateMixin {
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

  late AnimationController _entranceController;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);
  final List<String> months = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
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
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
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

        final nps = int.tryParse(monthData['nps'] ?? '0') ?? 0;
        final bp = int.tryParse(monthData['bp'] ?? '0') ?? 0;
        final da = int.tryParse(monthData['da'] ?? '0') ?? 0;
        final npa = int.tryParse(monthData['npa'] ?? '0') ?? 0;
        final gisValue = int.tryParse(monthData['gis'] ?? '0') ?? 0;
        final gpfValue = int.tryParse(monthData['gpf'] ?? '0') ?? 0;
        final drive = int.tryParse(monthData['drive'] ?? '0') ?? 0;
        final conv = int.tryParse(monthData['conv'] ?? '0') ?? 0;
        final uniform = int.tryParse(monthData['uniform'] ?? '0') ?? 0;

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
            const SnackBar(content: Text("No Data Found")),
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
        final mmtution = int.tryParse(arrData['mmtution'] ?? '0') ?? 0;
        final jatution = int.tryParse(arrData['jatution'] ?? '0') ?? 0;
        final sntution = int.tryParse(arrData['sntution'] ?? '0') ?? 0;
        final dftution = int.tryParse(arrData['dftution'] ?? '0') ?? 0;

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

    if (ceaController.text == '0' && isCea) {
      _showDialog("Error", "CEA cannot be blank when tuition fees are present.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
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
                Text("Saving...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
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

  void _calculateData() {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            content: Text(content, style: const TextStyle(fontSize: 15, color: Color(0xFF475569))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      });
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
      backgroundColor: const Color(0xFFF1F5F9),
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
                              "Update Deductions",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${widget.biometricId} - ${widget.name}",
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
                      child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAnimatedSection(
                            0,
                            _buildSectionCard(
                              "Employee Identity",
                              Icons.badge_rounded,
                              [
                                _AnimatedInputField(label: "BIOMETRIC ID", controller: biometricIdController, icon: Icons.fingerprint_rounded, readOnly: true),
                                _AnimatedInputField(label: "NAME", controller: nameController, icon: Icons.person_outline_rounded, readOnly: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            1,
                            _buildSectionCard(
                              "Savings (Section 80C)",
                              Icons.savings_rounded,
                              [
                                _AnimatedInputField(label: "POST OFFICE", controller: poController, icon: Icons.local_post_office_rounded),
                                _AnimatedInputField(label: "PPF", controller: ppfController, icon: Icons.account_balance_rounded),
                                _AnimatedInputField(label: "LIC", controller: licController, icon: Icons.health_and_safety_rounded),
                                _AnimatedInputField(label: "HOUSE LOAN PRINCIPLE", controller: hlpController, icon: Icons.real_estate_agent_rounded),
                                _AnimatedInputField(label: "FD", controller: fdController, icon: Icons.account_balance_wallet_rounded),
                                _AnimatedInputField(label: "NSC", controller: nscController, icon: Icons.receipt_long_rounded),
                                _AnimatedInputField(label: "80C", controller: atcController, icon: Icons.article_rounded),
                                _AnimatedInputField(label: "ULIP", controller: ulipController, icon: Icons.trending_up_rounded),
                                _AnimatedInputField(label: "80CCD(1)NPS", controller: atccd1Controller, icon: Icons.shield_rounded),
                                _AnimatedInputField(label: "GPF", controller: gpfController, icon: Icons.monetization_on_rounded),
                                _AnimatedInputField(label: "GIS", controller: gisController, icon: Icons.security_rounded),
                                _AnimatedInputField(label: "ELSS", controller: elssController, icon: Icons.pie_chart_rounded),
                                _AnimatedInputField(label: "SUKANYA SAMRIDHI YOJNA", controller: ssyController, icon: Icons.girl_rounded),
                                _AnimatedInputField(label: "TUTION FEES RECIEPT", controller: tutionController, icon: Icons.school_rounded),
                                _AnimatedInputField(label: "OTHER", controller: ext3Controller, icon: Icons.more_horiz_rounded),
                                _AnimatedInputField(label: "MAX SAVINGS", controller: maxsavController, icon: Icons.verified_rounded, readOnly: true),
                                _AnimatedInputField(label: "TOTAL SAVINGS", controller: totalsavController, icon: Icons.functions_rounded, readOnly: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            2,
                            _buildSectionCard(
                              "Exemptions & Allowances",
                              Icons.receipt_long_rounded,
                              [
                                _AnimatedInputField(label: "80CCD(2) NPS EMPLOYER", controller: atccd2Controller, icon: Icons.business_rounded),
                                _AnimatedInputField(label: "HOUSING LOAN INTEREST", controller: hliController, icon: Icons.house_rounded, onChanged: (v) => _validateValue(hliController, v)),
                                _AnimatedInputField(label: "80G", controller: atgController, icon: Icons.volunteer_activism_rounded),
                                _AnimatedInputField(label: "CEA", controller: ceaController, icon: Icons.child_care_rounded),
                                _AnimatedInputField(label: "80CCD(1B)", controller: atccdnpsController, icon: Icons.account_balance_rounded, onChanged: (v) => _validateValue(atccdnpsController, v)),
                                _AnimatedInputField(label: "80D", controller: atdController, icon: Icons.health_and_safety_rounded, onChanged: (v) => _validateValue(atdController, v)),
                                _AnimatedInputField(label: "80DP", controller: atdpController, icon: Icons.medical_services_rounded, onChanged: (v) => _validateValue(atdpController, v)),
                                _AnimatedInputField(label: "80DPS", controller: atdpsController, icon: Icons.local_hospital_rounded, onChanged: (v) => _validateValue(atdpsController, v)),
                                _AnimatedInputField(label: "80U", controller: atuController, icon: Icons.accessible_rounded),
                                _AnimatedInputField(label: "80E", controller: ateController, icon: Icons.school_rounded),
                                _AnimatedInputField(label: "80EE", controller: ateeController, icon: Icons.home_rounded),
                                _AnimatedInputField(label: "CONVEYANCE & CONTIGENCY", controller: convcontuniformController, icon: Icons.directions_car_rounded),
                                _AnimatedInputField(label: "MEDICAL ALLOWANCE", controller: maController, icon: Icons.medication_rounded),
                                _AnimatedInputField(label: "OTHER", controller: otherController, icon: Icons.more_horiz_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            3,
                            _buildSectionCard(
                              "HRA Rebate Details",
                              Icons.home_work_rounded,
                              [
                                _AnimatedInputField(label: "HOUSE RENT RECIEPT", controller: hrrController, icon: Icons.receipt_rounded),
                                _AnimatedInputField(label: "OWNER NAME", controller: onameController, icon: Icons.person_rounded),
                                _AnimatedInputField(label: "OWNER PAN NUMBER", controller: opanController, icon: Icons.credit_card_rounded),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            4,
                            _buildSectionCard(
                              "Additional Relief",
                              Icons.add_circle_outline_rounded,
                              [
                                _AnimatedInputField(label: "RELIEF U/S 89", controller: reliefController, icon: Icons.verified_user_rounded),
                                Visibility(
                                  visible: false,
                                  child: Column(
                                    children: [
                                      _AnimatedInputField(label: "EXT 4", controller: ext4Controller, icon: Icons.extension_rounded),
                                      _AnimatedInputField(label: "EXT 5", controller: ext5Controller, icon: Icons.extension_rounded),
                                    ],
                                  ),
                                ),
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
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _AnimatedActionButton(
                      label: "SAVE DEDUCTION DATA",
                      icon: Icons.save_rounded,
                      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      onPressed: _saveData,
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
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
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
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                  ),
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
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

class _AnimatedInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final Function(String)? onChanged;

  const _AnimatedInputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  State<_AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<_AnimatedInputField> {
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
                  fontWeight: FontWeight.w800,
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
                controller: widget.controller,
                style: TextStyle(
                  color: widget.readOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: widget.readOnly ? FontWeight.w700 : FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.readOnly
                      ? const Color(0xFFF1F5F9)
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
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _isHovered && !widget.readOnly ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  } else {
                    if (widget.controller.text != value) {
                      final cursorPosition = widget.controller.selection;
                      widget.controller.value = TextEditingValue(
                        text: value,
                        selection: cursorPosition,
                      );
                    }
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
                    Icon(widget.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
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
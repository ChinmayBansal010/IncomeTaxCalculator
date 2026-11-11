import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';

class MonthDataPage extends StatefulWidget {
  final String biometricId;
  final String shortMonth;
  final String longMonth;

  const MonthDataPage({
    required this.biometricId,
    required this.shortMonth,
    required this.longMonth,
    super.key,
  });

  @override
  State<MonthDataPage> createState() => _MonthDataPageState();
}

class _MonthDataPageState extends State<MonthDataPage> with SingleTickerProviderStateMixin {
  final TextEditingController biometricidController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController daController = TextEditingController();
  final TextEditingController hraController = TextEditingController();
  final TextEditingController npaController = TextEditingController();
  final TextEditingController splpayController = TextEditingController();
  final TextEditingController convController = TextEditingController();
  final TextEditingController pgController = TextEditingController();
  final TextEditingController annualController = TextEditingController();
  final TextEditingController uniformController = TextEditingController();
  final TextEditingController nursingController = TextEditingController();
  final TextEditingController taController = TextEditingController();
  final TextEditingController daontaController = TextEditingController();
  final TextEditingController medicalController = TextEditingController();
  final TextEditingController dirtController = TextEditingController();
  final TextEditingController washingController = TextEditingController();
  final TextEditingController tbController = TextEditingController();
  final TextEditingController nightController = TextEditingController();
  final TextEditingController driveController = TextEditingController();
  final TextEditingController cycleController = TextEditingController();
  final TextEditingController pcaController = TextEditingController();
  final TextEditingController otController = TextEditingController();
  final TextEditingController daext1Controller = TextEditingController();
  final TextEditingController daext2Controller = TextEditingController();
  final TextEditingController daext3Controller = TextEditingController();
  final TextEditingController daext4Controller = TextEditingController();
  final TextEditingController grossController = TextEditingController();
  final TextEditingController incometaxController = TextEditingController();
  final TextEditingController gisController = TextEditingController();
  final TextEditingController gpfController = TextEditingController();
  final TextEditingController npsController = TextEditingController();
  final TextEditingController epfController = TextEditingController();
  final TextEditingController esiController = TextEditingController();
  final TextEditingController slfController = TextEditingController();
  final TextEditingController societyController = TextEditingController();
  final TextEditingController recoveryController = TextEditingController();
  final TextEditingController wfController = TextEditingController();
  final TextEditingController medController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController ddext1Controller = TextEditingController();
  final TextEditingController ddext2Controller = TextEditingController();
  final TextEditingController ddext3Controller = TextEditingController();
  final TextEditingController ddext4Controller = TextEditingController();
  final TextEditingController totaldedController = TextEditingController();
  final TextEditingController netsalaryController = TextEditingController();

  bool dachk = false;
  bool hrachk = false;
  bool tachk = false;
  bool npachk = false;
  bool gpfchk = false;
  bool npschk = false;
  bool epfchk = false;
  bool esichk = false;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> monthData = {};
  Map<dynamic, dynamic> percentageData = {};
  String mIncrement = '';
  String dRetierment = '';
  bool isLoading = true;
  String errorMessage = '';

  bool isGpfChecked = false;
  bool isNpsChecked = false;
  bool isEpfChecked = false;
  bool isEsiChecked = false;

  Set<String> manualOverrides = {};
  Set<String> dirtyManualFields = {};
  bool isBpChanged = false;
  bool isTaChanged = false;

  static const Map<String, String> _autoCalculatedFieldLabels = {
    'npa': 'NPA',
    'da': 'DA',
    'hra': 'HRA',
    'daonta': 'DA ON TA',
    'nps': 'NPS',
    'esi': 'ESI',
    'epf': 'EPF',
  };

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    fetchMonthData();
  }

  void _setInitialValue() {
    isBpChanged = false;
    isTaChanged = false;
    dirtyManualFields.clear();
    manualOverrides.clear();
    if (monthData['manual_overrides'] != null) {
      if (monthData['manual_overrides'] is Map) {
        (monthData['manual_overrides'] as Map).forEach((k, v) {
          if (v == true || v == '1' || v == 1 || v == 'true') {
            manualOverrides.add(k.toString());
          }
        });
      } else if (monthData['manual_overrides'] is List) {
        for (var item in (monthData['manual_overrides'] as List)) {
          manualOverrides.add(item.toString());
        }
      } else if (monthData['manual_overrides'] is String) {
        manualOverrides = (monthData['manual_overrides'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .toSet();
      }
    }
    biometricidController.text = monthData['biometricid']?.toString() ?? '';
    nameController.text = monthData['name']?.toString() ?? '';
    designationController.text = monthData['designation']?.toString() ?? '';
    bpController.text = monthData['bp']?.toString() ?? '';
    daController.text = monthData['da']?.toString() ?? '';
    hraController.text = monthData['hra']?.toString() ?? '';
    npaController.text = monthData['npa']?.toString() ?? '';
    splpayController.text = monthData['splpay']?.toString() ?? '';
    convController.text = monthData['conv']?.toString() ?? '';
    pgController.text = monthData['pg']?.toString() ?? '';
    annualController.text = monthData['annual']?.toString() ?? '';
    uniformController.text = monthData['uniform']?.toString() ?? '';
    nursingController.text = monthData['nursing']?.toString() ?? '';
    taController.text = monthData['ta']?.toString() ?? '';
    daontaController.text = monthData['daonta']?.toString() ?? '';
    medicalController.text = monthData['medical']?.toString() ?? '';
    dirtController.text = monthData['dirt']?.toString() ?? '';
    washingController.text = monthData['washing']?.toString() ?? '';
    tbController.text = monthData['tb']?.toString() ?? '';
    nightController.text = monthData['night']?.toString() ?? '';
    driveController.text = monthData['drive']?.toString() ?? '';
    cycleController.text = monthData['cycle']?.toString() ?? '';
    pcaController.text = monthData['pca']?.toString() ?? '';
    otController.text = (monthData['ot'] == null || monthData['ot'].toString().isEmpty) ? '0' : monthData['ot'].toString();
    daext1Controller.text = monthData['daext1']?.toString() ?? '';
    daext2Controller.text = monthData['daext2']?.toString() ?? '';
    daext3Controller.text = monthData['daext3']?.toString() ?? '';
    daext4Controller.text = monthData['daext4']?.toString() ?? '';
    grossController.text = monthData['gross']?.toString() ?? '';
    incometaxController.text = monthData['incometax']?.toString() ?? '';
    gisController.text = monthData['gis']?.toString() ?? '';
    gpfController.text = monthData['gpf']?.toString() ?? '';
    npsController.text = monthData['nps']?.toString() ?? '';
    epfController.text = monthData['epf']?.toString() ?? '';
    esiController.text = monthData['esi']?.toString() ?? '';
    slfController.text = monthData['slf']?.toString() ?? '';
    societyController.text = monthData['society']?.toString() ?? '';
    recoveryController.text = monthData['recovery']?.toString() ?? '';
    wfController.text = monthData['wf']?.toString() ?? '';
    medController.text = monthData['med'] ?? '';
    waterController.text = monthData['water']?.toString() ?? '';
    otherController.text = monthData['other']?.toString() ?? '';
    ddext1Controller.text = monthData['ddext1']?.toString() ?? '';
    ddext2Controller.text = monthData['ddext2']?.toString() ?? '';
    ddext3Controller.text = monthData['ddext3']?.toString() ?? '';
    ddext4Controller.text = monthData['ddext4']?.toString() ?? '';
    totaldedController.text = monthData['totalded']?.toString() ?? '';
    netsalaryController.text = monthData['netsalary']?.toString() ?? '';

    dachk = monthData['dap']?.toString() == '1';
    hrachk = monthData['hrap']?.toString() == '1';
    tachk = monthData['tap']?.toString() == '1';
    npachk = monthData['npap']?.toString() == '1';
    gpfchk = monthData['gpfchk']?.toString() == '1';
    npschk = monthData['npschk']?.toString() == '1';
    epfchk = monthData['epfchk']?.toString() == '1';
    esichk = monthData['esichk']?.toString() == '1';

    isGpfChecked = monthData['gpfchk']?.toString() == '1';
    isNpsChecked = monthData['npschk']?.toString() == '1';
    isEpfChecked = monthData['epfchk']?.toString() == '1';
    isEsiChecked = monthData['esichk']?.toString() == '1';
  }

  @override
  void dispose() {
    _entranceController.dispose();
    biometricidController.dispose();
    nameController.dispose();
    designationController.dispose();
    bpController.dispose();
    daController.dispose();
    hraController.dispose();
    npaController.dispose();
    splpayController.dispose();
    convController.dispose();
    pgController.dispose();
    annualController.dispose();
    uniformController.dispose();
    nursingController.dispose();
    taController.dispose();
    daontaController.dispose();
    medicalController.dispose();
    dirtController.dispose();
    washingController.dispose();
    tbController.dispose();
    nightController.dispose();
    driveController.dispose();
    cycleController.dispose();
    pcaController.dispose();
    otController.dispose();
    daext1Controller.dispose();
    daext2Controller.dispose();
    daext3Controller.dispose();
    daext4Controller.dispose();
    grossController.dispose();
    incometaxController.dispose();
    gisController.dispose();
    gpfController.dispose();
    npsController.dispose();
    epfController.dispose();
    esiController.dispose();
    slfController.dispose();
    societyController.dispose();
    recoveryController.dispose();
    wfController.dispose();
    medController.dispose();
    waterController.dispose();
    otherController.dispose();
    ddext1Controller.dispose();
    ddext2Controller.dispose();
    ddext3Controller.dispose();
    ddext4Controller.dispose();
    totaldedController.dispose();
    netsalaryController.dispose();
    super.dispose();
  }

  Future<void> fetchMonthData() async {
    try {
      DatabaseReference monthRef = _dbRef
          .child(sharedData.userPlace)
          .child('monthdata')
          .child(widget.shortMonth)
          .child(widget.biometricId);
      DatabaseEvent event = await monthRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        setState(() {
          monthData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
          _setInitialValue();
        });
        _entranceController.forward();
      } else {
        setState(() {
          errorMessage = 'No data available for ${widget.shortMonth}';
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

  Future<void> fetchIncrement() async {
    try {
      DatabaseReference incrementRef = _dbRef
          .child(sharedData.userPlace)
          .child('maindata')
          .child(widget.biometricId)
          .child('mincrement');
      DatabaseEvent event = await incrementRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        setState(() {
          mIncrement = snapshot.value.toString();
          isLoading = false;
        });
      } else {}
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchRetierment() async {
    try {
      DatabaseReference retirementRef = _dbRef
          .child(sharedData.userPlace)
          .child('maindata')
          .child(widget.biometricId)
          .child('dort');
      DatabaseEvent event = await retirementRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        setState(() {
          dRetierment = snapshot.value.toString();
          isLoading = false;
        });
      } else {}
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final delay = (index * 0.1).clamp(0.0, 1.0);
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children, {bool isGrid = true, int? forceCrossAxisCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.06),
                blurRadius: isMobile ? 10 : 20,
                offset: Offset(0, isMobile ? 4 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 24,
                  vertical: isMobile ? 10 : 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobile ? 14 : 22),
                    topRight: Radius.circular(isMobile ? 14 : 22),
                  ),
                  border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                        border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                      ),
                      child: Icon(icon, color: const Color(0xFF2563EB), size: isMobile ? 18 : 22),
                    ),
                    SizedBox(width: isMobile ? 10 : 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 10 : 24),
                child: isGrid
                    ? LayoutBuilder(
                  builder: (context, innerConstraints) {
                    int crossAxisCount = forceCrossAxisCount ?? (innerConstraints.maxWidth > 800 ? 3 : 2);
                    double spacing = isMobile ? 8.0 : 20.0;
                    double runSpacing = isMobile ? 10.0 : 24.0;
                    double itemWidth = (innerConstraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: runSpacing,
                      children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
                    );
                  },
                )
                    : Wrap(
                  spacing: isMobile ? 8.0 : 16.0,
                  runSpacing: isMobile ? 8.0 : 16.0,
                  children: children,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleCard(String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: value ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: value ? [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // This keeps the card width matching its content
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF2563EB) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: value ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: value ? const Color(0xFF1E3A8A) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required ValueChanged<String> onFieldChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: isMobile ? 12 : 21),
                Padding(
                  padding: EdgeInsets.only(
                    top: isMobile ? 8.0 : 16.0,
                    right: isMobile ? 4.0 : 12.0,
                  ),
                  child: SizedBox(
                    width: isMobile ? 18 : 24,
                    height: isMobile ? 18 : 24,
                    child: Checkbox(
                      value: isChecked,
                      activeColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 4 : 6)),
                      side: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: AnimatedInputField(
                label: label,
                controller: controller,
                icon: icon,
                keyboardType: TextInputType.number,
                enabled: isChecked,
                onChanged: onFieldChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onFieldChanged(String key, String value) {
    setState(() {
      monthData[key] = value;
    });
  }

  void _onAutoCalculatedFieldChanged(String key, String value) {
    setState(() {
      monthData[key] = value;
      dirtyManualFields.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      )
          : Stack(
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
                            Text(
                              "${widget.longMonth.toUpperCase()} DATA",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${widget.biometricId} - ${monthData['name'] ?? ''}",
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
                              "Employee Information",
                              Icons.badge_rounded,
                              [
                                AnimatedInputField(
                                  label: "BIOMETRIC ID",
                                  controller: biometricidController,
                                  icon: Icons.fingerprint_rounded,
                                  readOnly: true, // Field Disabled
                                ),
                                AnimatedInputField(
                                  label: "NAME",
                                  controller: nameController,
                                  icon: Icons.person_outline_rounded,
                                  readOnly: true, // Field Disabled
                                ),
                                AnimatedInputField(
                                  label: "DESIGNATION",
                                  controller: designationController,
                                  icon: Icons.work_outline_rounded,
                                  readOnly: true, // Field Disabled
                                ),
                              ],
                              forceCrossAxisCount: 1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            1,
                            _buildSectionCard(
                              "Percentage Variables",
                              Icons.percent_rounded,
                              [
                                _buildToggleCard("DA", dachk, (val) {
                                  setState(() {
                                    dachk = val;
                                    monthData['dap'] = val ? '1' : '0';
                                    if (!val) manualOverrides.remove('da');
                                  });
                                }),
                                _buildToggleCard("HRA", hrachk, (val) {
                                  setState(() {
                                    hrachk = val;
                                    monthData['hrap'] = val ? '1' : '0';
                                    if (!val) manualOverrides.remove('hra');
                                  });
                                }),
                                _buildToggleCard("TA", tachk, (val) {
                                  setState(() {
                                    tachk = val;
                                    monthData['tap'] = val ? '1' : '0';
                                    if (!val) manualOverrides.remove('daonta');
                                  });
                                }),
                                _buildToggleCard("NPA", npachk, (val) {
                                  setState(() {
                                    npachk = val;
                                    monthData['npap'] = val ? '1' : '0';
                                    if (!val) manualOverrides.remove('npa');
                                  });
                                }),
                              ],
                              isGrid: false, // Forces the Wrap layout to shrink toggles
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            2,
                            _buildSectionCard(
                              "Details of Allowance",
                              Icons.account_balance_wallet_rounded,
                              [
                                AnimatedInputField(label: "BP", controller: bpController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) { _onFieldChanged('bp', val); isBpChanged = true; }),
                                AnimatedInputField(label: "DA", controller: daController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onAutoCalculatedFieldChanged('da', val)),
                                AnimatedInputField(label: "HRA", controller: hraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onAutoCalculatedFieldChanged('hra', val)),
                                AnimatedInputField(label: "NPA", controller: npaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onAutoCalculatedFieldChanged('npa', val)),
                                AnimatedInputField(label: "SPECIAL PAY", controller: splpayController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('splpay', val)),
                                AnimatedInputField(label: "CONVEYANCE", controller: convController, icon: Icons.directions_car_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('conv', val)),
                                AnimatedInputField(label: "PG", controller: pgController, icon: Icons.school_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('pg', val)),
                                AnimatedInputField(label: "ANNUAL", controller: annualController, icon: Icons.event_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('annual', val)),
                                AnimatedInputField(label: "UNIFORM", controller: uniformController, icon: Icons.checkroom_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('uniform', val)),
                                AnimatedInputField(label: "NURSING", controller: nursingController, icon: Icons.local_hospital_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('nursing', val)),
                                AnimatedInputField(label: "TA", controller: taController, icon: Icons.flight_takeoff_rounded, keyboardType: TextInputType.number, onChanged: (val) { _onFieldChanged('ta', val); isTaChanged = true; }),
                                AnimatedInputField(label: "DA ON TA", controller: daontaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onAutoCalculatedFieldChanged('daonta', val)),
                                AnimatedInputField(label: "MEDICAL", controller: medicalController, icon: Icons.medical_services_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('medical', val)),
                                AnimatedInputField(label: "DIRT", controller: dirtController, icon: Icons.cleaning_services_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('dirt', val)),
                                AnimatedInputField(label: "WASHING", controller: washingController, icon: Icons.local_laundry_service_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('washing', val)),
                                AnimatedInputField(label: "TB", controller: tbController, icon: Icons.sick_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('tb', val)),
                                AnimatedInputField(label: "NIGHT", controller: nightController, icon: Icons.nights_stay_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('night', val)),
                                AnimatedInputField(label: "CONTINGENCY", controller: driveController, icon: Icons.warning_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('drive', val)),
                                AnimatedInputField(label: "CYCLE", controller: cycleController, icon: Icons.pedal_bike_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('cycle', val)),
                                AnimatedInputField(label: "PCA", controller: pcaController, icon: Icons.computer_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('pca', val)),
                                AnimatedInputField(label: "OT", controller: otController, icon: Icons.computer_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('ot', val)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            3,
                            _buildSectionCard(
                              "Gross Summary",
                              Icons.payments_rounded,
                              [
                                AnimatedInputField(
                                  label: "GROSS SALARY",
                                  controller: grossController,
                                  icon: Icons.account_balance_rounded,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            4,
                            _buildSectionCard(
                              "Details of Deduction",
                              Icons.money_off_rounded,
                              [
                                AnimatedInputField(label: "INCOME TAX", controller: incometaxController, icon: Icons.request_quote_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('incometax', val)),
                                AnimatedInputField(label: "GIS", controller: gisController, icon: Icons.security_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('gis', val)),
                                AnimatedInputField(label: "SLF", controller: slfController, icon: Icons.savings_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('slf', val)),
                                AnimatedInputField(label: "SOCIETY", controller: societyController, icon: Icons.groups_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('society', val)),
                                AnimatedInputField(label: "RECOVERY", controller: recoveryController, icon: Icons.restore_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('recovery', val)),
                                AnimatedInputField(label: "WIDOW WELFARE FUND", controller: wfController, icon: Icons.volunteer_activism_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('wf', val)),
                                AnimatedInputField(label: "MCD-EHS", controller: medController, icon: Icons.health_and_safety_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('med', val)),
                                AnimatedInputField(label: "WATER CHARGES", controller: waterController, icon: Icons.water_drop_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('water', val)),
                                AnimatedInputField(label: "OTHER", controller: otherController, icon: Icons.more_horiz_rounded, keyboardType: TextInputType.number, onChanged: (val) => _onFieldChanged('other', val)),
                                _buildCheckboxInputField(
                                  label: "GPF",
                                  controller: gpfController,
                                  icon: Icons.savings_rounded,
                                  isChecked: gpfchk,
                                  onChanged: (val) {
                                    setState(() {
                                      gpfchk = val!;
                                      isGpfChecked = val;
                                      gpfController.text = val ? monthData['gpf'] ?? '0' : '0';
                                      monthData['gpfchk'] = val ? '1' : '0';
                                    });
                                  },
                                  onFieldChanged: (val) => _onFieldChanged('gpf', val),
                                ),
                                _buildCheckboxInputField(
                                  label: "NPS",
                                  controller: npsController,
                                  icon: Icons.account_balance_rounded,
                                  isChecked: npschk,
                                  onChanged: (val) {
                                    setState(() {
                                      npschk = val!;
                                      isNpsChecked = val;
                                      npsController.text = val ? monthData['nps'] ?? '0' : '0';
                                      monthData['npschk'] = val ? '1' : '0';
                                      if (!val) {
                                        manualOverrides.remove('nps');
                                        dirtyManualFields.remove('nps');
                                      }
                                    });
                                  },
                                  onFieldChanged: (val) => _onAutoCalculatedFieldChanged('nps', val),
                                ),
                                _buildCheckboxInputField(
                                  label: "EPF",
                                  controller: epfController,
                                  icon: Icons.account_balance_wallet_rounded,
                                  isChecked: epfchk,
                                  onChanged: (val) {
                                    setState(() {
                                      epfchk = val!;
                                      isEpfChecked = val;
                                      epfController.text = val ? monthData['epf'] ?? '0' : '0';
                                      monthData['epfchk'] = val ? '1' : '0';
                                      if (!val) {
                                        manualOverrides.remove('epf');
                                        dirtyManualFields.remove('epf');
                                      }
                                    });
                                  },
                                  onFieldChanged: (val) => _onAutoCalculatedFieldChanged('epf', val),
                                ),
                                _buildCheckboxInputField(
                                  label: "ESI",
                                  controller: esiController,
                                  icon: Icons.medical_information_rounded,
                                  isChecked: esichk,
                                  onChanged: (val) {
                                    setState(() {
                                      esichk = val!;
                                      isEsiChecked = val;
                                      esiController.text = val ? monthData['esi'] ?? '0' : '0';
                                      monthData['esichk'] = val ? '1' : '0';
                                      if (!val) {
                                        manualOverrides.remove('esi');
                                        dirtyManualFields.remove('esi');
                                      }
                                    });
                                  },
                                  onFieldChanged: (val) => _onAutoCalculatedFieldChanged('esi', val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            5,
                            _buildSectionCard(
                              "Final Calculation",
                              Icons.calculate_rounded,
                              [
                                AnimatedInputField(
                                  label: "TOTAL DEDUCTIONS",
                                  controller: totaldedController,
                                  icon: Icons.remove_circle_outline_rounded,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                ),
                                AnimatedInputField(
                                  label: "NET SALARY",
                                  controller: netsalaryController,
                                  icon: Icons.account_balance_wallet_rounded,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
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
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AnimatedActionButton(
                            label: "CALCULATE",
                            icon: Icons.calculate_rounded,
                            gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            onPressed: _handleCalculate,
                          ),
                          const SizedBox(width: 16),
                          _AnimatedActionButton(
                            label: "SAVE",
                            icon: Icons.save_rounded,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            onPressed: _saveData,
                          ),
                          const SizedBox(width: 16),
                          _AnimatedActionButton(
                            label: "SAVE ALL",
                            icon: Icons.save_as_rounded,
                            gradientColors: const [Color(0xFF10B981), Color(0xFF047857)],
                            onPressed: _saveAll,
                          ),
                        ],
                      ),
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

  Future<void> _handleCalculate() async {
    if (isBpChanged) {
      const bpDependents = {'npa', 'da', 'hra', 'nps', 'esi', 'epf'};
      manualOverrides.removeAll(bpDependents);
      dirtyManualFields.removeAll(bpDependents);
      isBpChanged = false;
    }

    if (isTaChanged) {
      const taDependents = {'daonta', 'esi', 'epf'};
      manualOverrides.removeAll(taDependents);
      dirtyManualFields.removeAll(taDependents);
      isTaChanged = false;
    }

    // Only check fields that the user actually modified manually in this session
    // and that are not yet confirmed in manualOverrides.
    List<String> unconfirmedManualFields = dirtyManualFields
        .where((field) => !manualOverrides.contains(field))
        .toList();

    if (unconfirmedManualFields.isNotEmpty) {
      if (!mounted) return;
      List<String> modifiedLabels = unconfirmedManualFields
          .map((f) => _autoCalculatedFieldLabels[f] ?? f.toUpperCase())
          .toList();

      bool? confirmOverride = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Manual Override"),
          content: Text(
            "You have manually modified auto-calculated field(s):\n"
            "${modifiedLabels.join(', ')}\n\n"
            "Do you want to override the calculated data with manually entered values?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Use Auto Values"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text("Override"),
            ),
          ],
        ),
      );

      if (confirmOverride == null) {
        return; // User cancelled
      } else if (confirmOverride == true) {
        setState(() {
          manualOverrides.addAll(unconfirmedManualFields);
          dirtyManualFields.removeAll(unconfirmedManualFields);
        });
      } else {
        setState(() {
          manualOverrides.removeAll(unconfirmedManualFields);
          dirtyManualFields.removeAll(unconfirmedManualFields);
        });
      }
    }

    await _calculateData(widget.shortMonth);
  }

  Future<Map<String, dynamic>> _calculateData(String month, {bool isIncrement = false, Set<String>? overridesToUse}) async {
    Set<String> activeOverrides = overridesToUse ?? manualOverrides;

    try {
      DatabaseReference percentageRef = _dbRef.child(sharedData.userPlace).child('percentage');
      DatabaseEvent event = await percentageRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<dynamic, dynamic> pData = {};
        rawData.forEach((key, value) {
          pData[key] = value;
        });

        setState(() {
          percentageData = pData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    }

    try {
      int dap = 0, hrap = 0, tap = 0, npap = 0;
      int bpVal = int.tryParse(bpController.text) ?? 0;
      int npaVal = int.tryParse(npaController.text) ?? 0;
      if (isIncrement) {
        double incrementAmount = bpVal * 0.03;
        incrementAmount = ((incrementAmount + 50) ~/ 100) * 100;
        bpVal = bpVal + incrementAmount.toInt();
        if (bpVal > 218200) {
          bpVal = 218200;
        }
        bpController.text = bpVal.toString();
      }
      monthData['bp'] = bpVal.toString();

      if (activeOverrides.contains('npa')) {
        npaVal = int.tryParse(npaController.text) ?? 0;
        monthData['npa'] = npaController.text = npaVal.toString();
      } else {
        if (npachk) {
          npap = int.tryParse(percentageData['${month}n']?.toString() ?? '0') ?? 0;
          npaVal = (bpVal * (npap / 100)).round();
          if (npaVal + bpVal > 237500) {
            npaVal = npaVal - (bpVal + npaVal - 237500);
          }
          monthData['npa'] = npaController.text = npaVal.toString();
        } else {
          monthData['npa'] = npaController.text = '0';
          npaVal = 0;
        }
      }

      if (activeOverrides.contains('da')) {
        int daVal = int.tryParse(daController.text) ?? 0;
        monthData['da'] = daController.text = daVal.toString();
      } else {
        if (dachk) {
          dap = int.tryParse(percentageData['${month}d']?.toString() ?? '0') ?? 0;
          monthData['da'] = daController.text = ((bpVal + npaVal) * (dap / 100)).round().toString();
        } else {
          monthData['da'] = daController.text = '0';
        }
      }

      if (activeOverrides.contains('hra')) {
        int hraVal = int.tryParse(hraController.text) ?? 0;
        monthData['hra'] = hraController.text = hraVal.toString();
      } else {
        if (hrachk) {
          hrap = int.tryParse(percentageData['${month}h']?.toString() ?? '0') ?? 0;
          monthData['hra'] = hraController.text = (bpVal * (hrap / 100)).round().toString();
        } else {
          monthData['hra'] = hraController.text = '0';
        }
      }

      if (activeOverrides.contains('daonta')) {
        int daontaVal = int.tryParse(daontaController.text) ?? 0;
        monthData['daonta'] = daontaController.text = daontaVal.toString();
      } else {
        if (tachk) {
          tap = int.tryParse(percentageData['${month}d']?.toString() ?? '0') ?? 0;
          monthData['daonta'] = daontaController.text = ((int.tryParse(taController.text) ?? 0) * (tap / 100)).round().toString();
        } else {
          monthData['daonta'] = daontaController.text = '0';
        }
      }

      // Gross Salary: Automatically calculated from all allowance components (reflecting manual overrides)
      var controllers = [
        bpController, daController, hraController, npaController, splpayController, convController,
        pgController, annualController, uniformController, nursingController, taController, daontaController,
        medicalController, dirtController, washingController, tbController, nightController, driveController,
        cycleController, pcaController, otController, daext1Controller, daext2Controller, daext3Controller, daext4Controller,
      ];
      double grossTotal = controllers.map((controller) => double.tryParse(controller.text) ?? 0).reduce((sum, value) => sum + value);
      monthData['gross'] = grossController.text = grossTotal.round().toString();

      if (npschk && gpfchk) {
        if (mounted) {
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
        }
        return {};
      }

      if (activeOverrides.contains('nps')) {
        int npsVal = int.tryParse(npsController.text) ?? 0;
        monthData['nps'] = npsController.text = npsVal.toString();
      } else if (npschk && !gpfchk) {
        var npsControllersList = [bpController, npaController, daController];
        double npsTotal = npsControllersList.map((controller) => double.tryParse(controller.text) ?? 0).reduce((sum, value) => sum + value);
        monthData['nps'] = npsController.text = (npsTotal * 0.10).round().toString();
      } else {
        monthData['nps'] = npsController.text = '0';
      }

      monthData['epf'] = monthData['esi'] = '0';

      if (activeOverrides.contains('esi')) {
        int esiVal = int.tryParse(esiController.text) ?? 0;
        monthData['esi'] = esiController.text = esiVal.toString();
      } else if (esichk) {
        if ((int.tryParse(monthData['gross']?.toString() ?? '0') ?? 0) <= 21000) {
          monthData['esi'] = esiController.text = ((int.tryParse(monthData['gross']?.toString() ?? '0') ?? 0) * 0.0075).ceil().toString();
        }
      }

      if (activeOverrides.contains('epf')) {
        int epfVal = int.tryParse(epfController.text) ?? 0;
        monthData['epf'] = epfController.text = epfVal.toString();
      } else if (epfchk) {
        if ((int.tryParse(monthData['gross']?.toString() ?? '0') ?? 0) >= 15000) {
          monthData['epf'] = epfController.text = '1800';
        } else {
          monthData['epf'] = epfController.text = ((int.tryParse(monthData['gross']?.toString() ?? '0') ?? 0) * 0.12).round().toString();
        }
      }

      if (month == 'feb') incometaxController.text = '0';

      // Total Deductions: Automatically calculated as sum of all 17 deduction components
      var dedControllers = [
        incometaxController, gisController, gpfController, npsController, epfController, esiController,
        slfController, societyController, recoveryController, wfController, medController, waterController,
        otherController, ddext1Controller, ddext2Controller, ddext3Controller, ddext4Controller,
      ];
      double dedTotal = dedControllers.map((controller) => double.tryParse(controller.text) ?? 0).reduce((sum, value) => sum + value);
      monthData['totalded'] = totaldedController.text = dedTotal.round().toString();

      // Net Salary: Automatically calculated as Gross Salary - Total Deductions
      monthData['netsalary'] = netsalaryController.text = ((int.tryParse(grossController.text) ?? 0) - (int.tryParse(totaldedController.text) ?? 0)).toString();

      if (activeOverrides.isNotEmpty) {
        monthData['manual_overrides'] = activeOverrides.join(',');
      } else {
        monthData.remove('manual_overrides');
      }

      return Map<String, dynamic>.from(monthData);
    } catch (error) {
      final String message = "Error: $error";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
      return {};
    }
  }

  Future<void> _saveData() async {
    if (checkYearFrozenAndShowDialog(context)) return;
    try {
      DatabaseReference userMonthDataRef = _dbRef.child(sharedData.userPlace).child('monthdata');

      final currentMonthData = monthData;
      DatabaseReference currentMonthNodeRef = userMonthDataRef.child(widget.shortMonth).child(widget.biometricId);
      await currentMonthNodeRef.update(currentMonthData);

      await fetchIncrement();

      bool needsJulyIncrement = widget.shortMonth == 'jun' && mIncrement == 'JULY';
      bool needsJanuaryIncrement = widget.shortMonth == 'dec' && mIncrement == 'JANUARY';

      if (needsJulyIncrement || needsJanuaryIncrement) {
        String nextIncrementMonth = needsJulyIncrement ? 'jul' : 'jan';
        final incrementedData = await _calculateData(nextIncrementMonth, isIncrement: true, overridesToUse: {});
        DatabaseReference nextMonthNodeRef = userMonthDataRef.child(nextIncrementMonth).child(widget.biometricId);
        await nextMonthNodeRef.update(incrementedData);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Data Saved Successfully"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to save data:\n$e"),
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

  Future<void> _saveAll() async {
    if (checkYearFrozenAndShowDialog(context)) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: EdgeInsets.all(20.0),
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
    final List<String> months = ['mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec', 'jan', 'feb'];
    List<String> updatedmonths = [];
    try {
      DatabaseReference monthRef = _dbRef.child(sharedData.userPlace).child('monthdata');
      final int targetIndex = months.indexOf(widget.shortMonth);

      if (targetIndex != -1) {
        await fetchIncrement();
        await fetchRetierment();

        DateTime? retirementDate;
        DateTime? fyStartDate;

        if (dRetierment.isNotEmpty) {
          List<String> parts = dRetierment.split("-");
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          retirementDate = DateTime(year, month, day);

          List<String> years = sharedData.ccurrentYear.split("-");
          int startYear = int.parse(years[0]);
          fyStartDate = DateTime(startYear, 3, 1);
        }

        for (int i = targetIndex; i < months.length; i++) {
          final currentMonth = months[i];

          final currentMonthDate = getMonthDate(currentMonth, fyStartDate!.year);

          bool shouldClear = retirementDate != null &&
              currentMonthDate.isAfter(
                DateTime(retirementDate.year, retirementDate.month, 1),
              );

          if (shouldClear) {
            monthData.updateAll((key, value) {
              if (key == 'biometricid' || key == 'name' || key == 'designation') {
                return value;
              }
              return "0";
            });
            await monthRef.child(currentMonth).child(widget.biometricId).update(monthData);
          } else {
            updatedmonths.add(currentMonth);
            if ((widget.shortMonth != 'jul' && currentMonth == 'jul' && mIncrement == 'JULY') ||
                (widget.shortMonth != 'jan' && currentMonth == 'jan' && mIncrement == 'JANUARY')) {
              final incData = await _calculateData(currentMonth, isIncrement: true, overridesToUse: {});
              await monthRef.child(currentMonth).child(widget.biometricId).update(incData);
              continue;
            }
            final monthDataForCurrent = await _calculateData(
              currentMonth,
              overridesToUse: currentMonth == widget.shortMonth ? manualOverrides : {},
            );

            if (currentMonth == 'feb') {
              monthDataForCurrent['incometax'] = '0';
            }
            await monthRef.child(currentMonth).child(widget.biometricId).update(monthDataForCurrent);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: Text(
              "Data Saved Successfully for months:\n${updatedmonths.map((m) => m.toUpperCase()).join(', ')}",
            ),
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

  DateTime getMonthDate(String shortMonth, int fyStartYear) {
    const monthMap = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
      'sept': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };

    final m = monthMap[shortMonth]!;
    final year = (m == 1 || m == 2) ? fyStartYear + 1 : fyStartYear;
    return DateTime(year, m, 1);
  }
}

class AnimatedInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isEffectivelyReadOnly = widget.readOnly || !widget.enabled;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0.0, _isHovered && !isEffectivelyReadOnly ? -2.0 : 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: isMobile ? 3 : 8),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.w800,
                  color: isEffectivelyReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                boxShadow: [
                  if (_isHovered && !isEffectivelyReadOnly)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: isMobile ? 8 : 12,
                      offset: Offset(0, isMobile ? 2 : 4),
                    ),
                ],
              ),
              child: TextField(
                readOnly: isEffectivelyReadOnly,
                enabled: widget.enabled,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                onTap: () {
                  if (!isEffectivelyReadOnly &&
                      widget.keyboardType == TextInputType.number &&
                      widget.controller.text == '0') {
                    widget.controller.text = '';
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  }
                },
                style: TextStyle(
                  color: isEffectivelyReadOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: isEffectivelyReadOnly ? FontWeight.w700 : FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isEffectivelyReadOnly
                      ? const Color(0xFFF1F5F9)
                      : (_isHovered ? Colors.white : const Color(0xFFF8FAFC)),
                  prefixIcon: Icon(
                    widget.icon,
                    color: isEffectivelyReadOnly
                        ? const Color(0xFF94A3B8)
                        : (_isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                    size: isMobile ? 16 : 20,
                  ),
                  suffixIcon: isEffectivelyReadOnly
                      ? Icon(Icons.lock_outline_rounded, color: const Color(0xFFCBD5E1), size: isMobile ? 14 : 18)
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMobile ? 10 : 18,
                    horizontal: isMobile ? 10 : 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: BorderSide(
                      color: _isHovered && !isEffectivelyReadOnly ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  String newValue = value;
                  if (!isEffectivelyReadOnly &&
                      widget.keyboardType == TextInputType.number &&
                      newValue.length > 1 &&
                      newValue.startsWith('0')) {
                    newValue = newValue.replaceFirst(RegExp(r'^0+'), '');
                    if (newValue.isEmpty) newValue = '0';
                  }
                  if (widget.controller.text != newValue) {
                    final cursorPosition = TextSelection.collapsed(offset: newValue.length);
                    widget.controller.value = TextEditingValue(
                      text: newValue,
                      selection: cursorPosition,
                    );
                  }
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
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
    final isMobile = MediaQuery.of(context).size.width < 600;

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
                height: isMobile ? 44 : 60,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: _isHovered ? 0.4 : 0.2),
                      blurRadius: _isHovered ? (isMobile ? 12 : 20) : (isMobile ? 6 : 10),
                      offset: Offset(0, isMobile ? 4 : 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: isMobile ? 18 : 24),
                    SizedBox(width: isMobile ? 6 : 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 13 : 16,
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
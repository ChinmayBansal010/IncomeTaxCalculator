import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../shared.dart';

class FyMonthInfo {
  final String shortKey;
  final String fullName;
  final String quarter;
  final bool isIncrementMonth;

  const FyMonthInfo({
    required this.shortKey,
    required this.fullName,
    required this.quarter,
    this.isIncrementMonth = false,
  });
}

class FyMonthsSavePage extends StatefulWidget {
  const FyMonthsSavePage({super.key});

  @override
  State<FyMonthsSavePage> createState() => _FyMonthsSavePageState();
}

class _FyMonthsSavePageState extends State<FyMonthsSavePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  static const List<FyMonthInfo> fyMonths = [
    FyMonthInfo(shortKey: 'mar', fullName: 'MARCH', quarter: 'Q1 (Mar - May)'),
    FyMonthInfo(shortKey: 'apr', fullName: 'APRIL', quarter: 'Q1 (Mar - May)'),
    FyMonthInfo(shortKey: 'may', fullName: 'MAY', quarter: 'Q1 (Mar - May)'),
    FyMonthInfo(shortKey: 'jun', fullName: 'JUNE', quarter: 'Q2 (Jun - Aug)'),
    FyMonthInfo(shortKey: 'jul', fullName: 'JULY', quarter: 'Q2 (Jun - Aug)', isIncrementMonth: true),
    FyMonthInfo(shortKey: 'aug', fullName: 'AUGUST', quarter: 'Q2 (Jun - Aug)'),
    FyMonthInfo(shortKey: 'sept', fullName: 'SEPTEMBER', quarter: 'Q3 (Sep - Nov)'),
    FyMonthInfo(shortKey: 'oct', fullName: 'OCTOBER', quarter: 'Q3 (Sep - Nov)'),
    FyMonthInfo(shortKey: 'nov', fullName: 'NOVEMBER', quarter: 'Q3 (Sep - Nov)'),
    FyMonthInfo(shortKey: 'dec', fullName: 'DECEMBER', quarter: 'Q4 (Dec - Feb)'),
    FyMonthInfo(shortKey: 'jan', fullName: 'JANUARY', quarter: 'Q4 (Dec - Feb)', isIncrementMonth: true),
    FyMonthInfo(shortKey: 'feb', fullName: 'FEBRUARY', quarter: 'Q4 (Dec - Feb)'),
  ];

  Map<String, int> _savedCountPerMonth = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthCounts();
  }

  Future<void> _loadMonthCounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final monthDataRef = _dbRef.child('${sharedData.userPlace}/monthdata');
      final snapshot = await monthDataRef.get();

      Map<String, int> counts = {};
      if (snapshot.exists && snapshot.value is Map) {
        Map monthMap = snapshot.value as Map;
        monthMap.forEach((mKey, mVal) {
          if (mVal is Map) {
            counts[mKey.toString()] = mVal.length;
          }
        });
      }

      if (mounted) {
        setState(() {
          _savedCountPerMonth = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading month counts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchMainData() async {
    final mainRef = _dbRef.child('${sharedData.userPlace}/maindata');
    final snapshot = await mainRef.get();
    Map<String, Map<String, dynamic>> employees = {};

    if (snapshot.exists && snapshot.value is Map) {
      Map rawMap = snapshot.value as Map;
      rawMap.forEach((key, val) {
        if (key is String && val is Map) {
          employees[key] = Map<String, dynamic>.from(val);
        }
      });
    }
    return employees;
  }

  Future<Map<String, dynamic>> _fetchPercentageData() async {
    final percRef = _dbRef.child('${sharedData.userPlace}/percentage');
    final snapshot = await percRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  Map<String, String> _calculateEmployeeSalary({
    required String monthKey,
    required Map<String, dynamic> empDetails,
    required Map<String, dynamic> percData,
    Map<String, dynamic>? existingMonthData,
  }) {
    Map<String, String> mData = {};
    if (existingMonthData != null) {
      existingMonthData.forEach((k, v) {
        mData[k] = v?.toString() ?? '0';
      });
    }

    String biometricId = empDetails['biometricid']?.toString() ?? empDetails['biometricId']?.toString() ?? '';
    String name = empDetails['name']?.toString() ?? '';
    String designation = empDetails['designation']?.toString() ?? '';
    String mincrement = empDetails['mincrement']?.toString() ?? '';
    String dort = empDetails['dort']?.toString() ?? '';

    mData['biometricid'] = biometricId;
    mData['name'] = name;
    mData['designation'] = designation;

    // Check Retirement Date
    if (dort.isNotEmpty) {
      try {
        List<String> parts = dort.split("-");
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int mNum = int.parse(parts[1]);
          int yNum = int.parse(parts[2]);
          DateTime retirementDate = DateTime(yNum, mNum, day);

          List<String> years = sharedData.ccurrentYear.split("-");
          int startYear = int.parse(years[0]);

          Map<String, int> monthOrderIndex = {
            'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
            'jul': 7, 'aug': 8, 'sept': 9, 'oct': 10,
            'nov': 11, 'dec': 12, 'jan': 1, 'feb': 2,
          };
          int targetM = monthOrderIndex[monthKey] ?? 3;
          int targetY = (targetM >= 3) ? startYear : startYear + 1;
          DateTime monthDate = DateTime(targetY, targetM, 1);

          if (monthDate.isAfter(DateTime(retirementDate.year, retirementDate.month, 1))) {
            mData.forEach((key, value) {
              if (key != 'biometricid' && key != 'name' && key != 'designation') {
                mData[key] = "0";
              }
            });
            return mData;
          }
        }
      } catch (e) {
        debugPrint('Error parsing retirement date: $e');
      }
    }

    int bp = int.tryParse(mData['bp'] ?? empDetails['bp']?.toString() ?? '0') ?? 0;
    if (bp == 0 && empDetails.containsKey('bp')) {
      bp = int.tryParse(empDetails['bp'].toString()) ?? 0;
    }

    // Check Increment Month
    bool isJulyInc = monthKey == 'jul' && mincrement == 'JULY';
    bool isJanInc = monthKey == 'jan' && mincrement == 'JANUARY';

    if (isJulyInc || isJanInc) {
      double incAmt = bp * 0.03;
      incAmt = ((incAmt + 50) ~/ 100) * 100;
      bp = min(218200, bp + incAmt.toInt());
    }

    mData['bp'] = bp.toString();

    bool dachk = mData['dachk'] == 'true' || empDetails['dachk'] == true || empDetails['dachk'] == 'true';
    bool hrachk = mData['hrachk'] == 'true' || empDetails['hrachk'] == true || empDetails['hrachk'] == 'true';
    bool tachk = mData['tachk'] == 'true' || empDetails['tachk'] == true || empDetails['tachk'] == 'true';
    bool npachk = mData['npachk'] == 'true' || empDetails['npachk'] == true || empDetails['npachk'] == 'true';
    bool npschk = mData['npschk'] == 'true' || empDetails['npschk'] == true || empDetails['npschk'] == 'true';
    bool gpfchk = mData['gpfchk'] == 'true' || empDetails['gpfchk'] == true || empDetails['gpfchk'] == 'true';
    bool esichk = mData['esichk'] == 'true' || empDetails['esichk'] == true || empDetails['esichk'] == 'true';
    bool epfchk = mData['epfchk'] == 'true' || empDetails['epfchk'] == true || empDetails['epfchk'] == 'true';

    int dap = int.tryParse(percData['${monthKey}d']?.toString() ?? '0') ?? 0;
    int hrap = int.tryParse(percData['${monthKey}h']?.toString() ?? '0') ?? 0;
    int npap = int.tryParse(percData['${monthKey}n']?.toString() ?? '0') ?? 0;

    int npa = 0;
    if (npachk) {
      npa = (bp * (npap / 100)).round();
      if (npa + bp > 237500) {
        npa = max(0, 237500 - bp);
      }
      mData['npa'] = npa.toString();
    } else {
      mData['npa'] = '0';
    }

    if (dachk) {
      mData['da'] = ((bp + npa) * (dap / 100)).round().toString();
    } else {
      mData['da'] = '0';
    }

    if (hrachk) {
      mData['hra'] = (bp * (hrap / 100)).round().toString();
    } else {
      mData['hra'] = '0';
    }

    int taVal = int.tryParse(mData['ta'] ?? empDetails['ta']?.toString() ?? '0') ?? 0;
    if (tachk) {
      mData['daonta'] = (taVal * (dap / 100)).round().toString();
    } else {
      mData['daonta'] = '0';
    }

    // Gross Calculation
    List<String> grossFields = [
      'bp', 'da', 'hra', 'npa', 'splpay', 'conv', 'pg', 'annual',
      'uniform', 'nursing', 'ta', 'daonta', 'medical', 'dirt',
      'washing', 'tb', 'night', 'drive', 'cycle', 'pca', 'ot',
      'daext1', 'daext2', 'daext3', 'daext4',
    ];

    double grossTotal = 0;
    for (String field in grossFields) {
      double val = double.tryParse(mData[field] ?? empDetails[field]?.toString() ?? '0') ?? 0;
      grossTotal += val;
    }
    mData['gross'] = grossTotal.round().toString();

    // NPS Calculation
    if (npschk && !gpfchk) {
      int daVal = int.tryParse(mData['da'] ?? '0') ?? 0;
      double npsTotal = (bp + npa + daVal).toDouble();
      mData['nps'] = (npsTotal * 0.10).round().toString();
    }

    // ESI & EPF Calculation
    int grossInt = grossTotal.round();
    if (esichk) {
      if (grossInt <= 21000) {
        mData['esi'] = (grossInt * 0.0075).ceil().toString();
      } else {
        mData['esi'] = '0';
      }
    } else {
      mData['esi'] = '0';
    }

    if (epfchk) {
      if (grossInt >= 15000) {
        mData['epf'] = '1800';
      } else {
        mData['epf'] = (grossInt * 0.12).round().toString();
      }
    } else {
      mData['epf'] = '0';
    }

    if (monthKey == 'feb') {
      mData['incometax'] = '0';
    }

    // Total Deductions
    List<String> dedFields = [
      'incometax', 'gis', 'gpf', 'nps', 'epf', 'esi', 'slf', 'society',
      'recovery', 'wf', 'med', 'water', 'other', 'ddext1', 'ddext2', 'ddext3', 'ddext4',
    ];

    double dedTotal = 0;
    for (String field in dedFields) {
      double val = double.tryParse(mData[field] ?? empDetails[field]?.toString() ?? '0') ?? 0;
      dedTotal += val;
    }
    mData['totalded'] = dedTotal.round().toString();
    mData['netsalary'] = (grossInt - dedTotal.round()).toString();

    return mData;
  }

  Future<void> _processMonthSave({required FyMonthInfo monthInfo}) async {
    if (checkYearFrozenAndShowDialog(context)) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.calculate_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Text('Confirm ${monthInfo.fullName} Save'),
          ],
        ),
        content: Text(
          'Are you sure you want to calculate and save salary data for all employees for ${monthInfo.fullName} in Financial Year ${sharedData.ccurrentYear}?',
          style: const TextStyle(height: 1.4, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final nav = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2563EB)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Calculating & Saving ${monthInfo.fullName}...',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final employees = await _fetchMainData();
      final percData = await _fetchPercentageData();

      if (employees.isEmpty) {
        if (mounted) nav.pop();
        _showDialog('No Employee Records', 'No employee records found in maindata to save.');
        return;
      }

      final monthRef = _dbRef.child('${sharedData.userPlace}/monthdata/${monthInfo.shortKey}');
      int savedCount = 0;

      for (var entry in employees.entries) {
        String bioId = entry.key;
        Map<String, dynamic> empDetails = entry.value;

        // Fetch existing month data if present
        final existingSnap = await monthRef.child(bioId).get();
        Map<String, dynamic>? existingMap;
        if (existingSnap.exists && existingSnap.value is Map) {
          existingMap = Map<String, dynamic>.from(existingSnap.value as Map);
        }

        Map<String, String> calculatedMonthData = _calculateEmployeeSalary(
          monthKey: monthInfo.shortKey,
          empDetails: empDetails,
          percData: percData,
          existingMonthData: existingMap,
        );

        await monthRef.child(bioId).update(calculatedMonthData);
        savedCount++;
      }

      if (mounted) nav.pop();
      await _loadMonthCounts();

      _showDialog(
        'Month Save Complete',
        'Successfully calculated and saved salary records for $savedCount employees for ${monthInfo.fullName} (FY ${sharedData.ccurrentYear}).',
        isSuccess: true,
      );
    } catch (e) {
      if (mounted) nav.pop();
      _showDialog('Error Saving Month', 'An error occurred while saving ${monthInfo.fullName}: $e');
    }
  }

  Future<void> _processSaveAllMonths() async {
    if (checkYearFrozenAndShowDialog(context)) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.save_as_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 12),
            Text('Confirm Save All Months'),
          ],
        ),
        content: Text(
          'Are you sure you want to calculate and save salary data for ALL 12 months (March to February) for all employees in Financial Year ${sharedData.ccurrentYear}?\n\nThis will compute salary components, increments, and deductions across the entire financial year.',
          style: const TextStyle(height: 1.4, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Proceed & Save All'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    ValueNotifier<String> currentStatusNotifier = ValueNotifier('Preparing batch calculation...');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2563EB)),
              const SizedBox(height: 20),
              ValueListenableBuilder<String>(
                valueListenable: currentStatusNotifier,
                builder: (context, status, child) {
                  return Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    final nav = Navigator.of(context);

    try {
      final employees = await _fetchMainData();
      final percData = await _fetchPercentageData();

      if (employees.isEmpty) {
        if (mounted) nav.pop();
        _showDialog('No Employee Records', 'No employee records found in maindata to save.');
        return;
      }

      for (int i = 0; i < fyMonths.length; i++) {
        FyMonthInfo mInfo = fyMonths[i];
        currentStatusNotifier.value = 'Calculating & Saving ${mInfo.fullName} (${i + 1}/12)...';

        final monthRef = _dbRef.child('${sharedData.userPlace}/monthdata/${mInfo.shortKey}');

        for (var entry in employees.entries) {
          String bioId = entry.key;
          Map<String, dynamic> empDetails = entry.value;

          final existingSnap = await monthRef.child(bioId).get();
          Map<String, dynamic>? existingMap;
          if (existingSnap.exists && existingSnap.value is Map) {
            existingMap = Map<String, dynamic>.from(existingSnap.value as Map);
          }

          Map<String, String> calculatedMonthData = _calculateEmployeeSalary(
            monthKey: mInfo.shortKey,
            empDetails: empDetails,
            percData: percData,
            existingMonthData: existingMap,
          );

          await monthRef.child(bioId).update(calculatedMonthData);
        }
      }

      if (mounted) nav.pop();
      await _loadMonthCounts();

      _showDialog(
        'Save All Months Complete',
        'Successfully calculated and saved salary records for all 12 months (March to February) for ${employees.length} employees in FY ${sharedData.ccurrentYear}.',
        isSuccess: true,
      );
    } catch (e) {
      if (mounted) nav.pop();
      _showDialog('Error Saving Months', 'An error occurred during Save All: $e');
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isSuccess ? const Color(0xFF059669) : const Color(0xFF2563EB),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? const Color(0xFF059669) : const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
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
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildSaveAllCard(),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                          : _buildMonthsGrid(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Go Back',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FY Month Selection & Batch Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FY: ${sharedData.ccurrentYear} • Select a month or save all',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAllCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.save_as_rounded, color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Save All 12 Months (Mar - Feb)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Automatically computes & updates salary data for all employees across the entire financial year.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _processSaveAllMonths,
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('SAVE ALL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthsGrid() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      itemCount: fyMonths.length,
      itemBuilder: (context, index) {
        final mInfo = fyMonths[index];
        int count = _savedCountPerMonth[mInfo.shortKey] ?? 0;

        return _MonthCard(
          index: index + 1,
          monthInfo: mInfo,
          recordCount: count,
          onSaveMonth: () => _processMonthSave(monthInfo: mInfo),
        );
      },
    );
  }
}

class _MonthCard extends StatelessWidget {
  final int index;
  final FyMonthInfo monthInfo;
  final int recordCount;
  final VoidCallback onSaveMonth;

  const _MonthCard({
    required this.index,
    required this.monthInfo,
    required this.recordCount,
    required this.onSaveMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: monthInfo.isIncrementMonth ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          width: monthInfo.isIncrementMonth ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: monthInfo.isIncrementMonth ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                index < 10 ? '0$index' : '$index',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: monthInfo.isIncrementMonth ? const Color(0xFF1E3A8A) : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      monthInfo.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (monthInfo.isIncrementMonth) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Text(
                          'Increment Month',
                          style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      monthInfo.quarter,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    const SizedBox(width: 8),
                    Text(
                      recordCount > 0 ? '$recordCount Records Saved' : 'No Records Saved Yet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: recordCount > 0 ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSaveMonth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CALCULATE & SAVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

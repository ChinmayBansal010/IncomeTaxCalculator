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

  Future<Map<String, Map<String, Map<String, dynamic>>>> _fetchAllMonthData() async {
    final monthRef = _dbRef.child('${sharedData.userPlace}/monthdata');
    final snapshot = await monthRef.get();
    Map<String, Map<String, Map<String, dynamic>>> allData = {};

    if (snapshot.exists && snapshot.value is Map) {
      Map rawMap = snapshot.value as Map;
      rawMap.forEach((mKey, mVal) {
        if (mKey is String && mVal is Map) {
          Map<String, Map<String, dynamic>> empMonthMap = {};
          mVal.forEach((bioKey, bioVal) {
            if (bioKey is String && bioVal is Map) {
              empMonthMap[bioKey] = Map<String, dynamic>.from(bioVal);
            }
          });
          allData[mKey] = empMonthMap;
        }
      });
    }
    return allData;
  }

  Map<String, dynamic> _getEmployeeInitialBaseState({
    required String bioId,
    required Map<String, dynamic> empDetails,
    required Map<String, Map<String, Map<String, dynamic>>> allMonthData,
  }) {
    Map<String, dynamic> baseState = {};

    empDetails.forEach((k, v) {
      baseState[k] = v;
    });

    for (var mInfo in fyMonths) {
      String mKey = mInfo.shortKey;
      if (allMonthData.containsKey(mKey) && allMonthData[mKey]!.containsKey(bioId)) {
        Map<String, dynamic> mData = allMonthData[mKey]![bioId]!;

        mData.forEach((k, v) {
          if (v != null && v.toString().isNotEmpty && v.toString() != '0') {
            baseState[k] = v;
          } else if (!baseState.containsKey(k)) {
            baseState[k] = v;
          }
        });

        int monthBp = int.tryParse(mData['bp']?.toString() ?? '0') ?? 0;
        int monthGross = int.tryParse(mData['gross']?.toString() ?? '0') ?? 0;

        if (monthBp > 0 || monthGross > 0) {
          baseState['bp'] = mData['bp']?.toString() ?? baseState['bp']?.toString() ?? '0';
          break;
        }
      }
    }

    return baseState;
  }

  DateTime _getMonthDate(String month, int startYear) {
    switch (month) {
      case 'mar': return DateTime(startYear, 3, 1);
      case 'apr': return DateTime(startYear, 4, 1);
      case 'may': return DateTime(startYear, 5, 1);
      case 'jun': return DateTime(startYear, 6, 1);
      case 'jul': return DateTime(startYear, 7, 1);
      case 'aug': return DateTime(startYear, 8, 1);
      case 'sept': return DateTime(startYear, 9, 1);
      case 'oct': return DateTime(startYear, 10, 1);
      case 'nov': return DateTime(startYear, 11, 1);
      case 'dec': return DateTime(startYear, 12, 1);
      case 'jan': return DateTime(startYear + 1, 1, 1);
      case 'feb': return DateTime(startYear + 1, 2, 1);
      default: return DateTime(startYear, 3, 1);
    }
  }

  Map<String, String> _computeMonthData({
    required Map<String, dynamic> monthData,
    required String currentMonth,
    required Map<String, dynamic> percentageData,
  }) {
    Map<String, String> result = {};
    monthData.forEach((k, v) {
      result[k] = v?.toString() ?? '0';
    });

    bool dachk = result['dap']?.toString() == '1' || result['dachk']?.toString() == 'true' || result['dap'] == null;
    bool hrachk = result['hrap']?.toString() == '1' || result['hrachk']?.toString() == 'true' || result['hrap'] == null;
    bool tachk = result['tap']?.toString() == '1' || result['tachk']?.toString() == 'true' || result['tap'] == null;
    bool npachk = result['npap']?.toString() == '1' || result['npachk']?.toString() == 'true';

    bool gpfchk = result['gpfchk']?.toString() == '1' || result['gpfchk']?.toString() == 'true';
    bool npschk = result['npschk']?.toString() == '1' || result['npschk']?.toString() == 'true';
    bool epfchk = result['epfchk']?.toString() == '1' || result['epfchk']?.toString() == 'true';
    bool esichk = result['esichk']?.toString() == '1' || result['esichk']?.toString() == 'true';

    int dap = 0, hrap = 0, tap = 0, npap = 0;
    int bp = int.tryParse(result['bp'] ?? '0') ?? 0;
    int npa = int.tryParse(result['npa'] ?? '0') ?? 0;

    result['bp'] = bp.toString();

    if (npachk) {
      npap = int.tryParse(percentageData['${currentMonth}n']?.toString() ?? '0') ?? 0;
      npa = (bp * (npap / 100)).round();
      if (npa + bp > 237500) {
        npa = max(0, 237500 - bp);
      }
      result['npa'] = npa.toString();
    } else {
      result['npa'] = '0';
      npa = 0;
    }

    if (dachk) {
      dap = int.tryParse(percentageData['${currentMonth}d']?.toString() ?? '0') ?? 0;
      result['da'] = ((bp + npa) * (dap / 100)).round().toString();
    } else {
      result['da'] = '0';
    }

    if (hrachk) {
      hrap = int.tryParse(percentageData['${currentMonth}h']?.toString() ?? '0') ?? 0;
      result['hra'] = (bp * (hrap / 100)).round().toString();
    } else {
      result['hra'] = '0';
    }

    int taVal = int.tryParse(result['ta'] ?? '0') ?? 0;
    if (tachk) {
      tap = int.tryParse(percentageData['${currentMonth}d']?.toString() ?? '0') ?? 0;
      result['daonta'] = (taVal * (tap / 100)).round().toString();
    } else {
      result['daonta'] = '0';
    }

    // Gross Total
    List<String> grossFields = [
      'bp', 'da', 'hra', 'npa', 'splpay', 'conv', 'pg', 'annual',
      'uniform', 'nursing', 'ta', 'daonta', 'medical', 'dirt',
      'washing', 'tb', 'night', 'drive', 'cycle', 'pca', 'ot',
      'daext1', 'daext2', 'daext3', 'daext4',
    ];

    double grossTotal = 0;
    for (String field in grossFields) {
      double val = double.tryParse(result[field] ?? '0') ?? 0;
      grossTotal += val;
    }
    result['gross'] = grossTotal.round().toString();

    // Deductions
    if (npschk && !gpfchk) {
      int daVal = int.tryParse(result['da'] ?? '0') ?? 0;
      double npsTotal = (bp + npa + daVal).toDouble();
      result['nps'] = (npsTotal * 0.10).round().toString();
    }

    int grossInt = grossTotal.round();
    if (esichk) {
      if (grossInt <= 21000) {
        result['esi'] = (grossInt * 0.0075).ceil().toString();
      } else {
        result['esi'] = '0';
      }
    } else {
      result['esi'] = '0';
    }

    if (epfchk) {
      if (grossInt >= 15000) {
        result['epf'] = '1800';
      } else {
        result['epf'] = (grossInt * 0.12).round().toString();
      }
    } else {
      result['epf'] = '0';
    }

    if (currentMonth == 'feb') {
      result['incometax'] = '0';
    }

    List<String> dedFields = [
      'incometax', 'gis', 'gpf', 'nps', 'epf', 'esi', 'slf', 'society',
      'recovery', 'wf', 'med', 'water', 'other', 'ddext1', 'ddext2', 'ddext3', 'ddext4',
    ];

    double dedTotal = 0;
    for (String field in dedFields) {
      double val = double.tryParse(result[field] ?? '0') ?? 0;
      dedTotal += val;
    }

    result['totalded'] = dedTotal.round().toString();
    result['netsalary'] = (grossInt - dedTotal.round()).toString();

    return result;
  }

  Future<List<String>> _calculateAndSaveAllMonthsForEmployee({
    required String bioId,
    required Map<String, dynamic> empMainDetails,
    required Map<String, dynamic> percentageData,
    required Map<String, Map<String, dynamic>> allExistingMonthDataForBioId,
    String startMonth = 'mar',
  }) async {
    final List<String> monthKeys = ['mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec', 'jan', 'feb'];
    List<String> updatedMonths = [];

    DatabaseReference monthRef = _dbRef.child(sharedData.userPlace).child('monthdata');

    Map<String, dynamic> monthData = {};

    for (String m in monthKeys) {
      if (allExistingMonthDataForBioId.containsKey(m) && allExistingMonthDataForBioId[m]!.isNotEmpty) {
        monthData = Map<String, dynamic>.from(allExistingMonthDataForBioId[m]!);
        break;
      }
    }

    monthData['biometricid'] = bioId;
    monthData['name'] = empMainDetails['name']?.toString() ?? monthData['name']?.toString() ?? '';
    monthData['designation'] = empMainDetails['designation']?.toString() ?? monthData['designation']?.toString() ?? '';

    monthData['dap'] ??= empMainDetails['dap']?.toString() ?? '1';
    monthData['hrap'] ??= empMainDetails['hrap']?.toString() ?? '1';
    monthData['tap'] ??= empMainDetails['tap']?.toString() ?? '1';
    monthData['npap'] ??= empMainDetails['npap']?.toString() ?? '0';

    monthData['gpfchk'] ??= (empMainDetails['gpfchk'] == true || empMainDetails['gpfchk']?.toString() == '1' || empMainDetails['gpfchk']?.toString() == 'true') ? '1' : '0';
    monthData['npschk'] ??= (empMainDetails['npschk'] == true || empMainDetails['npschk']?.toString() == '1' || empMainDetails['npschk']?.toString() == 'true') ? '1' : '0';
    monthData['epfchk'] ??= (empMainDetails['epfchk'] == true || empMainDetails['epfchk']?.toString() == '1' || empMainDetails['epfchk']?.toString() == 'true') ? '1' : '0';
    monthData['esichk'] ??= (empMainDetails['esichk'] == true || empMainDetails['esichk']?.toString() == '1' || empMainDetails['esichk']?.toString() == 'true') ? '1' : '0';

    String mIncrement = empMainDetails['mincrement']?.toString() ?? '';
    String dRetierment = empMainDetails['dort']?.toString() ?? '';

    DateTime? retirementDate;
    DateTime? fyStartDate;

    if (dRetierment.isNotEmpty) {
      try {
        List<String> parts = dRetierment.split("-");
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          retirementDate = DateTime(year, month, day);

          List<String> years = sharedData.ccurrentYear.split("-");
          int startYear = int.parse(years[0]);
          fyStartDate = DateTime(startYear, 3, 1);
        }
      } catch (e) {
        debugPrint('Error parsing retirement date: $e');
      }
    }

    int targetIndex = monthKeys.indexOf(startMonth);
    if (targetIndex == -1) targetIndex = 0;

    for (int i = targetIndex; i < monthKeys.length; i++) {
      final currentMonth = monthKeys[i];

      if (allExistingMonthDataForBioId.containsKey(currentMonth) && allExistingMonthDataForBioId[currentMonth]!.isNotEmpty) {
        allExistingMonthDataForBioId[currentMonth]!.forEach((k, v) {
          if (v != null && v.toString().isNotEmpty && v.toString() != '0') {
            monthData[k] = v.toString();
          }
        });
      }

      bool shouldClear = false;
      if (retirementDate != null && fyStartDate != null) {
        DateTime currentMonthDate = _getMonthDate(currentMonth, fyStartDate.year);
        shouldClear = currentMonthDate.isAfter(DateTime(retirementDate.year, retirementDate.month, 1));
      }

      if (shouldClear) {
        Map<String, dynamic> retiredData = Map<String, dynamic>.from(monthData);
        retiredData.forEach((key, value) {
          if (key != 'biometricid' && key != 'name' && key != 'designation') {
            retiredData[key] = "0";
          }
        });
        await monthRef.child(currentMonth).child(bioId).update(retiredData);
      } else {
        updatedMonths.add(currentMonth);

        // Check Increment
        bool isIncrement = (startMonth != 'jul' && currentMonth == 'jul' && mIncrement == 'JULY') ||
            (startMonth != 'jan' && currentMonth == 'jan' && mIncrement == 'JANUARY');

        if (isIncrement) {
          int bp = int.tryParse(monthData['bp']?.toString() ?? '0') ?? 0;
          double incrementAmount = bp * 0.03;
          incrementAmount = ((incrementAmount + 50) ~/ 100) * 100;
          bp = bp + incrementAmount.toInt();
          if (bp > 218200) bp = 218200;
          monthData['bp'] = bp.toString();
        }

        Map<String, String> calculatedData = _computeMonthData(
          monthData: monthData,
          currentMonth: currentMonth,
          percentageData: percentageData,
        );

        if (currentMonth == 'feb') {
          calculatedData['incometax'] = '0';
        }

        calculatedData.forEach((k, v) {
          monthData[k] = v;
        });

        await monthRef.child(currentMonth).child(bioId).update(calculatedData);
      }
    }

    return updatedMonths;
  }

  Future<void> _processSingleMonthSave({required FyMonthInfo monthInfo}) async {
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
          'Are you sure you want to calculate and save salary data for all employees for ${monthInfo.fullName} ONLY in Financial Year ${sharedData.ccurrentYear}?',
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
      final allMonthData = await _fetchAllMonthData();

      if (employees.isEmpty) {
        if (mounted) nav.pop();
        _showDialog('No Employee Records', 'No employee records found in maindata to save.');
        return;
      }

      int savedCount = 0;

      for (var entry in employees.entries) {
        String bioId = entry.key;
        Map<String, dynamic> empDetails = entry.value;

        // Compute single month using exact calculations
        Map<String, dynamic> runningState = _getEmployeeInitialBaseState(
          bioId: bioId,
          empDetails: empDetails,
          allMonthData: allMonthData,
        );

        if (allMonthData.containsKey(monthInfo.shortKey) && allMonthData[monthInfo.shortKey]!.containsKey(bioId)) {
          runningState.addAll(allMonthData[monthInfo.shortKey]![bioId]!);
        }

        Map<String, String> calculatedMonthData = _computeMonthData(
          monthData: runningState,
          currentMonth: monthInfo.shortKey,
          percentageData: percData,
        );

        await _dbRef
            .child('${sharedData.userPlace}/monthdata/${monthInfo.shortKey}/$bioId')
            .update(calculatedMonthData);

        savedCount++;
      }

      if (mounted) nav.pop();
      await _loadMonthCounts();

      _showDialog(
        'Month Save Complete',
        'Successfully calculated and saved salary records for $savedCount employees for ${monthInfo.fullName} ONLY (FY ${sharedData.ccurrentYear}).',
        isSuccess: true,
      );
    } catch (e) {
      if (mounted) nav.pop();
      _showDialog('Error Saving Month', 'An error occurred while saving ${monthInfo.fullName}: $e');
    }
  }

  Future<void> _processMonthWiseSaveAll({required FyMonthInfo monthInfo}) async {
    if (checkYearFrozenAndShowDialog(context)) return;

    String startName = monthInfo.fullName;
    String rangeLabel = monthInfo.shortKey == 'mar'
        ? 'ALL 12 months (March to February)'
        : 'months from $startName to FEBRUARY (excluding preceding months)';

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Text('Confirm Save From $startName'),
          ],
        ),
        content: Text(
          'Are you sure you want to calculate and save salary data for $rangeLabel for all employees in Financial Year ${sharedData.ccurrentYear}?',
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
            child: const Text('Proceed & Save'),
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
      final allMonthData = await _fetchAllMonthData();

      if (employees.isEmpty) {
        if (mounted) nav.pop();
        _showDialog('No Employee Records', 'No employee records found in maindata to save.');
        return;
      }

      int employeeCount = 0;
      for (var entry in employees.entries) {
        String bioId = entry.key;
        Map<String, dynamic> empDetails = entry.value;

        employeeCount++;
        currentStatusNotifier.value = 'Calculating & Saving Employee $employeeCount/${employees.length} (${empDetails['name'] ?? bioId})...';

        await _calculateAndSaveAllMonthsForEmployee(
          bioId: bioId,
          empMainDetails: empDetails,
          percentageData: percData,
          allExistingMonthDataForBioId: allMonthData,
          startMonth: monthInfo.shortKey,
        );
      }

      if (mounted) nav.pop();
      await _loadMonthCounts();

      _showDialog(
        'Save Complete',
        'Successfully calculated and saved salary records from $startName to February for ${employees.length} employees in FY ${sharedData.ccurrentYear}.',
        isSuccess: true,
      );
    } catch (e) {
      if (mounted) nav.pop();
      _showDialog('Error Saving Months', 'An error occurred during save: $e');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.save_as_rounded, color: Color(0xFF2563EB), size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save All 12 Months (Mar - Feb)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Automatically computes & updates salary data for all employees across the entire financial year.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _processMonthWiseSaveAll(monthInfo: fyMonths[0]),
                icon: const Icon(Icons.bolt_rounded, size: 20),
                label: const Text(
                  'SAVE ALL 12 MONTHS (MARCH TO FEBRUARY)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
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
          onSaveSingleMonth: () => _processSingleMonthSave(monthInfo: mInfo),
          onSaveFromMonthToFeb: () => _processMonthWiseSaveAll(monthInfo: mInfo),
        );
      },
    );
  }
}

class _MonthCard extends StatelessWidget {
  final int index;
  final FyMonthInfo monthInfo;
  final int recordCount;
  final VoidCallback onSaveSingleMonth;
  final VoidCallback onSaveFromMonthToFeb;

  const _MonthCard({
    required this.index,
    required this.monthInfo,
    required this.recordCount,
    required this.onSaveSingleMonth,
    required this.onSaveFromMonthToFeb,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                            fontSize: 17,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          monthInfo.quarter,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
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
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isNarrow = constraints.maxWidth < 480;

              List<Widget> buttons = [
                OutlinedButton.icon(
                  onPressed: onSaveSingleMonth,
                  icon: const Icon(Icons.calculate_rounded, size: 16),
                  label: Text('Save ${monthInfo.fullName} Only'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onSaveFromMonthToFeb,
                  icon: const Icon(Icons.bolt_rounded, size: 16),
                  label: Text(
                    monthInfo.shortKey == 'mar'
                        ? 'Save All (Mar - Feb)'
                        : 'Save From ${monthInfo.fullName} to Feb',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ];

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buttons[0],
                    const SizedBox(height: 8),
                    buttons[1],
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: buttons[0]),
                    const SizedBox(width: 10),
                    Expanded(child: buttons[1]),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

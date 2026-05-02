import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'shared.dart';

class CalcArrearPage extends StatefulWidget {
  const CalcArrearPage({super.key});

  @override
  State<CalcArrearPage> createState() => _CalcArrearPageState();
}

class _CalcArrearPageState extends State<CalcArrearPage> with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController newDaPercentController = TextEditingController();
  final TextEditingController newHraPercentController = TextEditingController();
  final TextEditingController newNpaPercentController = TextEditingController();
  bool recalculateDa = false;
  bool recalculateHra = false;
  bool recalculateNpa = false;

  Map<String, bool> selectedTargetMonths = {
    'jan_p': false, 'feb_p': false,
    'mar': false, 'apr': false, 'may': false, 'jun': false,
    'jul': false, 'aug': false, 'sept': false, 'oct': false,
    'nov': false, 'dec': false, 'jan': false, 'feb': false,
  };

  final List<String> monthList = [
    'jan_p', 'feb_p', 'mar', 'apr', 'may', 'jun', 'jul', 'aug',
    'sept', 'oct', 'nov', 'dec', 'jan', 'feb'
  ];

  final List<Map<String, String>> valueAllowances = [
    {'key': 'splpay', 'label': 'SPL PAY'},
    {'key': 'conv', 'label': 'CONV'},
    {'key': 'pg', 'label': 'PG'},
    {'key': 'annual', 'label': 'ANNUAL'},
    {'key': 'uniform', 'label': 'UNIFORM'},
    {'key': 'nursing', 'label': 'NURSING'},
    {'key': 'medical', 'label': 'MEDICAL'},
    {'key': 'dirt', 'label': 'DIRT'},
    {'key': 'washing', 'label': 'WASHING'},
    {'key': 'tb', 'label': 'TB'},
    {'key': 'night', 'label': 'NIGHT'},
    {'key': 'drive', 'label': 'DRIVE'},
    {'key': 'cycle', 'label': 'CYCLE'},
    {'key': 'pca', 'label': 'PCA'},
  ];

  final Map<String, TextEditingController> newValControllers = {};
  final Map<String, bool> recalcFlags = {};

  bool isLoading = false;
  List<Map<String, dynamic>> calculationResults = [];
  List<Map<String, dynamic>> filteredResults = [];
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> allEmployees = [];
  Map<String, bool> selectedEmployees = {};
  final TextEditingController empSearchController = TextEditingController();
  bool isTargetMonthsExpanded = false;
  bool isEmployeesExpanded = false;

  Timer? _debounce;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _entranceController.forward();

    searchController.addListener(_onSearchChanged);
    for (var allow in valueAllowances) {
      newValControllers[allow['key']!] = TextEditingController();
      recalcFlags[allow['key']!] = false;
    }
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      DatabaseEvent mainDataEvent = await _dbRef.child(sharedData.userPlace).child('maindata').once();
      List<Map<String, String>> employees = [];
      if (mainDataEvent.snapshot.exists) {
        dynamic rawMainData = mainDataEvent.snapshot.value;
        if (rawMainData is Map) {
          rawMainData.forEach((key, value) {
            if (value is Map) {
              employees.add({
                'id': key.toString(),
                'name': value['name']?.toString() ?? 'Unknown'
              });
            }
          });
        } else if (rawMainData is List) {
          for (int i = 0; i < rawMainData.length; i++) {
            if (rawMainData[i] is Map) {
              employees.add({
                'id': i.toString(),
                'name': rawMainData[i]['name']?.toString() ?? 'Unknown'
              });
            }
          }
        }
      }
      employees.sort((a, b) => a['name']!.compareTo(b['name']!));
      if (mounted) {
        setState(() {
          allEmployees = employees;
          for (var emp in allEmployees) {
            selectedEmployees[emp['id']!] = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
    }
  }

  String _getMonthLabel(String mKey) {
    String currentYearStr = sharedData.ccurrentYear;
    List<String> parts = currentYearStr.split('-');
    if (parts.length != 2) return mKey.toUpperCase().replaceAll('_P', '');

    int startYear = int.parse(parts[0]);
    int endYear = 2000 + int.parse(parts[1]);

    String monthName = mKey.endsWith('_p') ? mKey.split('_')[0] : mKey;
    bool isPrevFY = mKey.endsWith('_p');

    int year;
    if (isPrevFY) {
      if (['jan', 'feb'].contains(monthName.toLowerCase())) {
        year = startYear;
      } else {
        year = startYear - 1;
      }
    } else {
      if (['jan', 'feb'].contains(monthName.toLowerCase())) {
        year = endYear;
      } else {
        year = startYear;
      }
    }
    return "${monthName.toUpperCase()} $year";
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _debounce?.cancel();
    newDaPercentController.dispose();
    newHraPercentController.dispose();
    newNpaPercentController.dispose();
    for (var c in newValControllers.values) {
      c.dispose();
    }
    searchController.dispose();
    empSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterResults);
  }

  void _filterResults() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredResults = calculationResults.where((r) {
        bool matchesPerson = r['name'].toString().toLowerCase().contains(query) ||
            r['bioId'].toString().toLowerCase().contains(query);

        bool matchesMonth = (r['monthlyData'] as List).any((m) =>
            m['month'].toString().toLowerCase().contains(query)
        );

        return matchesPerson || matchesMonth;
      }).toList();
    });
  }

  Future<void> _calculateArrears() async {
    if (recalculateDa && newDaPercentController.text.isEmpty) {
      _showModernSnackbar('Please enter the new DA %', Icons.warning_rounded, const Color(0xFFF59E0B));
      return;
    }

    List<String> activeTargetMonths = selectedTargetMonths.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeTargetMonths.isEmpty) {
      _showModernSnackbar('Please select at least one target month', Icons.calendar_today_rounded, const Color(0xFFF59E0B));
      return;
    }

    List<String> activeEmployeeIds = selectedEmployees.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeEmployeeIds.isEmpty) {
      _showModernSnackbar('Please select at least one employee', Icons.people_alt_rounded, const Color(0xFFF59E0B));
      return;
    }

    setState(() {
      isLoading = true;
      calculationResults = [];
    });

    double newDaPercent = double.tryParse(newDaPercentController.text) ?? 0;
    double newHraPercent = double.tryParse(newHraPercentController.text) ?? 0;
    double newNpaPercent = double.tryParse(newNpaPercentController.text) ?? 0;

    try {
      DatabaseEvent mainDataEvent = await _dbRef.child(sharedData.userPlace).child('maindata').once();
      Map<String, String> employeeNames = {};
      if (mainDataEvent.snapshot.exists) {
        dynamic rawMainData = mainDataEvent.snapshot.value;
        if (rawMainData is Map) {
          rawMainData.forEach((key, value) {
            if (value is Map) {
              employeeNames[key.toString()] = value['name']?.toString() ?? 'Unknown';
            }
          });
        } else if (rawMainData is List) {
          for (int i = 0; i < rawMainData.length; i++) {
            if (rawMainData[i] is Map) {
              employeeNames[i.toString()] = rawMainData[i]['name']?.toString() ?? 'Unknown';
            }
          }
        }
      }

      Map<String, Map<String, dynamic>> groupedResults = {};

      final List<Future<DatabaseEvent>> futures = activeTargetMonths.map((m) {
        String pathYear = sharedData.userPlace;
        String monthName = m;
        if (m.endsWith('_p')) {
          String currentYearStr = sharedData.ccurrentYear;
          List<String> parts = currentYearStr.split('-');
          int startYear = int.parse(parts[0]);
          String prevYearStr = "${startYear - 1}-${startYear.toString().substring(2)}";
          pathYear = sharedData.userPlace.replaceFirst(sharedData.ccurrentYear, prevYearStr);
          monthName = m.split('_')[0];
        }
        return _dbRef.child(pathYear).child('monthdata').child(monthName).once();
      }).toList();

      final List<DatabaseEvent> events = await Future.wait(futures);

      for (int i = 0; i < activeTargetMonths.length; i++) {
        final String targetMonth = activeTargetMonths[i];
        final DatabaseEvent monthEvent = events[i];

        if (monthEvent.snapshot.exists) {
          dynamic rawMonthData = monthEvent.snapshot.value;

          void process(String bId, Map d) {
            if (!activeEmployeeIds.contains(bId)) return;
            var entry = _calculateMonthEntry(
              bId,
              d,
              targetMonth,
              employeeNames,
              recalculateDa: recalculateDa,
              newDaPercent: newDaPercent,
              recalculateHra: recalculateHra,
              newHraPercent: newHraPercent,
              recalculateNpa: recalculateNpa,
              newNpaPercent: newNpaPercent,
              recalcFlags: recalcFlags,
              newValControllers: newValControllers,
            );
            if (!groupedResults.containsKey(bId)) {
              groupedResults[bId] = {
                'bioId': bId,
                'name': entry['name'],
                'totalArrear': 0.0,
                'monthlyData': [],
                'totals': <String, double>{},
              };
            }
            var p = groupedResults[bId]!;
            Map<String, double> totals = p['totals'];

            void addTotal(String key, double oldVal, double newVal, double diff) {
              totals['old_$key'] = (totals['old_$key'] ?? 0) + oldVal;
              totals['new_$key'] = (totals['new_$key'] ?? 0) + newVal;
              totals['diff_$key'] = (totals['diff_$key'] ?? 0) + diff;
            }

            addTotal('da', entry['oldDa'], entry['newDa'], entry['daDiff']);
            addTotal('hra', entry['oldHra'], entry['newHra'], entry['hraDiff']);
            addTotal('npa', entry['oldNpa'], entry['newNpa'], entry['npaDiff']);
            addTotal('daonta', entry['oldDaOnTa'], entry['newDaOnTa'], entry['daontaDiff']);
            addTotal('bp', entry['bp'], entry['bp'], 0);
            addTotal('ta', entry['ta'], entry['ta'], 0);

            for (var allow in valueAllowances) {
              String k = allow['key']!;
              addTotal(k, entry[k], entry['new$k'], entry['${k}Diff']);
            }

            p['monthlyData'].add(entry);
            p['totalArrear'] += entry['totalArrear'];
          }

          if (rawMonthData is Map) {
            rawMonthData.forEach((bioId, data) {
              if (data is Map) process(bioId.toString(), data);
            });
          } else if (rawMonthData is List) {
            for (int j = 0; j < rawMonthData.length; j++) {
              if (rawMonthData[j] is Map) process(j.toString(), rawMonthData[j]);
            }
          }
        }
      }

      List<Map<String, dynamic>> finalResults = groupedResults.values.toList();
      finalResults.sort((a, b) => a['name'].compareTo(b['name']));

      for (var person in finalResults) {
        (person['monthlyData'] as List).sort((a, b) =>
            monthList.indexOf(a['monthKey']).compareTo(monthList.indexOf(b['monthKey']))
        );
      }

      if (mounted) {
        setState(() {
          calculationResults = finalResults;
          _filterResults();
        });
      }
    } catch (e) {
      if (mounted) _showModernSnackbar('Error: $e', Icons.error_rounded, const Color(0xFFEF4444));
    } finally {
      if (mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  Map<String, dynamic> _calculateMonthEntry(
      String bioId,
      Map data,
      String targetMonth,
      Map<String, String> employeeNames, {
        bool recalculateDa = false,
        double newDaPercent = 0,
        bool recalculateHra = false,
        double newHraPercent = 0,
        bool recalculateNpa = false,
        double newNpaPercent = 0,
        Map<String, bool>? recalcFlags,
        Map<String, TextEditingController>? newValControllers,
      }) {
    String name = employeeNames[bioId] ?? 'Unknown';

    Map<String, double> oldVals = {};
    for (var allow in valueAllowances) {
      oldVals[allow['key']!] = double.tryParse(data[allow['key']]?.toString() ?? '0') ?? 0;
    }

    double da = double.tryParse(data['da']?.toString() ?? '0') ?? 0;
    double hra = double.tryParse(data['hra']?.toString() ?? '0') ?? 0;
    double npa = double.tryParse(data['npa']?.toString() ?? '0') ?? 0;
    double daonta = double.tryParse(data['daonta']?.toString() ?? '0') ?? 0;
    double bp = double.tryParse(data['bp']?.toString() ?? '0') ?? 0;
    double ta = double.tryParse(data['ta']?.toString() ?? '0') ?? 0;

    Map<String, double> newVals = {};
    for (var allow in valueAllowances) {
      String k = allow['key']!;
      if (recalcFlags != null && recalcFlags[k] == true && oldVals[k]! > 0) {
        newVals[k] = double.tryParse(newValControllers![k]!.text) ?? oldVals[k]!;
      } else {
        newVals[k] = oldVals[k]!;
      }
    }

    double newBp = bp;
    double newTa = ta;

    double newNpa = (recalculateNpa && npa > 0) ? (newBp * (newNpaPercent / 100)).roundToDouble() : npa;
    if (recalculateNpa && npa > 0 && (newNpa + newBp > 237500)) {
      newNpa = 237500 - newBp;
    }
    double npaDiff = newNpa - npa;

    double newDa = (recalculateDa && da > 0) ? ((newBp + newNpa) * (newDaPercent / 100)).roundToDouble() : da;
    double daDiff = newDa - da;

    double newDaOnTa = (recalculateDa && daonta > 0) ? (newTa * (newDaPercent / 100)).roundToDouble() : daonta;
    double daontaDiff = newDaOnTa - daonta;

    double newHra = (recalculateHra && hra > 0) ? (newBp * (newHraPercent / 100)).roundToDouble() : hra;
    double hraDiff = newHra - hra;

    String displayMonth = _getMonthLabel(targetMonth);

    Map<String, dynamic> entry = {
      'name': name,
      'month': displayMonth,
      'monthKey': targetMonth,
      'bp': bp,
      'ta': ta,
      'oldDa': da,
      'newDa': newDa,
      'daDiff': daDiff,
      'oldHra': hra,
      'newHra': newHra,
      'hraDiff': hraDiff,
      'oldNpa': npa,
      'newNpa': newNpa,
      'npaDiff': npaDiff,
      'oldDaOnTa': daonta,
      'newDaOnTa': newDaOnTa,
      'daontaDiff': daontaDiff,
    };

    double totalDiff = daDiff + hraDiff + npaDiff + daontaDiff;
    for (var allow in valueAllowances) {
      String k = allow['key']!;
      double diff = newVals[k]! - oldVals[k]!;
      entry[k] = oldVals[k]!;
      entry['new$k'] = newVals[k]!;
      entry['${k}Diff'] = diff;
      totalDiff += diff;
    }
    entry['totalArrear'] = totalDiff;

    return entry;
  }

  Future<void> _exportToExcel() async {
    if (calculationResults.isEmpty) {
      _showModernSnackbar('No results to export', Icons.info_outline_rounded, const Color(0xFF3B82F6));
      return;
    }

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    int rowIdx = 1;
    for (var person in calculationResults) {
      Map totals = person['totals'];

      bool showNpa = recalculateNpa && (totals['old_npa'] ?? 0) > 0;
      bool showHra = recalculateHra && (totals['old_hra'] ?? 0) > 0;
      bool showDa = recalculateDa && (totals['old_da'] ?? 0) > 0;
      bool showDaOnTa = recalculateDa && (totals['old_daonta'] ?? 0) > 0;

      List<Map<String, String>> personActiveExtraAllowances = valueAllowances.where((a) {
        String k = a['key']!;
        return recalcFlags[k] == true && (totals['old_$k'] ?? 0) > 0;
      }).toList();

      List<String> headers = ['ID', 'Name', 'Month', 'BP'];
      if (showNpa) headers.addAll(['Old NPA', 'New NPA', 'NPA Diff']);
      if (showHra) headers.addAll(['Old HRA', 'New HRA', 'HRA Diff']);
      if (showDa) headers.addAll(['Old DA', 'New DA', 'DA Diff']);
      if (showDaOnTa) headers.addAll(['Old DAonTA', 'New DAonTA', 'DAonTA Diff']);
      for (var allow in personActiveExtraAllowances) {
        headers.addAll(['Old ${allow['label']}', 'New ${allow['label']}', '${allow['label']} Diff']);
      }
      headers.add('Total Arrear');

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(rowIdx, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#D9E1F2';
        cell.cellStyle.hAlign = xlsio.HAlignType.center;
        cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      }
      rowIdx++;

      for (var m in person['monthlyData']) {
        sheet.getRangeByIndex(rowIdx, 1).setText(person['bioId'].toString());
        sheet.getRangeByIndex(rowIdx, 2).setText(person['name']);
        sheet.getRangeByIndex(rowIdx, 3).setText(m['month']);

        int currentCol = 4;
        sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['bp']);

        if (showNpa) {
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['oldNpa']);
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['newNpa']);
          final npaDiffCell = sheet.getRangeByIndex(rowIdx, currentCol++);
          npaDiffCell.setNumber(m['npaDiff']);
          if (m['npaDiff'] < 0) npaDiffCell.cellStyle.fontColor = '#FF0000';
        }

        if (showHra) {
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['oldHra']);
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['newHra']);
          final hraDiffCell = sheet.getRangeByIndex(rowIdx, currentCol++);
          hraDiffCell.setNumber(m['hraDiff']);
          if (m['hraDiff'] < 0) hraDiffCell.cellStyle.fontColor = '#FF0000';
        }

        if (showDa) {
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['oldDa']);
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['newDa']);
          final daDiffCell = sheet.getRangeByIndex(rowIdx, currentCol++);
          daDiffCell.setNumber(m['daDiff']);
          if (m['daDiff'] < 0) daDiffCell.cellStyle.fontColor = '#FF0000';
        }

        if (showDaOnTa) {
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['oldDaOnTa']);
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['newDaOnTa']);
          final taDiffCell = sheet.getRangeByIndex(rowIdx, currentCol++);
          taDiffCell.setNumber(m['daontaDiff']);
          if (m['daontaDiff'] < 0) taDiffCell.cellStyle.fontColor = '#FF0000';
        }

        for (var allow in personActiveExtraAllowances) {
          String k = allow['key']!;
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m[k]);
          sheet.getRangeByIndex(rowIdx, currentCol++).setNumber(m['new$k']);
          final diffCell = sheet.getRangeByIndex(rowIdx, currentCol++);
          diffCell.setNumber(m['${k}Diff']);
          if (m['${k}Diff'] < 0) diffCell.cellStyle.fontColor = '#FF0000';
        }

        final totalCell = sheet.getRangeByIndex(rowIdx, currentCol++);
        totalCell.setNumber(m['totalArrear']);
        if (m['totalArrear'] < 0) totalCell.cellStyle.fontColor = '#FF0000';

        rowIdx++;
      }

      int totalCols = headers.length;
      final totalCellRange = sheet.getRangeByIndex(rowIdx, 1, rowIdx, totalCols);
      totalCellRange.cellStyle.bold = true;
      totalCellRange.cellStyle.backColor = '#F2F2F2';
      totalCellRange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      sheet.getRangeByIndex(rowIdx, 2).setText("${person['name']} TOTAL");

      int currentTotalCol = 4;
      sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_bp'] ?? 0);

      if (showNpa) {
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_npa']);
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['new_npa']);
        final sumNpaDiffCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
        sumNpaDiffCell.setNumber(totals['diff_npa']);
        if (totals['diff_npa'] < 0) sumNpaDiffCell.cellStyle.fontColor = '#FF0000';
      }

      if (showHra) {
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_hra']);
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['new_hra']);
        final sumHraDiffCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
        sumHraDiffCell.setNumber(totals['diff_hra']);
        if (totals['diff_hra'] < 0) sumHraDiffCell.cellStyle.fontColor = '#FF0000';
      }

      if (showDa) {
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_da']);
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['new_da']);
        final sumDaDiffCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
        sumDaDiffCell.setNumber(totals['diff_da']);
        if (totals['diff_da'] < 0) sumDaDiffCell.cellStyle.fontColor = '#FF0000';
      }

      if (showDaOnTa) {
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_daonta']);
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['new_daonta']);
        final sumTaDiffCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
        sumTaDiffCell.setNumber(totals['diff_daonta']);
        if (totals['diff_daonta'] < 0) sumTaDiffCell.cellStyle.fontColor = '#FF0000';
      }

      for (var allow in personActiveExtraAllowances) {
        String k = allow['key']!;
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['old_$k']);
        sheet.getRangeByIndex(rowIdx, currentTotalCol++).setNumber(totals['new_$k']);
        final diffCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
        diffCell.setNumber(totals['diff_$k']);
        if (totals['diff_$k'] < 0) diffCell.cellStyle.fontColor = '#FF0000';
      }

      final sumTotalCell = sheet.getRangeByIndex(rowIdx, currentTotalCol++);
      sumTotalCell.setNumber(person['totalArrear']);
      if (person['totalArrear'] < 0) sumTotalCell.cellStyle.fontColor = '#FF0000';

      rowIdx += 2;
    }

    for (int i = 1; i <= 30; i++) {
      sheet.autoFitColumn(i);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    String fileName = "Arrear_Report_${sharedData.ccurrentYear.replaceAll('/', '-')}.xlsx";

    if (kIsWeb) {
      final content = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(content);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(file.path);
    }
  }

  void _showModernSnackbar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
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
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 900;
                      if (isWide) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 400,
                                margin: const EdgeInsets.only(right: 20),
                                child: _buildInputSection(),
                              ),
                              Expanded(
                                child: _buildResultsSection(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return _buildMobileLayout();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Arrear Calculator",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Calculate and export monthly arrears",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (calculationResults.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _exportToExcel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.file_download_rounded, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "EXPORT",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: calculationResults.isEmpty ? 1 : filteredResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildInputSection(),
          );
        }
        return _buildResultCard(filteredResults[index - 1]);
      },
    );
  }

  Widget _buildResultsSection() {
    return Container(
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
        children: [
          if (calculationResults.isNotEmpty) _buildSearchAndHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredResults.length,
              cacheExtent: 1500,
              itemBuilder: (context, index) => _buildResultCard(filteredResults[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search results...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt_rounded, color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${filteredResults.length} Records',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: Icon(
              Icons.calculate_outlined,
              size: 64,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            calculationResults.isEmpty
                ? 'Ready to Calculate'
                : 'No matches found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            calculationResults.isEmpty
                ? 'Adjust parameters and click Calculate'
                : 'Try a different search term',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _entranceController.value)),
          child: Opacity(
            opacity: _entranceController.value,
            child: child,
          ),
        );
      },
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                ),
                child: const Text(
                  "Parameters Configuration",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Allowances', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
                  leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF64748B), size: 20),
                  childrenPadding: const EdgeInsets.only(bottom: 16),
                  children: [
                    _buildSwitchTile('DA Percentage', recalculateDa, (v) => setState(() => recalculateDa = v)),
                    if (recalculateDa)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: TextField(
                          controller: newDaPercentController,
                          decoration: _inputDecoration('New DA %', Icons.percent_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    _buildSwitchTile('HRA Percentage', recalculateHra, (v) => setState(() => recalculateHra = v)),
                    if (recalculateHra)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: TextField(
                          controller: newHraPercentController,
                          decoration: _inputDecoration('New HRA %', Icons.home_work_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    _buildSwitchTile('NPA Percentage', recalculateNpa, (v) => setState(() => recalculateNpa = v)),
                    if (recalculateNpa)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: TextField(
                          controller: newNpaPercentController,
                          decoration: _inputDecoration('New NPA %', Icons.medical_services_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    const Divider(height: 32, indent: 20, endIndent: 20, color: Color(0xFFE2E8F0)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('OTHER ALLOWANCES (FIXED VALUE)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                    ),
                    ...valueAllowances.map((allow) {
                      String k = allow['key']!;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: recalcFlags[k],
                                onChanged: (v) => setState(() => recalcFlags[k] = v ?? false),
                                activeColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(allow['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: TextField(
                                controller: newValControllers[k],
                                enabled: recalcFlags[k],
                                decoration: InputDecoration(
                                  hintText: 'Amount',
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  filled: true,
                                  fillColor: recalcFlags[k]! ? Colors.white : const Color(0xFFF1F5F9),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: const Text('Target Months', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
                  leading: const Icon(Icons.calendar_month_rounded, color: Color(0xFF64748B), size: 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() => selectedTargetMonths.updateAll((k, v) => true)),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                            child: const Text('Select All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => selectedTargetMonths.updateAll((k, v) => false)),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                            child: const Text('Clear All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: monthList.map((m) {
                          bool isSelected = selectedTargetMonths[m]!;
                          String label = _getMonthLabel(m);
                          return FilterChip(
                            label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF475569))),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0))),
                            onSelected: (selected) => setState(() => selectedTargetMonths[m] = selected),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Employee Selection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
                  leading: const Icon(Icons.people_alt_rounded, color: Color(0xFF64748B), size: 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: TextField(
                        controller: empSearchController,
                        onChanged: (v) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  final query = empSearchController.text.toLowerCase();
                                  setState(() {
                                    for (var emp in allEmployees) {
                                      if (query.isEmpty || emp['name']!.toLowerCase().contains(query) || emp['id']!.toLowerCase().contains(query)) {
                                        selectedEmployees[emp['id']!] = true;
                                      }
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                                child: const Text('Select Visible', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              TextButton(
                                onPressed: () {
                                  final query = empSearchController.text.toLowerCase();
                                  setState(() {
                                    for (var emp in allEmployees) {
                                      if (query.isEmpty || emp['name']!.toLowerCase().contains(query) || emp['id']!.toLowerCase().contains(query)) {
                                        selectedEmployees[emp['id']!] = false;
                                      }
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                                child: const Text('Clear Visible', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '${selectedEmployees.values.where((v) => v).length}/${allEmployees.length}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Builder(
                          builder: (context) {
                            final query = empSearchController.text.toLowerCase();
                            final visibleEmployees = allEmployees.where((emp) =>
                            query.isEmpty || emp['name']!.toLowerCase().contains(query) || emp['id']!.toLowerCase().contains(query)
                            ).toList();

                            return ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: visibleEmployees.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              itemBuilder: (context, index) {
                                final emp = visibleEmployees[index];
                                final id = emp['id']!;
                                return CheckboxListTile(
                                  title: Text(emp['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                  subtitle: Text('ID: $id', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                                  value: selectedEmployees[id] ?? false,
                                  onChanged: (val) => setState(() => selectedEmployees[id] = val ?? false),
                                  activeColor: const Color(0xFF2563EB),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                );
                              },
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                ),
                child: ElevatedButton(
                  onPressed: _calculateArrears,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calculate_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('CALCULATE ARREARS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> person) {
    List monthlyData = person['monthlyData'];
    Map totals = person['totals'];

    bool showNpa = recalculateNpa && (totals['old_npa'] ?? 0) > 0;
    bool showHra = recalculateHra && (totals['old_hra'] ?? 0) > 0;
    bool showDa = recalculateDa && (totals['old_da'] ?? 0) > 0;
    bool showDaOnTa = recalculateDa && (totals['old_daonta'] ?? 0) > 0;

    List<Map<String, String>> personActiveExtraAllowances = valueAllowances.where((a) {
      String k = a['key']!;
      return recalcFlags[k] == true && (totals['old_$k'] ?? 0) > 0;
    }).toList();

    Color amountColor = person['totalArrear'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            title: Text(person['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildBadge('ID: ${person['bioId']}', const Color(0xFFF1F5F9), const Color(0xFF475569), Icons.fingerprint_rounded),
                  _buildBadge('${monthlyData.length} Months', const Color(0xFFEFF6FF), const Color(0xFF2563EB), Icons.calendar_month_rounded),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: amountColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TOTAL DIFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: amountColor.withValues(alpha: 0.8))),
                  const SizedBox(height: 2),
                  Text('₹${person['totalArrear'].toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: amountColor)),
                ],
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: DataTable(
                    headingRowHeight: 50,
                    dataRowHeight: 56,
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF475569)),
                    dataTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                    headingRowColor: WidgetStateProperty.all(Colors.white),
                    columns: [
                      const DataColumn(label: Text('MONTH')),
                      const DataColumn(label: Text('BP')),

                      if (showNpa) ...[
                        const DataColumn(label: Text('OLD NPA')),
                        const DataColumn(label: Text('NEW NPA')),
                        const DataColumn(label: Text('NPA DIFF', style: TextStyle(color: Color(0xFF334155)))),
                      ],
                      if (showHra) ...[
                        const DataColumn(label: Text('OLD HRA')),
                        const DataColumn(label: Text('NEW HRA')),
                        const DataColumn(label: Text('HRA DIFF', style: TextStyle(color: Color(0xFF334155)))),
                      ],
                      if (showDa) ...[
                        const DataColumn(label: Text('OLD DA')),
                        const DataColumn(label: Text('NEW DA')),
                        const DataColumn(label: Text('DA DIFF', style: TextStyle(color: Color(0xFF334155)))),
                      ],
                      if (showDaOnTa) ...[
                        const DataColumn(label: Text('OLD DAonTA')),
                        const DataColumn(label: Text('NEW DAonTA')),
                        const DataColumn(label: Text('DAonTA DIFF', style: TextStyle(color: Color(0xFF334155)))),
                      ],
                      for (var allow in personActiveExtraAllowances) ...[
                        DataColumn(label: Text('OLD ${allow['label']}')),
                        DataColumn(label: Text('NEW ${allow['label']}')),
                        DataColumn(label: Text('${allow['label']} DIFF', style: const TextStyle(color: Color(0xFF334155)))),
                      ],
                      const DataColumn(label: Text('TOTAL', style: TextStyle(color: Color(0xFF1D4ED8)))),
                    ],
                    rows: [
                      ...monthlyData.map((m) => DataRow(
                        cells: [
                          DataCell(Text(m['month'], style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                          DataCell(Text(m['bp'].toStringAsFixed(0))),

                          if (showNpa) ...[
                            DataCell(Text(m['oldNpa'].toStringAsFixed(0))),
                            DataCell(Text(m['newNpa'].toStringAsFixed(0))),
                            DataCell(Text(m['npaDiff'].toStringAsFixed(0), style: TextStyle(color: m['npaDiff'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w800))),
                          ],
                          if (showHra) ...[
                            DataCell(Text(m['oldHra'].toStringAsFixed(0))),
                            DataCell(Text(m['newHra'].toStringAsFixed(0))),
                            DataCell(Text(m['hraDiff'].toStringAsFixed(0), style: TextStyle(color: m['hraDiff'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w800))),
                          ],
                          if (showDa) ...[
                            DataCell(Text(m['oldDa'].toStringAsFixed(0))),
                            DataCell(Text(m['newDa'].toStringAsFixed(0))),
                            DataCell(Text(m['daDiff'].toStringAsFixed(0), style: TextStyle(color: m['daDiff'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w800))),
                          ],
                          if (showDaOnTa) ...[
                            DataCell(Text(m['oldDaOnTa'].toStringAsFixed(0))),
                            DataCell(Text(m['newDaOnTa'].toStringAsFixed(0))),
                            DataCell(Text(m['daontaDiff'].toStringAsFixed(0), style: TextStyle(color: m['daontaDiff'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w800))),
                          ],
                          for (var allow in personActiveExtraAllowances) ...[
                            DataCell(Text(m[allow['key']!].toStringAsFixed(0))),
                            DataCell(Text(m['new${allow['key']!}'].toStringAsFixed(0))),
                            DataCell(Text(m['${allow['key']!}Diff'].toStringAsFixed(0),
                                style: TextStyle(color: m['${allow['key']!}Diff'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w800))),
                          ],
                          DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: m['totalArrear'] < 0 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(m['totalArrear'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, color: m['totalArrear'] < 0 ? const Color(0xFFDC2626) : const Color(0xFF059669))),
                              )
                          ),
                        ],
                      )),
                      DataRow(
                        color: WidgetStateProperty.all(const Color(0xFFEFF6FF)),
                        cells: [
                          const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)))),
                          DataCell(Text(totals['old_bp']?.toStringAsFixed(0) ?? '', style: const TextStyle(fontWeight: FontWeight.w800))),

                          if (showNpa) ...[
                            DataCell(Text(totals['old_npa'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['new_npa'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['diff_npa'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, color: totals['diff_npa'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
                          ],
                          if (showHra) ...[
                            DataCell(Text(totals['old_hra'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['new_hra'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['diff_hra'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, color: totals['diff_hra'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
                          ],
                          if (showDa) ...[
                            DataCell(Text(totals['old_da'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['new_da'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['diff_da'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, color: totals['diff_da'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
                          ],
                          if (showDaOnTa) ...[
                            DataCell(Text(totals['old_daonta'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['new_daonta'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['diff_daonta'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, color: totals['diff_daonta'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
                          ],
                          for (var allow in personActiveExtraAllowances) ...[
                            DataCell(Text(totals['old_${allow['key']!}'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['new_${allow['key']!}'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800))),
                            DataCell(Text(totals['diff_${allow['key']!}'].toStringAsFixed(0),
                                style: TextStyle(fontWeight: FontWeight.w900, color: totals['diff_${allow['key']!}'] < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
                          ],
                          DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: person['totalArrear'] < 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(person['totalArrear'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF2563EB),
      activeTrackColor: const Color(0xFFBFDBFE),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13),
      suffixText: '%',
      suffixStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
    );
  }
}
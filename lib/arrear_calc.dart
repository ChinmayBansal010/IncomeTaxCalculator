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

class _CalcArrearPageState extends State<CalcArrearPage> {
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

  @override
  void initState() {
    super.initState();
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
      setState(() {
        allEmployees = employees;
        for (var emp in allEmployees) {
          selectedEmployees[emp['id']!] = true;
        }
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the new DA %')),
      );
      return;
    }

    List<String> activeTargetMonths = selectedTargetMonths.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeTargetMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one target month')),
      );
      return;
    }

    List<String> activeEmployeeIds = selectedEmployees.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one employee')),
      );
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

      setState(() {
        calculationResults = finalResults;
        _filterResults();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() { isLoading = false; });
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No results to export')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('ARREAR CALCULATOR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          if (calculationResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download, color: Colors.white, size: 20),
                label: const Text('EXCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing data...', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
              ],
            ))
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(right: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildInputSection(isWide: true),
                        ),
                      ),
                      Expanded(
                        child: _buildResultsSection(),
                      ),
                    ],
                  );
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: calculationResults.isEmpty ? 1 : filteredResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildInputSection(isWide: false);
        }
        return _buildResultCard(filteredResults[index - 1]);
      },
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        if (calculationResults.isNotEmpty) _buildSearchAndHeader(),
        Expanded(
          child: filteredResults.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredResults.length,
                  cacheExtent: 1500,
                  itemBuilder: (context, index) => _buildResultCard(filteredResults[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Name or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '${filteredResults.length} Records',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
            ],
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
          Icon(Icons.calculate_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            calculationResults.isEmpty 
              ? 'Select months and click Calculate' 
              : 'No records match your search',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ExpansionTile(
          title: const Text('ALLOWANCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent, letterSpacing: 1.2)),
          leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.blueAccent, size: 20),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildSwitchTile('DA Percentage', recalculateDa, (v) => setState(() => recalculateDa = v)),
            if (recalculateDa)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: newDaPercentController,
                  decoration: _inputDecoration('NEW DA %', Icons.percent_rounded),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            _buildSwitchTile('HRA Percentage', recalculateHra, (v) => setState(() => recalculateHra = v)),
            if (recalculateHra)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: newHraPercentController,
                  decoration: _inputDecoration('New HRA %', Icons.home_work_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            _buildSwitchTile('NPA Percentage', recalculateNpa, (v) => setState(() => recalculateNpa = v)),
            if (recalculateNpa)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: newNpaPercentController,
                  decoration: _inputDecoration('New NPA %', Icons.medical_services_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            const Divider(indent: 16, endIndent: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('OTHER ALLOWANCES (FIXED VALUE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
            ),
            ...valueAllowances.map((allow) {
              String k = allow['key']!;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: recalcFlags[k],
                        onChanged: (v) => setState(() => recalcFlags[k] = v ?? false),
                        activeColor: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(allow['label']!, style: const TextStyle(fontSize: 12))),
                    SizedBox(
                      width: 100,
                      height: 36,
                      child: TextField(
                        controller: newValControllers[k],
                        enabled: recalcFlags[k],
                        decoration: InputDecoration(
                          hintText: 'Value',
                          isDense: true,
                          filled: true,
                          fillColor: recalcFlags[k]! ? Colors.white : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
    const SizedBox(height: 16),

    Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: const Text('Target Months', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent)),
          leading: const Icon(Icons.calendar_month, color: Colors.blueAccent, size: 20),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => selectedTargetMonths.updateAll((k, v) => true)),
                    child: const Text('Select All', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => selectedTargetMonths.updateAll((k, v) => false)),
                    child: const Text('Clear All', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: monthList.map((m) {
                  bool isSelected = selectedTargetMonths[m]!;
                  String label = _getMonthLabel(m);
                  return FilterChip(
                    label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    checkmarkColor: Colors.white,
                    onSelected: (selected) => setState(() => selectedTargetMonths[m] = selected),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 16),
    Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ExpansionTile(
          title: const Text('Employee Selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent)),
          leading: const Icon(Icons.people_alt_rounded, color: Colors.blueAccent, size: 20),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: empSearchController,
                onChanged: (v) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              if (query.isEmpty || 
                                  emp['name']!.toLowerCase().contains(query) || 
                                  emp['id']!.toLowerCase().contains(query)) {
                                selectedEmployees[emp['id']!] = true;
                              }
                            }
                          });
                        },
                        child: const Text('Select Visible', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () {
                          final query = empSearchController.text.toLowerCase();
                          setState(() {
                            for (var emp in allEmployees) {
                              if (query.isEmpty || 
                                  emp['name']!.toLowerCase().contains(query) || 
                                  emp['id']!.toLowerCase().contains(query)) {
                                selectedEmployees[emp['id']!] = false;
                              }
                            }
                          });
                        },
                        child: const Text('Clear Visible', style: TextStyle(fontSize: 11, color: Colors.red)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${selectedEmployees.values.where((v) => v).length}/${allEmployees.length}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              child: Builder(
                builder: (context) {
                  final query = empSearchController.text.toLowerCase();
                  final visibleEmployees = allEmployees.where((emp) => 
                    query.isEmpty || 
                    emp['name']!.toLowerCase().contains(query) || 
                    emp['id']!.toLowerCase().contains(query)
                  ).toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: visibleEmployees.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade50),
                    itemBuilder: (context, index) {
                      final emp = visibleEmployees[index];
                      final id = emp['id']!;
                      return CheckboxListTile(
                        title: Text(emp['name']!, 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        subtitle: Text('ID: $id', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                        value: selectedEmployees[id] ?? false,
                        onChanged: (val) => setState(() => selectedEmployees[id] = val ?? false),
                        dense: true,
                        activeColor: Colors.blueAccent,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      );
                    },
                  );
                }
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),

    const SizedBox(height: 24),
    SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _calculateArrears,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('CALCULATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ),
        ),
        if (!isWide && calculationResults.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(),
          _buildSearchAndHeader(),
        ],
      ],
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade50),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(person['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.5)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Wrap(
            spacing: 12,
            children: [
              _buildBadge('ID: ${person['bioId']}', Colors.grey.shade100, Colors.black87),
              _buildBadge('${monthlyData.length} Months', Colors.blue.shade50, Colors.blueAccent),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('TOTAL DIFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            Text('₹${person['totalArrear'].toStringAsFixed(0)}', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: person['totalArrear'] < 0 ? Colors.red : Colors.green)),
          ],
        ),
        childrenPadding: const EdgeInsets.all(0),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 45,
                dataRowHeight: 50,
                columnSpacing: 18,
                horizontalMargin: 16,
                columns: [
                  const DataColumn(label: Text('MONTH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  const DataColumn(label: Text('BP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),

                  if (showNpa) ...[
                    const DataColumn(label: Text('OLD NPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('NEW NPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('NPA DIFF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                  if (showHra) ...[
                    const DataColumn(label: Text('OLD HRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('NEW HRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('HRA DIFF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                  if (showDa) ...[
                    const DataColumn(label: Text('OLD DA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('NEW DA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('DA DIFF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                  if (showDaOnTa) ...[
                    const DataColumn(label: Text('OLD DAonTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('NEW DAonTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const DataColumn(label: Text('DAonTA DIFF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                  for (var allow in personActiveExtraAllowances) ...[
                    DataColumn(label: Text('OLD ${allow['label']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    DataColumn(label: Text('NEW ${allow['label']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    DataColumn(label: Text('${allow['label']} DIFF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                  const DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
                rows: [
                  ...monthlyData.map((m) => DataRow(
                    cells: [
                      DataCell(Text(m['month'], style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(m['bp'].toStringAsFixed(0))),

                      if (showNpa) ...[
                        DataCell(Text(m['oldNpa'].toStringAsFixed(0))),
                        DataCell(Text(m['newNpa'].toStringAsFixed(0))),
                        DataCell(Text(m['npaDiff'].toStringAsFixed(0), style: TextStyle(color: m['npaDiff'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      ],
                      if (showHra) ...[
                        DataCell(Text(m['oldHra'].toStringAsFixed(0))),
                        DataCell(Text(m['newHra'].toStringAsFixed(0))),
                        DataCell(Text(m['hraDiff'].toStringAsFixed(0), style: TextStyle(color: m['hraDiff'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      ],
                      if (showDa) ...[
                        DataCell(Text(m['oldDa'].toStringAsFixed(0))),
                        DataCell(Text(m['newDa'].toStringAsFixed(0))),
                        DataCell(Text(m['daDiff'].toStringAsFixed(0), style: TextStyle(color: m['daDiff'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      ],
                      if (showDaOnTa) ...[
                        DataCell(Text(m['oldDaOnTa'].toStringAsFixed(0))),
                        DataCell(Text(m['newDaOnTa'].toStringAsFixed(0))),
                        DataCell(Text(m['daontaDiff'].toStringAsFixed(0), style: TextStyle(color: m['daontaDiff'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      ],
                      for (var allow in personActiveExtraAllowances) ...[
                        DataCell(Text(m[allow['key']!].toStringAsFixed(0))),
                        DataCell(Text(m['new${allow['key']!}'].toStringAsFixed(0))),
                        DataCell(Text(m['${allow['key']!}Diff'].toStringAsFixed(0), 
                          style: TextStyle(color: m['${allow['key']!}Diff'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      ],
                      DataCell(Text(m['totalArrear'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: m['totalArrear'] < 0 ? Colors.red : Colors.blueAccent))),
                    ],
                  )),
                  DataRow(
                    color: WidgetStateProperty.all(Colors.blue.shade50.withOpacity(0.5)),
                    cells: [
                      const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                      DataCell(Text(totals['old_bp']?.toStringAsFixed(0) ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),

                      if (showNpa) ...[
                        DataCell(Text(totals['old_npa'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['new_npa'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['diff_npa'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: totals['diff_npa'] < 0 ? Colors.red : Colors.green))),
                      ],
                      if (showHra) ...[
                        DataCell(Text(totals['old_hra'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['new_hra'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['diff_hra'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: totals['diff_hra'] < 0 ? Colors.red : Colors.green))),
                      ],
                      if (showDa) ...[
                        DataCell(Text(totals['old_da'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['new_da'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['diff_da'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: totals['diff_da'] < 0 ? Colors.red : Colors.green))),
                      ],
                      if (showDaOnTa) ...[
                        DataCell(Text(totals['old_daonta'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['new_daonta'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['diff_daonta'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: totals['diff_daonta'] < 0 ? Colors.red : Colors.green))),
                      ],
                      for (var allow in personActiveExtraAllowances) ...[
                        DataCell(Text(totals['old_${allow['key']!}'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['new_${allow['key']!}'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totals['diff_${allow['key']!}'].toStringAsFixed(0), 
                          style: TextStyle(fontWeight: FontWeight.bold, color: totals['diff_${allow['key']!}'] < 0 ? Colors.red : Colors.green))),
                      ],
                      DataCell(Text(person['totalArrear'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: person['totalArrear'] < 0 ? Colors.red : Colors.blueAccent))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      suffixText: '%',
      filled: true,
      fillColor: Colors.grey.shade50,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
      prefixIcon: Icon(icon, size: 18, color: Colors.blueAccent),
    );
  }
}

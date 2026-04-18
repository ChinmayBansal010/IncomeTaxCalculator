import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:incometax/shared.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;

Future<void> exportExcel(bool isZero) async {
  final db = FirebaseDatabase.instance.ref();
  final dataMainSnapshot = await db.child(sharedData.userPlace).child("maindata").once();
  final rawMain = dataMainSnapshot.snapshot.value;
  if (rawMain is! Map) return;
  final dataMain = Map<String, dynamic>.from(rawMain);

  final dataArrearSnapshot = await db.child(sharedData.userPlace).child("arrdata").once();
  final rawArrear = dataArrearSnapshot.snapshot.value;
  if (rawArrear is! Map) return;
  final arrearData = Map<String, dynamic>.from(rawArrear);

  final dataDedSnapshot = await db.child(sharedData.userPlace).child("deddata").once();
  final rawDed = dataDedSnapshot.snapshot.value;
  if (rawDed is! Map) return;
  final dedData = Map<String, dynamic>.from(rawDed);

  final oldTaxSnap = await db.child(sharedData.userPlace).child("itaxold").once();
  final newTaxSnap = await db.child(sharedData.userPlace).child("itaxnew").once();
  final oldTaxData = oldTaxSnap.snapshot.value is Map ? Map<String, dynamic>.from(oldTaxSnap.snapshot.value as Map) : <String, dynamic>{};
  final newTaxData = newTaxSnap.snapshot.value is Map ? Map<String, dynamic>.from(newTaxSnap.snapshot.value as Map) : <String, dynamic>{};

  final monthDataSnap = await db.child(sharedData.userPlace).child("monthdata").once();
  final allMonthsData = monthDataSnap.snapshot.value is Map ? Map<String, dynamic>.from(monthDataSnap.snapshot.value as Map) : <String, dynamic>{};

  final sheetMonths = [
    "March", "April", "May", "June", "July", "August", "September",
    "October", "November", "December", "January", "February"
  ];
  final dataMonths = [
    'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec', 'jan', 'feb'
  ];

  final workbook = xlsio.Workbook();

  for (int i = 0; i < dataMonths.length; i++) {
    final sheet = workbook.worksheets.addWithName(sheetMonths[i]);
    final monthKey = dataMonths[i];
    final rawMonth = allMonthsData[monthKey];
    final monthData = rawMonth is Map ? Map<String, dynamic>.from(rawMonth) : <String, dynamic>{};

    final data = getOptimizedData(monthKey, dataMain, monthData, dedData, oldTaxData, newTaxData, isZero);

    sheet.getRangeByIndex(1, 1, 1, 9).merge();
    sheet.getRangeByIndex(1, 1).setText(sharedData.zone.toUpperCase());
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.hAlign = xlsio.HAlignType.center;
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.bold = true;

    sheet.getRangeByIndex(2, 1, 2, 9).merge();
    sheet.getRangeByIndex(2, 1).setText("Details of Salary Payments made and TDS Deduction for financial Year");
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.hAlign = xlsio.HAlignType.center;
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.bold = true;

    final header = [
      "Sl. No.", "NAME AS PAN CARD (IT IS USED FOR IDENTIFICATION OF CORRECT NAME) IN CAPITAL LETTERS", "PAN NO AS PRINTED ON PAN CARD", "BMID NO", "DESIGNATION", "SALARY MONTH",
      "GROSS SALARY EXCLUDING NON TAXABLE", "TAX", "CHALLAN DATE (DD/MM/YYYY)", "SRN", "CHALLAN AMOUNT", "BSR CODE"
    ];
    sheet.importList(header, 3, 1, false);
    sheet.getRangeByIndex(3, 1, 3, 12).cellStyle.wrapText = true;
    sheet.getRangeByIndex(3, 1, 3, 12).autoFit();

    int rowIndex = 4;
    int totalTds = 0, totalGross = 0;

    for (var row in data) {
      sheet.importList(row, rowIndex, 1, false);
      totalGross += parseValue(row[6]);
      totalTds += parseValue(row[7]);
      rowIndex++;
    }

    List<dynamic> totalRow = ["", "", "", "", "", "Total", totalGross, totalTds, "", "", "", ""];
    sheet.importList(totalRow, rowIndex, 1, false);
    sheet.getRangeByIndex(1, 1, rowIndex, 12).autoFit();
  }

  final sheet = workbook.worksheets.addWithName("Arrear");

  sheet.getRangeByIndex(1, 1, 1, 13).merge();
  sheet.getRangeByIndex(1, 1).setText(sharedData.zone.toUpperCase());
  sheet.getRangeByIndex(1, 1, 1, 13).cellStyle.hAlign = xlsio.HAlignType.center;
  sheet.getRangeByIndex(1, 1, 1, 13).cellStyle.vAlign = xlsio.VAlignType.center;
  sheet.getRangeByIndex(1, 1, 1, 13).cellStyle.bold = true;

  sheet.getRangeByIndex(2, 1, 2, 13).merge();
  sheet.getRangeByIndex(2, 1).setText("Details of Salary Payments made and TDS Deduction for financial Year");
  sheet.getRangeByIndex(2, 1, 2, 13).cellStyle.hAlign = xlsio.HAlignType.center;
  sheet.getRangeByIndex(2, 1, 2, 13).cellStyle.vAlign = xlsio.VAlignType.center;
  sheet.getRangeByIndex(2, 1, 2, 13).cellStyle.bold = true;

  final header = [
    "Sl. No.", "NAME AS PAN CARD (IT IS USED FOR IDENTIFICATION OF CORRECT NAME) IN CAPITAL LETTERS",
    "PAN NO AS PRINTED ON PAN CARD", "BMID NO", "DESIGNATION", "MAR-MAY-OTHER", 'MAR-MAY-TAX', "JUN-AUG-OTHER", 'JUN-AUG-TAX',
    "SEPT-NOV-OTHER", 'SEPT-NOV-TAX', "DEC-FEB-OTHER", 'DEC-FEB-TAX'
  ];
  sheet.importList(header, 3, 1, false);
  sheet.getRangeByIndex(3, 1, 3, 13).cellStyle.wrapText = true;
  sheet.getRangeByIndex(3, 1, 3, 13).autoFit();

  final data = getArrearDataSync(dataMain, arrearData);
  int rowIndex = 4;
  int totalmmother = 0;
  int totalmmtax = 0;
  int totaljaother = 0;
  int totaljatax = 0;
  int totalsnother = 0;
  int totalsntax = 0;
  int totaldfother = 0;
  int totaldftax = 0;

  for (var row in data) {
    sheet.importList(row, rowIndex, 1, false);
    totalmmother += parseValue(row[5]);
    totalmmtax += parseValue(row[6]);
    totaljaother += parseValue(row[7]);
    totaljatax += parseValue(row[8]);
    totalsnother += parseValue(row[9]);
    totalsntax += parseValue(row[10]);
    totaldfother += parseValue(row[11]);
    totaldftax += parseValue(row[12]);
    rowIndex++;
  }

  List<dynamic> totalRow = ["", "", "", "", "Total", totalmmother, totalmmtax, totaljaother, totaljatax, totalsnother, totalsntax, totaldfother, totaldftax];
  sheet.importList(totalRow, rowIndex, 1, false);
  sheet.getRangeByIndex(1, 1, rowIndex, 13).autoFit();

  final xlsio.Worksheet firstSheet = workbook.worksheets[0];
  firstSheet.visibility = xlsio.WorksheetVisibility.hidden;

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb) {
    html.AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', 'tds.xlsx')
      ..click();
  } else {
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/tds.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}

List<List<dynamic>> getArrearDataSync(Map<String, dynamic> dataMain, Map<String, dynamic> arrearData) {
  List<List<dynamic>> dataList = [];
  final keys = dataMain.keys.toList();
  for (int i = 0; i < keys.length; i++) {
    final mainEntry = dataMain[keys[i]] is Map ? Map<String, dynamic>.from(dataMain[keys[i]]) : <String, dynamic>{};
    final arrearEntry = arrearData[keys[i]] is Map ? Map<String, dynamic>.from(arrearData[keys[i]]) : <String, dynamic>{};

    List<dynamic> row = [
      0,
      mainEntry["name"] ?? "",
      mainEntry["panno"] ?? "",
      mainEntry["biometricid"] ?? "",
      mainEntry["designation"] ?? "",
      int.tryParse(arrearEntry["mmother"] ?? "") ?? 0,
      int.tryParse(arrearEntry["mmext1"] ?? "") ?? 0,
      int.tryParse(arrearEntry["jaother"] ?? "") ?? 0,
      int.tryParse(arrearEntry["jaext1"] ?? "") ?? 0,
      int.tryParse(arrearEntry["snother"] ?? "") ?? 0,
      int.tryParse(arrearEntry["snext1"] ?? "") ?? 0,
      int.tryParse(arrearEntry["dfother"] ?? "") ?? 0,
      int.tryParse(arrearEntry["dfext1"] ?? "") ?? 0,
    ];
    if (row.getRange(5, 13).any((value) => value != 0)) {
      dataList.add(row);
    }
    for (int i = 0; i < dataList.length; i++) {
      dataList[i][0] = i + 1;
    }

  }
  return dataList;
}

List<List<dynamic>> getOptimizedData(
    String month,
    Map<String, dynamic> dataMain,
    Map<String, dynamic> monthData,
    Map<String, dynamic> dedData,
    Map<String, dynamic> oldTaxData,
    Map<String, dynamic> newTaxData,
    bool isZero) {

  List<List<dynamic>> dataList = [];
  final keys = dataMain.keys.toList();

  for (int i = 0; i < keys.length; i++) {
    final mainEntry = dataMain[keys[i]] is Map ? Map<String, dynamic>.from(dataMain[keys[i]]) : <String, dynamic>{};
    final monthEntry = monthData[keys[i]] is Map ? Map<String, dynamic>.from(monthData[keys[i]]) : <String, dynamic>{};
    final dedEntry = dedData[keys[i]] is Map ? Map<String, dynamic>.from(dedData[keys[i]]) : <String, dynamic>{};

    int gross = parseValue(monthEntry["gross"]) -
        parseValue(monthEntry["conv"]) -
        parseValue(monthEntry["drive"]) -
        parseValue(monthEntry["uniform"]) +
        parseValue(dedEntry["atccd2"]);

    int tax = parseValue(monthEntry["incometax"]);

    if (month == 'feb') {
      String bio = mainEntry["biometricid"]?.toString() ?? "";
      if (bio.isNotEmpty) {
        int oldVal = 0;
        int newVal = 0;

        if (oldTaxData[bio] is Map) {
          oldVal = parseValue((oldTaxData[bio] as Map)['nitpi']);
        }
        if (newTaxData[bio] is Map) {
          newVal = parseValue((newTaxData[bio] as Map)['nitpi']);
        }
        tax = min(oldVal, newVal);
      } else {
        tax = 0;
      }
    }

    List<dynamic> row = [
      0,
      mainEntry["name"] ?? "",
      mainEntry["panno"] ?? "",
      mainEntry["biometricid"] ?? "",
      mainEntry["designation"] ?? "",
      month.toUpperCase(),
      gross,
      tax,
      "", "", "", ""
    ];

    if ((isZero && row[6] != 0) || (!isZero && row[7] != 0 && row[6] != 0)) {
      dataList.add(row);
    }
  }

  for (int i = 0; i < dataList.length; i++) {
    dataList[i][0] = i + 1;
  }
  return dataList;
}

int parseValue(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return 0;
  return int.tryParse(value.toString()) ?? 0;
}
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
  if (rawMain is! Map) return ;
  final dataMain = Map<String, dynamic>.from(rawMain);

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
    final data = await getData(db, sharedData.userPlace, dataMonths[i], dataMain, isZero);
    sheet.getRangeByIndex(1, 1, 1, 9).merge();
    sheet.getRangeByIndex(1, 1).setText(sharedData.zone.toUpperCase());
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.hAlign = xlsio.HAlignType.center;
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByIndex(1, 1, 1, 9).cellStyle.bold = true;

    sheet.getRangeByIndex(2, 1, 2, 9).merge();
    sheet.getRangeByIndex(2, 1).setText(
        "Details of Salary Payments made and TDS Deduction for financial Year");
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.hAlign = xlsio.HAlignType.center;
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByIndex(2, 1, 2, 9).cellStyle.bold = true;

    final header = [
      "Sl. No.", "NAME AS PAN CARD (IT IS USED FOR IDENTIFICATION OF CORRECT NAME) IN CAPITAL LETTERS", "PAN NO AS PRINTED ON PAN CARD", "BMID NO", "DESIGNATION", "SALARY MONTH",
      "GROSS SALARY EXCLUDING NON TAXABLE", "TAX", "CHALLAN DATE (DD/MM/YYYY)", "SRN", "CHALLAN AMOUNT", "BSR CODE"
    ];
    sheet.importList(header, 3, 1, false);
    sheet.getRangeByIndex(3,1,3,12).cellStyle.wrapText = true;
    sheet.getRangeByIndex(3,1,3,12).autoFit();

    int rowIndex = 4;
    int totalTds = 0, totalGross = 0;

    for (var row in data) {
      sheet.importList(row, rowIndex, 1, false);
      totalGross += parseValue(row[6]);
      totalTds += parseValue(row[7]);
      rowIndex++;
    }


    List<dynamic> totalRow = ["", "", "", "", "", "Total", totalGross, totalTds, "", "", "", ""];
    if (totalRow.length >= 5) {
      sheet.importList(totalRow, rowIndex, 1, false);
    }

    sheet.getRangeByIndex(1, 1, rowIndex, 12).autoFit();
  }

  final xlsio.Worksheet firstSheet = workbook.worksheets[0];
  firstSheet.visibility = xlsio.WorksheetVisibility.hidden;

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb){
    html.AnchorElement(
        href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download','tds.xlsx')
      ..click();

  } else{
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/tds.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}

Future<List<List<dynamic>>> getData(DatabaseReference db, String userPlace, String month, Map<String, dynamic> dataMain, bool isZero) async {
  final monthSnapshot = await db.child(userPlace).child("monthdata").child(month).once();
  final rawMonth = monthSnapshot.snapshot.value;
  if (rawMonth is! Map) return [];
  final monthData = Map<String, dynamic>.from(rawMonth);

  List<List<dynamic>> dataList = [];

  final keys = dataMain.keys.toList();
  for (int i = 0; i < keys.length; i++) {
    final mainEntry = Map<String, dynamic>.from(dataMain[keys[i]]);
    final monthEntry = Map<String, dynamic>.from(monthData[keys[i]]);


    List<dynamic> row = [
      0, // Placeholder for Sl. No.
      mainEntry["name"] ?? "",
      mainEntry["panno"] ?? "",
      mainEntry["biometricid"] ?? "",
      mainEntry["designation"] ?? "",
      month.toUpperCase(),
      parseValue(monthEntry["gross"]) -
          parseValue(monthEntry["conv"]) -
          parseValue(monthEntry["drive"]) -
          parseValue(monthEntry["uniform"]),
      parseValue(monthEntry["incometax"]),
      "", "", "", ""
    ];

    if (month == 'feb') {
      row[7] = await fetchDataFromFirebase(mainEntry["biometricid"]);
    }

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


Future<int> fetchDataFromFirebase(String bio) async {
  if (bio.isEmpty) return 0;

  final db = FirebaseDatabase.instance.ref();
  final oldSnap = await db.child(sharedData.userPlace).child("itaxold").child(bio).once();
  final newSnap = await db.child(sharedData.userPlace).child("itaxnew").child(bio).once();

  final oldRaw = oldSnap.snapshot.value;
  final newRaw = newSnap.snapshot.value;

  if (oldRaw is! Map || newRaw is! Map) return 0;

  final oldData = Map<String, dynamic>.from(oldRaw);
  final newData = Map<String, dynamic>.from(newRaw);

  int oldVal = parseValue(oldData['nitpi']);
  int newVal = parseValue(newData['nitpi']);

  return min(oldVal, newVal);
}



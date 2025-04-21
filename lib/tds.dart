import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:incometax/shared.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;

Future<void> exportExcel() async {
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
    final data = await getData(db, sharedData.userPlace, dataMonths[i], dataMain);

    sheet.getRangeByIndex(1, 1, 1, 9).merge();
    sheet.getRangeByIndex(1, 1).setText(sharedData.zone.toUpperCase());

    sheet.getRangeByIndex(2, 1, 2, 9).merge();
    sheet.getRangeByIndex(2, 1).setText(
        "Details of Salary Payments made and TDS Deduction for financial Year");

    final header = [
      "Sl. No.", "Name of Employee", "PAN NO.", "TDS (Total Tax Deducted)",
      "Gross Salary", "Cheque No. & Date", "CRN No dated", "Amount in Rs/-", "MONTH"
    ];
    sheet.importList(header, 3, 1, false);

    int rowIndex = 4;
    int totalTds = 0, totalGross = 0;

    for (var row in data) {
      if (row.length >= 5) { // Ensure row has at least 5 columns
        sheet.importList(row, rowIndex, 1, false);
        totalTds += parseValue(row[3]);
        totalGross += parseValue(row[4]);
        rowIndex++;
      }
    }


    List<dynamic> totalRow = ["", "", "Total", totalTds, totalGross, "", "", "", ""];
    if (totalRow.length >= 5) {
      sheet.importList(totalRow, rowIndex, 1, false);
    }


    sheet.getRangeByIndex(1, 1, rowIndex, 9).autoFit();
  }

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

Future<List<List<dynamic>>> getData(DatabaseReference db, String userPlace, String month, Map<String, dynamic> dataMain) async {
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
      parseValue(monthEntry["incometax"]),
      parseValue(monthEntry["gross"]) -
          parseValue(monthEntry["conv"]) -
          parseValue(monthEntry["drive"]) -
          parseValue(monthEntry["uniform"]),
      "", "", "", month.toUpperCase()
    ];

    if (month == 'feb') {
      row[3] = await fetchDataFromFirebase(mainEntry["biometricid"]);
    }

    if (row[3] != 0) dataList.add(row);
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

  int oldVal = parseValue(oldData['nitpi']) + parseValue(oldData['ec']);
  int newVal = parseValue(newData['nitpi']) + parseValue(newData['ec']);

  return oldVal < newVal ? oldVal : newVal;
}



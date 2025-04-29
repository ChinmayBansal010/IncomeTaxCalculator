import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:universal_html/html.dart' show AnchorElement;
import 'dart:convert';
import 'dart:io';

final biometricIdController = TextEditingController();
final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
DatabaseReference bioRef = _dbRef.child(sharedData.userPlace);
Map<String, Map<String, dynamic>> biometricData = {};
bool isLoading = true;
bool shouldRefetch = true;
String errorMessage = '';
TextEditingController searchController = TextEditingController();

Map<String?, dynamic> itaxnewData = {};
Map<String?, dynamic> itaxoldData = {};

Map<String?, dynamic> novData = {};
Map<String?, dynamic> decData = {};
Map<String?, dynamic> janData = {};

Future<Object> fetchData() async {
  try {
    DatabaseEvent event = await bioRef.child('maindata').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
      Map<String, Map<String, dynamic>> data = {};

      rawData.forEach((key, value) {
        if (key is String && value is Map) {
          data[key] = Map<String, dynamic>.from(value);
        }
      });
      biometricData = data;
      return {};
    } else {
      return {};
    }
  } catch (e) {
    return e;
  }
}

Future<dynamic> fetchItaxnewdata(String biometricId) async {
  try {
    DatabaseEvent event = await bioRef.child('itaxnew').child(biometricId).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
      Map<String?, dynamic> data = rawData.cast<String, dynamic>();
      itaxnewData = data;
      return{};
    } else {
      return "No Data";
    }
  } catch (error) {
    return error;
  }
}

Future<dynamic> fetchItaxolddata(String biometricId) async {
  try {
    DatabaseEvent event = await bioRef.child('itaxold').child(biometricId).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
      Map<String?, dynamic> data = rawData.cast<String, dynamic>();
      itaxoldData = data;
      return{};
    } else {
      return "No Data";
    }
  } catch (error) {
    return error;
  }
}

Future<Map<String, Map<String?, dynamic>>> fetchAllMonthData(String biometricId) async {
  List<String> months = ['jan', 'nov', 'dec'];
  Map<String, Map<String?, dynamic>> allMonthData = {};

  for (String month in months) {
    Map<String?, dynamic>? data = (await fetchMonthData(month, biometricId)) as Map<String?, dynamic>?;
    allMonthData[month] = data!;
  }

  return allMonthData;
}

Future<Object> fetchMonthData(String month, String biometricId) async {
  try {

    DatabaseEvent event = await bioRef
        .child('monthdata')
        .child(month)
        .child(biometricId)
        .once();

    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
      Map<String?, dynamic> data = rawData.cast<String, dynamic>();

      return data;
    } else {
      return{};
    }
  } catch (error) {
    return error;
  }
}

Future<void> createExcel() async{
  await fetchData();

  final xls.Workbook workbook = xls.Workbook();
  final xls.Worksheet taxSheet = workbook.worksheets[0];

  taxSheet.name = "TAX";

  var sortedEntries = biometricData.entries.toList()
    ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

  Map<String, dynamic> sortedBiometricData = Map.fromEntries(sortedEntries);
  List<String> biometricIds = sortedBiometricData.keys.toList();

  final xls.Style commontextStyle = workbook.styles.add('commontextStyle');
  commontextStyle.fontName = 'Calibri';
  commontextStyle.fontSize = 11;
  commontextStyle.fontColor = '#000000';
  commontextStyle.hAlign = xls.HAlignType.left;
  commontextStyle.vAlign = xls.VAlignType.center;
  commontextStyle.borders.all.color = '#000000';
  commontextStyle.borders.all.lineStyle = xls.LineStyle.thin;
  commontextStyle.wrapText = true;

  final xls.Style commontextStyleBold = workbook.styles.add('commontextStyleBold');
  commontextStyleBold.fontName = 'Calibri';
  commontextStyleBold.fontSize = 11;
  commontextStyleBold.bold = true;
  commontextStyleBold.fontColor = '#000000';
  commontextStyleBold.hAlign = xls.HAlignType.left;
  commontextStyleBold.vAlign = xls.VAlignType.center;
  commontextStyleBold.borders.all.color = '#000000';
  commontextStyleBold.borders.all.lineStyle = xls.LineStyle.thin;


  taxSheet.getRangeByName('A1').setText('Biometric ID');
  taxSheet.getRangeByName('B1').setText('Name');
  taxSheet.getRangeByName('C1').setText('Group');
  taxSheet.getRangeByName('D1').setText('Nov');
  taxSheet.getRangeByName('E1').setText('Dec');
  taxSheet.getRangeByName('F1').setText('Jan');
  taxSheet.getRangeByName('G1').setText('TaxOld');
  taxSheet.getRangeByName('H1').setText('Tax/Excess');
  taxSheet.getRangeByName('I1').setText('TaxNew');
  taxSheet.getRangeByName('J1').setText('Tax/Excess');
  taxSheet.getRangeByName('A1:J1').cellStyle = commontextStyleBold;

  int itaxold = 0;
  String itaxoldpt = 'TAX';
  int itaxnew = 0;
  String itaxnewpt = 'TAX';
  int rowIndex = 2;

  for (int i = 0; i < biometricIds.length; i++) {

    await fetchItaxolddata(biometricIds[i]);
    await fetchItaxnewdata(biometricIds[i]);
    Map<String, Map<String?, dynamic>> monthdata = await fetchAllMonthData(biometricIds[i]);
    novData = monthdata['nov']!;
    decData = monthdata['dec']!;
    janData = monthdata['jan']!;

    String key = biometricIds[i];


    String namevalue = biometricData[key]?['name'] ?? 'Unknown';
    dynamic groupvalue = biometricData[key]?['group'] ?? 'Unknown';
    
    int oldNitpi = int.parse(itaxoldData['nitpi']?.toString() ?? '0');
    int oldExcess = int.parse(itaxoldData['ep']?.toString() ?? '0');

    if (oldNitpi == 0 && oldExcess == 0) {
      itaxold = 0;
      itaxoldpt = 'TAX';
    } else if (oldNitpi >= 0 && oldExcess == 0) {
      itaxold = oldNitpi;
      itaxoldpt = 'TAX';
    } else if (oldNitpi == 0 && oldExcess >= 0) {
      itaxold = oldExcess;
      itaxoldpt = 'EXCESS';
    }

    int newNitpi = int.parse(itaxnewData['nitpi']?.toString() ?? '0');
    int newExcess = int.parse(itaxnewData['ep']?.toString() ?? '0');

    if (newNitpi == 0 && newExcess == 0) {
      itaxnew = 0;
      itaxnewpt = 'TAX';
    } else if (newNitpi >= 0 && newExcess == 0) {
      itaxnew = newNitpi;
      itaxnewpt = 'TAX';
    } else if (newNitpi == 0 && newExcess >= 0) {
      itaxnew = newExcess;
      itaxnewpt = 'EXCESS';
    }

    taxSheet.getRangeByIndex(rowIndex, 1).setValue(biometricIds[i]);
    taxSheet.getRangeByIndex(rowIndex, 2).setValue(namevalue);
    taxSheet.getRangeByIndex(rowIndex, 3).setValue(groupvalue);
    taxSheet.getRangeByIndex(rowIndex, 4).setValue(novData['incometax']);
    taxSheet.getRangeByIndex(rowIndex, 5).setValue(decData['incometax']);
    taxSheet.getRangeByIndex(rowIndex, 6).setValue(janData['incometax']);
    taxSheet.getRangeByIndex(rowIndex, 7).setValue(itaxold);
    taxSheet.getRangeByIndex(rowIndex, 8).setValue(itaxoldpt);
    taxSheet.getRangeByIndex(rowIndex, 9).setValue(itaxnew);
    taxSheet.getRangeByIndex(rowIndex, 10).setValue(itaxnewpt);

    rowIndex++;
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb){
    AnchorElement(
        href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download','tax.xlsx')
      ..click();

  } else{
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/tax.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

}

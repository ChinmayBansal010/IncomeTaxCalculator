import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:incometax/shared.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;

final database = FirebaseDatabase.instance.ref().child(sharedData.userPlace);

Future<Map<String, Map<String, dynamic>>> fetchMainData() async {
  final mainSnap = await database.child("maindata").once();
  final mainMap = Map<String, dynamic>.from(mainSnap.snapshot.value as Map);

  final orderedKeys = [
    "biometricid","name", "fhname", "designation", "dob", "doa", "dort", "group", "category",
    "sex", "address", "aadhaarno", "mobileno", "accountno", "branch", "micrno",
    "ifsc", "panno", "payscale", "level", "gpfno", "npsno","epfno", "esino", "emailid", "cycleno",
    "voterid", "dojo", "place", "bloodgrp", "emergencyno", "nicemailid", "dorn",
    "education", "emptype", "bname", "ext3", "ext4"
  ];

  final Map<String, String> labelMap = {
    "biometricid": "Biometric ID",
    "name": "Name",
    "fhname": "Father/Husband Name",
    "designation": "Designation",
    "dob": "Date of Birth",
    "doa": "Date of Appointment",
    "dort": "Date of Retirement",
    "group": "Group",
    "category": "Category",
    "sex": "Gender",
    "address": "Address",
    "aadhaarno": "Aadhaar No.",
    "mobileno": "Mobile No.",
    "accountno": "Bank Account No.",
    "branch": "Bank Branch",
    "micrno": "MICR No.",
    "ifsc": "IFSC Code",
    "panno": "PAN No.",
    "payscale": "Pay Scale",
    "level": "Pay Level",
    "gpfno": "GPF No.",
    "npsno": "NPS No.",
    "epfno": "EPF No.",
    "esino": "ESI No.",
    "emailid": "Email ID",
    "cycleno": "Cycle No.",
    "voterid": "Voter ID",
    "dojo": "Date of Joining Office",
    "place": "Place",
    "bloodgrp": "Blood Group",
    "emergencyno": "Emergency No.",
    "nicemailid": "NIC Email ID",
    "dorn": "Date of Resignation",
    "education": "Educational",
    "emptype": "Employment Type",
    "bname": "Bank Name",
    "ext3": "Extra Field 3",
    "ext4": "Extra Field 4",
  };

  final mappedData = mainMap.map((key, value) {
    final labeledMap = {
      for (var k in orderedKeys)
        if (value[k] != null) labelMap[k] ?? k: value[k]
    };
    return MapEntry(key, labeledMap);
  });

  return mappedData;
}


Future<Map<String, Map<String?, dynamic>>> fetchAllMonthData() async {
  List<String> months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec'];
  Map<String, Map<String?, dynamic>> allMonthData = {};

  for (String month in months) {
    Map<String?, dynamic> data = await fetchMonthData(month);
    allMonthData[month] = data;
  }

  return allMonthData;
}

Future<Map<String?, dynamic>> fetchMonthData(String month) async {
  try {
    DatabaseEvent event = await database.child('monthdata').child(month).once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final rawData = event;
      final monthMap = Map<String, dynamic>.from(rawData.snapshot.value as Map);

      final orderedKeys = [
        "biometricid", "name", "designation", "bp", "da", "hra", "npa", "splpay", "conv", "pg", "annual",
        "uniform", "nursing", "ta", "daonta", "medical", "dirt", "washing", "tb", "night", "drive", "cycle",
        "pca", "daext1", "daext2", "daext3", "daext4", "gross", "incometax", "gis", "gpf", "nps", "epf", "esi", "slf",
        "society", "recovery", "wf", "other", "ddext1", "ddext2", "ddext3", "ddext4", "totalded", "netsalary",
        "dap", "hrap", "tap", "npap", "gpfchk", "npschk", "epfchk", "esichk"
      ];

      final labelMap = {
        "biometricid": "Biometric ID",
        "name": "Name",
        "designation": "Designation",
        "bp": "Basic Pay",
        "da": "DA",
        "hra": "HRA",
        "npa": "NPA",
        "splpay": "Special Pay",
        "conv": "Conveyance",
        "pg": "PG",
        "annual": "Annual",
        "uniform": "Uniform",
        "nursing": "Nursing",
        "ta": "TA",
        "daonta": "DA on TA",
        "medical": "Medical",
        "dirt": "Contigency",
        "washing": "Washing",
        "tb": "TB",
        "night": "Night",
        "drive": "Drive",
        "cycle": "Cycle",
        "pca": "PCA",
        "daext1": "Extra 1",
        "daext2": "Extra 2",
        "daext3": "Extra 3",
        "daext4": "Extra 4",
        "gross": "Gross Salary",
        "incometax": "Income Tax",
        "gis": "GIS",
        "gpf": "GPF",
        "nps": "NPS",
        "epf": "EPF",
        "esi": "ESI",
        "slf": "SLF",
        "society": "Society",
        "recovery": "Recovery",
        "wf": "W/F Fund",
        "other": "Other",
        "ddext1": "Extra 1",
        "ddext2": "Extra 2",
        "ddext3": "Extra 3",
        "ddext4": "Extra 4",
        "totalded": "Total Deduction",
        "netsalary": "Net Salary",
        "dap": "DA CHK",
        "hrap": "HRA CHK",
        "tap": "TA CHK",
        "npap": "NPA CHK",
        "gpfchk": "GPF CHK",
        "npschk": "NPS CHK",
        "epfchk": "EPF CHK",
        "esichk": "ESI CHK",
      };

      final mappedData = <String, Map<String, dynamic>>{};
      monthMap.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = {
            for (var k in orderedKeys)
              if (innerMap.containsKey(k)) labelMap[k] ?? k: innerMap[k]
          };
          mappedData[key] = labeledMap;
        }
      });
      return mappedData;
    }
    return {};
  } catch (error) {
    return {};
  }
}


Future<Map<String, dynamic>> fetcharrearData() async {
  try {
    DatabaseEvent event = await database.child('arrdata').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final arrData = Map<String, dynamic>.from(event.snapshot.value as Map);

      final orderedKeys = [
        "biometricid","name",
        "mmda","mmhra","mmdaonta","mmpca","mmnpa","mmtution","mmother","mmext1","mmext2","mmext3",
        "jada","jahra","jadaonta","japca","janpa","jatution","jaother","jaext1","jaext2","jaext3",
        "snda","snhra","sndaonta","snpca","snnpa","sntution","snother","snext1","snext2","snext3",
        "dfda","dfhra","dfdaonta","dfpca","dfnpa","dftution","dfother","dfext1","dfext2","dfext3",
        "bonus"
      ];

      final labelMap = {
        "biometricid": "Biometric ID",
        "name": "Name",
        "mmda": "MM DA", "mmhra": "MM HRA", "mmdaonta": "MM DA on TA", "mmpca": "MM PCA", "mmnpa": "MM NPA",
        "mmtution": "MM Tuition", "mmother": "MM Other", "mmext1": "MM Extra 1", "mmext2": "MM Extra 2", "mmext3": "MM Extra 3",
        "jada": "JA DA", "jahra": "JA HRA", "jadaonta": "JA DA on TA", "japca": "JA PCA", "janpa": "JA NPA",
        "jatution": "JA Tuition", "jaother": "JA Other", "jaext1": "JA Extra 1", "jaext2": "JA Extra 2", "jaext3": "JA Extra 3",
        "snda": "SN DA", "snhra": "SN HRA", "sndaonta": "SN DA on TA", "snpca": "SN PCA", "snnpa": "SN NPA",
        "sntution": "SN Tuition", "snother": "SN Other", "snext1": "SN Extra 1", "snext2": "SN Extra 2", "snext3": "SN Extra 3",
        "dfda": "DF DA", "dfhra": "DF HRA", "dfdaonta": "DF DA on TA", "dfpca": "DF PCA", "dfnpa": "DF NPA",
        "dftution": "DF Tuition", "dfother": "DF Other", "dfext1": "DF Extra 1", "dfext2": "DF Extra 2", "dfext3": "DF Extra 3",
        "bonus": "Bonus",
      };

      final mappedData = <String, Map<String, dynamic>>{};
      arrData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = {
            for (var k in orderedKeys)
              if (innerMap.containsKey(k)) labelMap[k] ?? k: innerMap[k]
          };
          mappedData[key] = labeledMap;
        }
      });

      return mappedData;
    } else {
      return {};
    }
  } catch (error) {
    return {};
  }
}


Future<Map<String, dynamic>> fetchdedData() async {
  try {
    DatabaseEvent event = await database.child('deddata').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final dedData = Map<String, dynamic>.from(event.snapshot.value as Map);

      final orderedKeys = [
        "biometricid", "name", "oname", "opan", "po", "ppf", "lic", "hlp",
        "hli", "tution", "cea", "fd", "nsc", "80c", "ulip", "80ccd1", "gpf",
        "gis", "elss", "ssy", "80ccdnps", "80d", "80dp", "80dps", "80u", "80e",
        "relief", "80ee", "rpaid", "taexem", "other", "totalsav",
        "maxsav", "htype", "ext3", "ext4", "ext5"
      ];

      final labelMap = {
        "biometricid": "Biometric ID", "name": "Name", "oname": "O Name", "opan": "O PAN",
        "po": "Post Office", "ppf": "PPF", "lic": "LIC", "hlp": "Home Loan Principal",
        "hli": "Home Loan Interest", "tution": "Tuition", "cea": "CEA", "fd": "FD",
        "nsc": "NSC", "80c": "80C", "ulip": "ULIP", "80ccd1": "80CCD(1)", "gpf": "GPF",
        "gis": "GIS", "elss": "ELSS", "ssy": "SSY", "80ccdnps": "80CCD(NPS)",
        "80d": "80D", "80dp": "80D Parents", "80dps": "80D Parents Senior",
        "80u": "80U", "80e": "80E", "relief": "Relief",
        "80ee": "80EE", "rpaid": "Rent Paid", "taexem": "CONV+CONT+UNIFORM",
        "other": "Other", "totalsav": "Total Savings", "maxsav": "Max Saving",
        "htype": "H Type", "ext3": "Extra 3", "ext4": "Extra 4", "ext5": "Extra 5"
      };

      final mappedData = <String, Map<String, dynamic>>{};
      dedData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = {
            for (var k in orderedKeys)
              if (innerMap.containsKey(k)) labelMap[k] ?? k: innerMap[k]
          };
          mappedData[key] = labeledMap;
        }
      });

      return mappedData;
    } else {
      return {};
    }
  } catch (error) {
    return {};
  }
}


Future<Map<String, dynamic>> fetchitaxNewData() async {
  try {
    DatabaseEvent event = await database.child('itaxnew').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final itfNewData = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        'biometricid', 'tg', 'convdrive', 'uniform', 'gti', 'atccd2',
        'ti', 'sd', 'other', 'tti', 't1', 't2', 't3', 't4',
        't5', 't6', 't7', 'tt', 'sur', 'tl', 'tre', 'ttl', 'ec',
        'ttp', 'deduct', 'nitp', 'relief', 'nitpi', 'ep'
      ];

      final labelMap = {
        'biometricid': 'Biometric ID', 'tg': 'Total Gross', 'convdrive': 'Conv&Cont',
        'uniform': 'Uniform', 'gti': 'Gross Taxable Income', 'atccd2': '80CCD(2)',
        'ti': 'Taxable Income', 'sd': 'Standard Deduction', 'other': 'Other',
        'tti': 'Total Taxable Income', 't1': 'Tax Slab 1', 't2': 'Tax Slab 2', 't3': 'Tax Slab 3',
        't4': 'Tax Slab 4', 't5': 'Tax Slab 5', 't6': 'Tax Slab 6', 't7': 'Tax Slab 7', 'tt': 'Total Tax',
        'sur': 'Surcharge', 'tl': 'Tax Liability', 'tre': 'Tax Rebate', 'ttl': 'Total Tax Liability',
        'ec': 'Cess', 'ttp': 'Total Tax Payble', 'deduct': 'Deductions', 'nitp': 'Net Taxable Income',
        'relief': 'tax Relief', 'nitpi': 'Net Tax Payble', 'ep': 'Excess'
      };

      final mappedData = <String, Map<String, dynamic>>{};
      itfNewData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = {
            for (var k in orderedKeys)
              if (innerMap.containsKey(k)) labelMap[k] ?? k: innerMap[k]
          };
          mappedData[key] = labeledMap;
        }
      });

      return mappedData;
    } else {
      return {};
    }
  } catch (error) {
    return {};
  }
}



Future<Map<String, dynamic>> fetchDaData() async {
  try {
    DatabaseEvent event = await database.child('percentage').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        "jand", "janh", "jann", "febd", "febh", "febn", "mard", "marh", "marn",
        "aprd", "aprh", "aprn", "mayd", "mayh", "mayn", "jund", "junh", "junn",
        "juld", "julh", "juln", "augd", "augh", "augn", "septd", "septh", "septn",
        "octd", "octh", "octn", "novd", "novh", "novn", "decd", "dech", "decn"
      ];

      final labelMap = {
        "jand": "Jan DA", "janh": "Jan HRA", "jann": "Jan NPA",
        "febd": "Feb DA", "febh": "Feb HRA", "febn": "Feb NPA",
        "mard": "Mar DA", "marh": "Mar HRA", "marn": "Mar NPA",
        "aprd": "Apr DA", "aprh": "Apr HRA", "aprn": "Apr NPA",
        "mayd": "May DA", "mayh": "May HRA", "mayn": "May NPA",
        "jund": "Jun DA", "junh": "Jun HRA", "junn": "Jun NPA",
        "juld": "Jul DA", "julh": "Jul HRA", "juln": "Jul NPA",
        "augd": "Aug DA", "augh": "Aug HRA", "augn": "Aug NPA",
        "septd": "Sep DA", "septh": "Sep HRA", "septn": "Sep NPA",
        "octd": "Oct DA", "octh": "Oct HRA", "octn": "Oct NPA",
        "novd": "Nov DA", "novh": "Nov HRA", "novn": "Nov NPA",
        "decd": "Dec DA", "dech": "Dec HRA", "decn": "Dec NPA"
      };

      final orderedMap = {
        for (var key in orderedKeys)
          if (rawData.containsKey(key)) labelMap[key] ?? key: rawData[key]
      };

      return orderedMap;
    } else {
      return {};
    }
  } catch (e) {
    return {};
  }
}




Future<void> exportAll() async {

  Map<String, dynamic> maindata  = await fetchMainData();
  Map<String, dynamic> monthdata = await fetchAllMonthData();
  Map<String, dynamic> mardata = monthdata['mar']!;
  Map<String, dynamic> aprdata = monthdata['apr']!;
  Map<String, dynamic> maydata = monthdata['may']!;
  Map<String, dynamic> jundata = monthdata['jun']!;
  Map<String, dynamic> juldata = monthdata['jul']!;
  Map<String, dynamic> augdata = monthdata['aug']!;
  Map<String, dynamic> septdata = monthdata['sept']!;
  Map<String, dynamic> octdata = monthdata['oct']!;
  Map<String, dynamic> novdata = monthdata['nov']!;
  Map<String, dynamic> decdata = monthdata['dec']!;
  Map<String, dynamic> jandata = monthdata['jan']!;
  Map<String, dynamic> febdata = monthdata['feb']!;
  Map<String, dynamic> arrdata = await fetcharrearData();
  Map<String, dynamic> deddata = await fetchdedData();
  Map<String, dynamic> itaxnewdata = await fetchitaxNewData();
  Map<String, dynamic> dadata = await fetchDaData();


  final workbook = xlsio.Workbook();

  final mainSheet = workbook.worksheets[0];
  final marSheet = workbook.worksheets.add();
  final aprSheet = workbook.worksheets.add();
  final maySheet = workbook.worksheets.add();
  final junSheet = workbook.worksheets.add();
  final julSheet = workbook.worksheets.add();
  final augSheet = workbook.worksheets.add();
  final septSheet = workbook.worksheets.add();
  final octSheet = workbook.worksheets.add();
  final novSheet = workbook.worksheets.add();
  final decSheet = workbook.worksheets.add();
  final janSheet = workbook.worksheets.add();
  final febSheet = workbook.worksheets.add();
  final arrSheet = workbook.worksheets.add();
  final dedSheet = workbook.worksheets.add();
  final itaxnewSheet = workbook.worksheets.add();
  final daSheet = workbook.worksheets.add();

  mainSheet.name = 'Main';
  marSheet.name = 'Mar';
  aprSheet.name = 'Apr';
  maySheet.name = 'May';
  junSheet.name = 'Jun';
  julSheet.name = 'Jul';
  augSheet.name = 'Aug';
  septSheet.name = 'Sept';
  octSheet.name = 'Oct';
  novSheet.name = 'Nov';
  decSheet.name = 'Dec';
  janSheet.name = 'Jan';
  febSheet.name = 'Feb';
  arrSheet.name = 'Arrear';
  dedSheet.name = 'Deduction';
  itaxnewSheet.name = 'ItaxNew';
  daSheet.name = 'DA%';

  var columns = <String>{};

  for (var record in maindata.values) {
    if (record is Map) {
      columns.addAll(record.keys.cast<String>());
    }
  }
  final maincolumns = columns.toList();

  columns = <String>{};

  for (var record in mardata.values) {
    if (record is Map) {
      columns.addAll(record.keys.cast<String>());
    }
  }
  final monthcolumns = columns.toList();


  columns = <String>{};

  for (var record in arrdata.values) {
    if (record is Map) {
      columns.addAll(record.keys.cast<String>());
    }
  }
  final arrcolumns = columns.toList();

  columns = <String>{};

  for (var record in deddata.values) {
    if (record is Map) {
      columns.addAll(record.keys.cast<String>());
    }
  }
  final dedcolumns = columns.toList();

  columns = <String>{};

  for (var record in itaxnewdata.values) {
    if (record is Map) {
      columns.addAll(record.keys.cast<String>());
    }
  }
  final itaxnewcolumns = columns.toList();




  setColumns(mainSheet, maincolumns);
  setColumns(marSheet, monthcolumns);
  setColumns(aprSheet, monthcolumns);
  setColumns(maySheet, monthcolumns);
  setColumns(junSheet, monthcolumns);
  setColumns(julSheet, monthcolumns);
  setColumns(augSheet, monthcolumns);
  setColumns(septSheet, monthcolumns);
  setColumns(octSheet, monthcolumns);
  setColumns(novSheet, monthcolumns);
  setColumns(decSheet, monthcolumns);
  setColumns(janSheet, monthcolumns);
  setColumns(febSheet, monthcolumns);
  setColumns(arrSheet, arrcolumns);
  setColumns(dedSheet, dedcolumns);
  setColumns(itaxnewSheet, itaxnewcolumns);

  setDataValue(mainSheet, maindata);
  setDataValue(marSheet, mardata);
  setDataValue(aprSheet, aprdata);
  setDataValue(maySheet, maydata);
  setDataValue(junSheet, jundata);
  setDataValue(julSheet, juldata);
  setDataValue(augSheet, augdata);
  setDataValue(septSheet, septdata);
  setDataValue(octSheet, octdata);
  setDataValue(novSheet, novdata);
  setDataValue(decSheet, decdata);
  setDataValue(janSheet, jandata);
  setDataValue(febSheet, febdata);
  setDataValue(arrSheet, arrdata);
  setDataValue(dedSheet, deddata);
  setDataValue(itaxnewSheet, itaxnewdata);

  writeDaDataToExcel(dadata,daSheet);



  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  if (kIsWeb){
    html.AnchorElement(
        href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download','data.xlsx')
      ..click();

  } else{
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/data.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

}

void setColumns(xlsio.Worksheet sheet, List<dynamic> columns) {
  for (var colIndex = 0; colIndex < columns.length; colIndex++) {
    sheet.getRangeByIndex(1 , colIndex + 1).setText(columns[colIndex]);
    sheet.getRangeByIndex(1 , colIndex + 1).columnWidth = 15;
    sheet.getRangeByIndex(1 , colIndex + 1).cellStyle.hAlign = xlsio.HAlignType.left;
    sheet.getRangeByIndex(1 , colIndex + 1).cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.getRangeByIndex(1 , colIndex + 1).cellStyle.bold = true;
    sheet.getRangeByIndex(1 , colIndex + 1).cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
  }
}


void setDataValue(xlsio.Worksheet sheet, Map<String, dynamic> data) {
  var rowIndex = 2;
  for (var entry in data.entries){
    var columnIndex=1;
    var rowData = entry.value;
    for(dynamic values in rowData.values){
      sheet.getRangeByIndex(rowIndex, columnIndex).setValue(values);
      sheet.getRangeByIndex(rowIndex, columnIndex).cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      sheet.getRangeByIndex(rowIndex, columnIndex).cellStyle.hAlign = xlsio.HAlignType.left;
      sheet.getRangeByIndex(rowIndex, columnIndex).cellStyle.vAlign = xlsio.VAlignType.center;
      sheet.getRangeByIndex(rowIndex, columnIndex).cellStyle.wrapText = true;
      columnIndex++;
    }
    rowIndex++;
  }
  sheet.getRangeByIndex(1, 1, rowIndex - 1, data.values.first.length).autoFit();
}

void writeDaDataToExcel(Map<String, dynamic> data, xlsio.Worksheet sheet) {
  sheet.getRangeByName('A1').setText('Month');
  sheet.getRangeByName('B1').setText('DA');
  sheet.getRangeByName('C1').setText('HRA');
  sheet.getRangeByName('D1').setText('NPA');

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  int row = 2;
  for (var month in months) {
    sheet.getRangeByIndex(row, 1).setText(month);
    sheet.getRangeByIndex(row, 2).setValue(data['$month DA'] ?? '');
    sheet.getRangeByIndex(row, 3).setValue(data['$month HRA'] ?? '');
    sheet.getRangeByIndex(row, 4).setValue(data['$month NPA'] ?? '');

    for (int col = 1; col <= 4; col++) {
      final cell = sheet.getRangeByIndex(row, col);
      cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;
    }

    row++;
  }

  sheet.getRangeByIndex(1, 1, row - 1, 4).autoFit();
}


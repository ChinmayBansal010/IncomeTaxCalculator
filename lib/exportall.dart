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
  try {
    final mainSnap = await database.child("maindata").once();
    if (!mainSnap.snapshot.exists || mainSnap.snapshot.value == null) {
      return {};
    }
    final mainMap = Map<String, dynamic>.from(mainSnap.snapshot.value as Map);

    final orderedKeys = [
      "biometricid", "name", "fhname", "group", "sex", "designation", "emptype", "place",
      "dob", "doa", "dort", "category", "address", "aadhaarno", "mobileno",
      "bname", "accountno", "branch", "micrno", "ifsc",
      "panno", "payscale", "level", "gpfno", "npsno", "epfno", "esino", "emailid", "cycleno",
      "voterid", "dojo", "bloodgrp", "emergencyno", "nicemailid", "dorn", "dot", "pot", "dod",
      "education"
    ];

    final Map<String, String> labelMap = {
      "biometricid": "Biometric ID",
      "name": "Name",
      "fhname": "Father/Husband Name",
      "group": "Group",
      "sex": "Gender",
      "designation": "Designation",
      "emptype": "Employee Type",
      "place": "Place of Duty",
      "dob": "Date of Birth",
      "doa": "Date of Appointment",
      "dort": "Date of Retirement",
      "category": "Category",
      "address": "Address",
      "aadhaarno": "Aadhaar No.",
      "mobileno": "Mobile No.",
      "bname": "Bank Name",
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
      "cycleno": "Vehicle No.",
      "voterid": "Voter ID",
      "dojo": "Date of Joining Office",
      "bloodgrp": "Blood Group",
      "emergencyno": "Emergency No.",
      "nicemailid": "NIC Email ID",
      "dorn": "Date of Resignation",
      "dot": "Date of Transfer",
      "pot": "Place of Transfer",
      "dod": "Date of Death",
      "education": "Educational",
    };

    final mappedData = <String, Map<String, dynamic>>{};
    mainMap.forEach((key, value) {
      if (value is Map) {
        final innerMap = Map<String, dynamic>.from(value);
        final labeledMap = {
          for (var k in orderedKeys)
            labelMap[k] ?? k: (innerMap[k] != null && innerMap[k].toString() != 'null') ? innerMap[k] : ''
        };
        mappedData[key] = labeledMap;
      }
    });

    return mappedData;
  } catch (error) {
    return {};
  }
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

    if (snapshot.exists && snapshot.value != null) {
      final monthMap = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        "biometricid", "name", "designation", "bp", "da", "hra", "npa", "splpay", "conv", "pg", "annual",
        "uniform", "nursing", "ta", "daonta", "medical", "dirt", "washing", "tb", "night", "drive", "cycle",
        "pca", "ot", "gross", "incometax", "gis", "gpf", "nps", "epf", "esi", "slf",
        "society", "recovery", "wf", "other", "totalded", "netsalary",
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
        "dirt": "Dirt",
        "washing": "Washing",
        "tb": "TB",
        "night": "Night",
        "drive": "Contigency",
        "cycle": "Cycle",
        "pca": "PCA",
        "ot": "OT",
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
              labelMap[k] ?? k: (innerMap[k] != null && innerMap[k].toString() != 'null') ? innerMap[k] : ''
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

    if (snapshot.exists && snapshot.value != null) {
      final arrData = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        "biometricid", "name",

        // Q1 (MM)
        "mmda", "mmhra", "mmdaonta", "mmpca", "mmnpa", "mmtution",
        "mmsplpay", "mmconv", "mmpg", "mmannual", "mmuniform", "mmnursing", "mmmedical",
        "mmdirt", "mmtb", "mmnight", "mmdrive", "mmcycle", "mmot", "mmwashing",
        "mmother", "mmext1",

        // Q2 (JA)
        "jada", "jahra", "jadaonta", "japca", "janpa", "jatution",
        "jasplpay", "jaconv", "japg", "jaannual", "jauniform", "janursing", "jamedical",
        "jadirt", "jatb", "janight", "jadrive", "jacycle", "jaot", "jawashing",
        "jaother", "jaext1",

        // Q3 (SN)
        "snda", "snhra", "sndaonta", "snpca", "snnpa", "sntution",
        "snsplpay", "snconv", "snpg", "snannual", "snuniform", "snnursing", "snmedical",
        "sndirt", "sntb", "snight", "sndrive", "sncycle", "snot", "snwashing",
        "snother", "snext1",

        // Q4 (DF)
        "dfda", "dfhra", "dfdaonta", "dfpca", "dfnpa", "dftution",
        "dfsplpay", "dfconv", "dfpg", "dfannual", "dfuniform", "dfnursing", "dfmedical",
        "dfdirt", "dftb", "dfnight", "dfdrive", "dfcycle", "dfot", "dfwashing",
        "dfother", "dfext1",

        // Adjustments
        "bonus", "previnc", "prevtax"
      ];

      final labelMap = {
        "biometricid": "Biometric ID",
        "name": "Name",

        // Q1
        "mmda": "Q1 DA", "mmhra": "Q1 HRA", "mmdaonta": "Q1 DA on TA", "mmpca": "Q1 PCA", "mmnpa": "Q1 NPA",
        "mmtution": "Q1 Tuition", "mmsplpay": "Q1 Special Pay", "mmconv": "Q1 Conveyance", "mmpg": "Q1 PG",
        "mmannual": "Q1 Annual", "mmuniform": "Q1 Uniform", "mmnursing": "Q1 Nursing", "mmmedical": "Q1 Medical",
        "mmdirt": "Q1 Dirt", "mmtb": "Q1 TB", "mmnight": "Q1 Night", "mmdrive": "Q1 Contingency",
        "mmcycle": "Q1 Cycle", "mmot": "Q1 OT", "mmwashing": "Q1 Washing", "mmother": "Q1 Other", "mmext1": "Q1 Tax",

        // Q2
        "jada": "Q2 DA", "jahra": "Q2 HRA", "jadaonta": "Q2 DA on TA", "japca": "Q2 PCA", "janpa": "Q2 NPA",
        "jatution": "Q2 Tuition", "jasplpay": "Q2 Special Pay", "jaconv": "Q2 Conveyance", "japg": "Q2 PG",
        "jaannual": "Q2 Annual", "jauniform": "Q2 Uniform", "janursing": "Q2 Nursing", "jamedical": "Q2 Medical",
        "jadirt": "Q2 Dirt", "jatb": "Q2 TB", "janight": "Q2 Night", "jadrive": "Q2 Contingency",
        "jacycle": "Q2 Cycle", "jaot": "Q2 OT", "jawashing": "Q2 Washing", "jaother": "Q2 Other", "jaext1": "Q2 Tax",

        // Q3
        "snda": "Q3 DA", "snhra": "Q3 HRA", "sndaonta": "Q3 DA on TA", "snpca": "Q3 PCA", "snnpa": "Q3 NPA",
        "sntution": "Q3 Tuition", "snsplpay": "Q3 Special Pay", "snconv": "Q3 Conveyance", "snpg": "Q3 PG",
        "snannual": "Q3 Annual", "snuniform": "Q3 Uniform", "snnursing": "Q3 Nursing", "snmedical": "Q3 Medical",
        "sndirt": "Q3 Dirt", "sntb": "Q3 TB", "snight": "Q3 Night", "sndrive": "Q3 Contingency",
        "sncycle": "Q3 Cycle", "snot": "Q3 OT", "snwashing": "Q3 Washing", "snother": "Q3 Other", "snext1": "Q3 Tax",

        // Q4
        "dfda": "Q4 DA", "dfhra": "Q4 HRA", "dfdaonta": "Q4 DA on TA", "dfpca": "Q4 PCA", "dfnpa": "Q4 NPA",
        "dftution": "Q4 Tuition", "dfsplpay": "Q4 Special Pay", "dfconv": "Q4 Conveyance", "dfpg": "Q4 PG",
        "dfannual": "Q4 Annual", "dfuniform": "Q4 Uniform", "dfnursing": "Q4 Nursing", "dfmedical": "Q4 Medical",
        "dfdirt": "Q4 Dirt", "dftb": "Q4 TB", "dfnight": "Q4 Night", "dfdrive": "Q4 Contingency",
        "dfcycle": "Q4 Cycle", "dfot": "Q4 OT", "dfwashing": "Q4 Washing", "dfother": "Q4 Other", "dfext1": "Q4 Tax",

        // Additional Adjustments
        "bonus": "Bonus",
        "previnc": "Previous Employer Income",
        "prevtax": "Previous Employer Tax",
      };

      String formatOtherVal(dynamic otherVal, dynamic customListRaw) {
        final baseVal = (otherVal != null && otherVal.toString() != 'null') ? otherVal.toString() : '';
        if (customListRaw is List && customListRaw.isNotEmpty) {
          final customStrs = <String>[];
          for (var c in customListRaw) {
            if (c is Map && c['name'] != null && c['name'].toString().isNotEmpty) {
              customStrs.add("${c['name']}: ${c['amount'] ?? 0}");
            }
          }
          if (customStrs.isNotEmpty) {
            return baseVal.isEmpty ? customStrs.join(', ') : "$baseVal (${customStrs.join(', ')})";
          }
        }
        return baseVal;
      }

      final mappedData = <String, Map<String, dynamic>>{};
      arrData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = <String, dynamic>{};
          for (var k in orderedKeys) {
            final label = labelMap[k] ?? k;
            if (k == 'mmother') {
              labeledMap[label] = formatOtherVal(innerMap[k], innerMap['q1custom']);
            } else if (k == 'jaother') {
              labeledMap[label] = formatOtherVal(innerMap[k], innerMap['q2custom']);
            } else if (k == 'snother') {
              labeledMap[label] = formatOtherVal(innerMap[k], innerMap['q3custom']);
            } else if (k == 'dfother') {
              labeledMap[label] = formatOtherVal(innerMap[k], innerMap['q4custom']);
            } else {
              labeledMap[label] = (innerMap[k] != null && innerMap[k].toString() != 'null') ? innerMap[k] : '';
            }
          }
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

    if (snapshot.exists && snapshot.value != null) {
      final dedData = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        "biometricid", "name", "oname", "opan", "po", "hrr", "ppf", "lic", "hlp",
        "hli", "80g", "tution", "cea", "fd", "nsc", "80c", "ulip", "80ccd1", "gpf",
        "gis", "elss", "ssy", "80ccdnps", "80d", "80dp", "80dps", "80u", "80e",
        "relief", "80ee", "taexem", "other", "totalsav",
        "maxsav"
      ];

      final labelMap = {
        "biometricid": "Biometric ID", "name": "Name", "oname": "O Name", "opan": "O PAN", "hrr": "Rent",
        "po": "Post Office", "ppf": "PPF", "lic": "LIC", "hlp": "Home Loan Principal",
        "hli": "Home Loan Interest", "80g":"80G", "tution": "Tuition", "cea": "CEA", "fd": "FD",
        "nsc": "NSC", "80c": "80C", "ulip": "ULIP", "80ccd1": "80CCD(1)", "gpf": "GPF",
        "gis": "GIS", "elss": "ELSS", "ssy": "SSY", "80ccdnps": "80CCD(1B)",
        "80d": "80D", "80dp": "80DP", "80dps": "80DPS",
        "80u": "80U", "80e": "80E", "relief": "Relief",
        "80ee": "80EE", "taexem": "CONV+CONT+UNIFORM",
        "other": "Other", "totalsav": "Total Savings", "maxsav": "Max Saving"
      };

      final mappedData = <String, Map<String, dynamic>>{};
      dedData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final labeledMap = {
            for (var k in orderedKeys)
              labelMap[k] ?? k: (innerMap[k] != null && innerMap[k].toString() != 'null') ? innerMap[k] : ''
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


Future<Map<String, dynamic>> fetchitaxNewData([Map<String, dynamic>? mainDataMap]) async {
  try {
    DatabaseEvent event = await database.child('itaxnew').once();
    DataSnapshot snapshot = event.snapshot;

    Map<String, dynamic> rawMainMap = {};
    if (mainDataMap != null) {
      rawMainMap = mainDataMap;
    } else {
      final mainSnap = await database.child('maindata').once();
      if (mainSnap.snapshot.exists && mainSnap.snapshot.value != null) {
        rawMainMap = Map<String, dynamic>.from(mainSnap.snapshot.value as Map);
      }
    }

    if (snapshot.exists && snapshot.value != null) {
      final itfNewData = Map<String, dynamic>.from(snapshot.value as Map);

      final orderedKeys = [
        'biometricid', 'name', 'panno', 'tg', 'convdrive', 'uniform', 'gti', 'atccd2',
        'ti', 'sd', 'other', 'tti', 't1', 't2', 't3', 't4',
        't5', 't6', 't7', 'tt', 'sur', 'tl', 'tre', 'ttl', 'ec',
        'ttp', 'deduct', 'nitp', 'relief', 'nitpi', 'ep'
      ];

      final labelMap = {
        'biometricid': 'Biometric ID',
        'name': 'Name',
        'panno': 'PAN Number',
        'tg': 'Total Gross',
        'convdrive': 'Conv&Cont',
        'uniform': 'Uniform',
        'gti': 'Gross Taxable Income',
        'atccd2': '80CCD(2)',
        'ti': 'Taxable Income',
        'sd': 'Standard Deduction',
        'other': 'Other',
        'tti': 'Total Taxable Income',
        't1': 'Tax Slab 1',
        't2': 'Tax Slab 2',
        't3': 'Tax Slab 3',
        't4': 'Tax Slab 4',
        't5': 'Tax Slab 5',
        't6': 'Tax Slab 6',
        't7': 'Tax Slab 7',
        'tt': 'Total Tax',
        'sur': 'Surcharge',
        'tl': 'Tax Liability',
        'tre': 'Tax Rebate',
        'ttl': 'Total Tax Liability',
        'ec': 'Cess',
        'ttp': 'Total Tax Payble',
        'deduct': 'Tax Already Paid',
        'nitp': 'Tax Payble',
        'relief': 'tax Relief',
        'nitpi': 'Net Tax Payble',
        'ep': 'Excess'
      };

      final mappedData = <String, Map<String, dynamic>>{};
      itfNewData.forEach((key, value) {
        if (value is Map) {
          final innerMap = Map<String, dynamic>.from(value);
          final bioId = innerMap['biometricid']?.toString() ?? key;

          final mainRecord = rawMainMap[bioId] ?? rawMainMap[key];
          String name = '';
          String panNo = '';
          if (mainRecord is Map) {
            name = (mainRecord['name'] ?? mainRecord['Name'] ?? '').toString();
            panNo = (mainRecord['panno'] ?? mainRecord['PAN No.'] ?? mainRecord['PAN Number'] ?? '').toString();
          }

          innerMap['name'] = name;
          innerMap['panno'] = panNo;

          final labeledMap = {
            for (var k in orderedKeys)
              labelMap[k] ?? k: innerMap[k] ?? ''
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
  Map<String, dynamic> itaxnewdata = await fetchitaxNewData(maindata);
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

  List<String> getSheetColumns(Map<String, dynamic> dataMap) {
    if (dataMap.isEmpty) return [];
    final first = dataMap.values.first;
    if (first is Map) {
      return first.keys.cast<String>().toList();
    }
    return [];
  }

  final maincolumns = getSheetColumns(maindata);
  final monthcolumns = getSheetColumns(mardata);
  final arrcolumns = getSheetColumns(arrdata);
  final dedcolumns = getSheetColumns(deddata);
  final itaxnewcolumns = getSheetColumns(itaxnewdata);

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

  setDataValue(mainSheet, maindata, addTotalRow: false);
  setDataValue(marSheet, mardata, addTotalRow: true);
  setDataValue(aprSheet, aprdata, addTotalRow: true);
  setDataValue(maySheet, maydata, addTotalRow: true);
  setDataValue(junSheet, jundata, addTotalRow: true);
  setDataValue(julSheet, juldata, addTotalRow: true);
  setDataValue(augSheet, augdata, addTotalRow: true);
  setDataValue(septSheet, septdata, addTotalRow: true);
  setDataValue(octSheet, octdata, addTotalRow: true);
  setDataValue(novSheet, novdata, addTotalRow: true);
  setDataValue(decSheet, decdata, addTotalRow: true);
  setDataValue(janSheet, jandata, addTotalRow: true);
  setDataValue(febSheet, febdata, addTotalRow: true);
  setDataValue(arrSheet, arrdata, addTotalRow: true);
  setDataValue(dedSheet, deddata, addTotalRow: true);
  setDataValue(itaxnewSheet, itaxnewdata, addTotalRow: true);

  writeDaDataToExcel(dadata, daSheet);

  final allSheets = [
    mainSheet, marSheet, aprSheet, maySheet, junSheet, julSheet,
    augSheet, septSheet, octSheet, novSheet, decSheet, janSheet,
    febSheet, arrSheet, dedSheet, itaxnewSheet, daSheet,
  ];

  for (final s in allSheets) {
    s.getRangeByIndex(2, 3).freezePanes();
  }

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

final Set<String> _dateHeaders = {
  'Date of Birth', 'Date of Appointment', 'Date of Retirement',
  'Date of Joining Office', 'Date of Resignation', 'Date of Transfer',
  'Date of Death', 'dob', 'doa', 'dort', 'dojo', 'dorn', 'dot', 'dod'
};

final Set<String> _codeCenterHeaders = {
  'Biometric ID', 'Gender', 'Group', 'Category', 'Pay Level', 'Aadhaar No.',
  'Mobile No.', 'Bank Account No.', 'MICR No.', 'IFSC Code', 'PAN No.',
  'PAN Number', 'GPF No.', 'NPS No.', 'EPF No.', 'ESI No.', 'Vehicle No.',
  'Voter ID', 'Blood Group', 'Emergency No.', 'DA CHK', 'HRA CHK', 'TA CHK',
  'NPA CHK', 'GPF CHK', 'NPS CHK', 'EPF CHK', 'ESI CHK', 'dap', 'hrap',
  'tap', 'npap', 'gpfchk', 'npschk', 'epfchk', 'esichk'
};

final Set<String> _nonNumericHeaders = {
  'Biometric ID', 'Name', 'Designation', 'Employee Type', 'Place of Duty',
  'Father/Husband Name', 'Date of Birth', 'Date of Appointment', 'Date of Retirement',
  'Group', 'Category', 'Gender', 'Address', 'Aadhaar No.', 'Mobile No.',
  'Bank Account No.', 'Bank Branch', 'MICR No.', 'IFSC Code', 'PAN No.', 'PAN Number',
  'Pay Scale', 'Pay Level', 'GPF No.', 'NPS No.', 'EPF No.', 'ESI No.', 'Email ID',
  'Vehicle No.', 'Voter ID', 'Date of Joining Office', 'Blood Group', 'Emergency No.',
  'NIC Email ID', 'Date of Resignation', 'Date of Transfer', 'Place of Transfer',
  'Date of Death', 'Educational', 'Bank Name', 'O Name', 'O PAN', 'Post Office',
  'DA CHK', 'HRA CHK', 'TA CHK', 'NPA CHK', 'GPF CHK', 'NPS CHK', 'EPF CHK', 'ESI CHK',
  'dap', 'hrap', 'tap', 'npap', 'gpfchk', 'npschk', 'epfchk', 'esichk',
};

xlsio.HAlignType _getColumnHAlign(String colHeader) {
  if (_dateHeaders.contains(colHeader) || _codeCenterHeaders.contains(colHeader)) {
    return xlsio.HAlignType.center;
  }
  if (_nonNumericHeaders.contains(colHeader)) {
    return xlsio.HAlignType.left;
  }
  return xlsio.HAlignType.right;
}

bool _isNumericColumn(String colHeader) {
  return !_nonNumericHeaders.contains(colHeader);
}

void setColumns(xlsio.Worksheet sheet, List<dynamic> columns) {
  sheet.getRangeByIndex(1, 1).rowHeight = 26;
  for (var colIndex = 0; colIndex < columns.length; colIndex++) {
    final colName = columns[colIndex].toString();
    final cell = sheet.getRangeByIndex(1, colIndex + 1);
    cell.setText(colName);
    cell.cellStyle.backColor = '#1E3A8A';
    cell.cellStyle.fontColor = '#FFFFFF';
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 11;
    cell.cellStyle.fontName = 'Segoe UI';
    cell.cellStyle.hAlign = _getColumnHAlign(colName);
    cell.cellStyle.vAlign = xlsio.VAlignType.center;
    cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    cell.cellStyle.borders.all.color = '#1E40AF';
  }
}

void setDataValue(xlsio.Worksheet sheet, Map<String, dynamic> data, {bool addTotalRow = false}) {
  if (data.isEmpty) return;
  final firstRow = data.values.first;
  if (firstRow is! Map) return;
  final columnHeaders = firstRow.keys.toList().cast<String>();

  var rowIndex = 2;
  for (var entry in data.entries) {
    var rowData = entry.value;
    if (rowData is Map) {
      sheet.getRangeByIndex(rowIndex, 1).rowHeight = 20;
      final isEvenRow = (rowIndex % 2 == 0);
      final rowBgColor = isEvenRow ? '#FFFFFF' : '#F8FAFC';

      for (var colIndex = 0; colIndex < columnHeaders.length; colIndex++) {
        final colHeader = columnHeaders[colIndex];
        final rawVal = rowData[colHeader] ?? '';
        final cell = sheet.getRangeByIndex(rowIndex, colIndex + 1);
        final isNum = _isNumericColumn(colHeader);

        cell.cellStyle.backColor = rowBgColor;
        cell.cellStyle.fontSize = 10;
        cell.cellStyle.fontName = 'Segoe UI';
        cell.cellStyle.fontColor = '#0F172A';
        cell.cellStyle.vAlign = xlsio.VAlignType.center;
        cell.cellStyle.hAlign = _getColumnHAlign(colHeader);
        cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
        cell.cellStyle.borders.all.color = '#E2E8F0';

        if (isNum && rawVal != null && rawVal.toString().trim().isNotEmpty && rawVal.toString().trim() != 'null') {
          final strVal = rawVal.toString().trim();
          final numVal = double.tryParse(strVal);
          if (numVal != null) {
            if (numVal == numVal.roundToDouble()) {
              cell.setValue(numVal.round());
            } else {
              cell.setValue(numVal);
            }
            cell.cellStyle.numberFormat = '#,##0';
          } else {
            cell.setValue(rawVal);
          }
        } else {
          cell.setValue(rawVal);
        }
      }
      rowIndex++;
    }
  }

  if (addTotalRow) {
    final totalRowIndex = rowIndex;
    sheet.getRangeByIndex(totalRowIndex, 1).rowHeight = 22;

    for (var colIndex = 0; colIndex < columnHeaders.length; colIndex++) {
      final colHeader = columnHeaders[colIndex];
      final cell = sheet.getRangeByIndex(totalRowIndex, colIndex + 1);
      final isNum = _isNumericColumn(colHeader);

      cell.cellStyle.backColor = '#E0F2FE';
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.fontName = 'Segoe UI';
      cell.cellStyle.fontColor = '#1E3A8A';
      cell.cellStyle.vAlign = xlsio.VAlignType.center;
      cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.borders.all.color = '#94A3B8';

      if (colIndex == 0) {
        cell.setText("TOTAL");
        cell.cellStyle.hAlign = xlsio.HAlignType.left;
      } else if (!isNum) {
        cell.setText("");
        cell.cellStyle.hAlign = xlsio.HAlignType.center;
      } else {
        double colSum = 0;
        bool hasValidNumber = false;
        for (var entry in data.entries) {
          var rowData = entry.value;
          if (rowData is Map) {
            var rawVal = rowData[colHeader];
            if (rawVal != null) {
              var strVal = rawVal.toString().trim();
              if (strVal.isNotEmpty && strVal != 'null') {
                var parsed = double.tryParse(strVal);
                if (parsed != null) {
                  colSum += parsed;
                  hasValidNumber = true;
                }
              }
            }
          }
        }

        if (hasValidNumber) {
          if (colSum == colSum.roundToDouble()) {
            cell.setValue(colSum.round());
          } else {
            cell.setValue(colSum);
          }
          cell.cellStyle.numberFormat = '#,##0';
          cell.cellStyle.hAlign = xlsio.HAlignType.right;
        } else {
          cell.setText("");
          cell.cellStyle.hAlign = xlsio.HAlignType.center;
        }
      }
    }
    rowIndex++;
  }

  sheet.getRangeByIndex(1, 1, rowIndex - 1, columnHeaders.length).autoFit();
  for (var colIndex = 0; colIndex < columnHeaders.length; colIndex++) {
    final range = sheet.getRangeByIndex(1, colIndex + 1);
    if (range.columnWidth < 14) {
      range.columnWidth = 14;
    }
  }
}

void writeDaDataToExcel(Map<String, dynamic> data, xlsio.Worksheet sheet) {
  sheet.getRangeByName('A1').setText('Month');
  sheet.getRangeByName('B1').setText('DA');
  sheet.getRangeByName('C1').setText('HRA');
  sheet.getRangeByName('D1').setText('NPA');

  sheet.getRangeByIndex(1, 1).rowHeight = 26;
  for (int col = 1; col <= 4; col++) {
    final cell = sheet.getRangeByIndex(1, col);
    cell.cellStyle.backColor = '#1E3A8A';
    cell.cellStyle.fontColor = '#FFFFFF';
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 11;
    cell.cellStyle.fontName = 'Segoe UI';
    cell.cellStyle.hAlign = col == 1 ? xlsio.HAlignType.center : xlsio.HAlignType.right;
    cell.cellStyle.vAlign = xlsio.VAlignType.center;
    cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    cell.cellStyle.borders.all.color = '#1E40AF';
  }

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  int row = 2;
  for (var month in months) {
    sheet.getRangeByIndex(row, 1).rowHeight = 20;
    final isEvenRow = (row % 2 == 0);
    final rowBgColor = isEvenRow ? '#FFFFFF' : '#F8FAFC';

    sheet.getRangeByIndex(row, 1).setText(month);
    sheet.getRangeByIndex(row, 2).setValue(data['$month DA'] ?? '');
    sheet.getRangeByIndex(row, 3).setValue(data['$month HRA'] ?? '');
    sheet.getRangeByIndex(row, 4).setValue(data['$month NPA'] ?? '');

    for (int col = 1; col <= 4; col++) {
      final cell = sheet.getRangeByIndex(row, col);
      cell.cellStyle.backColor = rowBgColor;
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.fontName = 'Segoe UI';
      cell.cellStyle.fontColor = '#0F172A';
      cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.borders.all.color = '#E2E8F0';
      cell.cellStyle.hAlign = col == 1 ? xlsio.HAlignType.center : xlsio.HAlignType.right;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;
    }

    row++;
  }

  sheet.getRangeByIndex(1, 1, row - 1, 4).autoFit();
  for (int col = 1; col <= 4; col++) {
    final range = sheet.getRangeByIndex(1, col);
    if (range.columnWidth < 14) {
      range.columnWidth = 14;
    }
  }
}


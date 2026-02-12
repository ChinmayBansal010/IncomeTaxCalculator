import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';

class DeductionAllPage {
  String biometricId;
  String name;
  String hrr;
  String oname;
  String opan;
  String po;
  String ppf;
  String lic;
  String hlp;
  String hli;
  String atg;
  String tution;
  String cea;
  String fd;
  String nsc;
  String atc;
  String ulip;
  String atccd1;
  String gpf;
  String gis;
  String elss;
  String ssy;
  String atccdnps;
  String atd;
  String atdp;
  String atdps;
  String atu;
  String ate;
  String relief;
  String atee;
  String rpaid;
  String convcontuniform;
  String other;
  String atccd2;
  String totalsav;
  String maxsav;
  String htype;
  String rent;
  String ext3;
  String ext4;
  String ext5;

   DeductionAllPage({
    required this.biometricId,
    required this.name,
    required this.hrr,
    required this.oname,
    required this.opan,
    required this.po,
    required this.ppf,
    required this.lic,
    required this.hlp,
    required this.hli,
    required this.atg,
    required this.tution,
    required this.cea,
    required this.fd,
    required this.nsc,
    required this.atc,
    required this.ulip,
    required this.atccd1,
    required this.gpf,
    required this.gis,
    required this.elss,
    required this.ssy,
    required this.atccdnps,
    required this.atd,
    required this.atdp,
    required this.atdps,
    required this.atu,
    required this.ate,
    required this.relief,
    required this.atee,
    required this.rpaid,
    required this.convcontuniform,
    required this.other,
    required this.atccd2,
    required this.totalsav,
    required this.maxsav,
    required this.htype,
    required this.rent,
    required this.ext3,
    required this.ext4,
    required this.ext5,

  });

  int gis2 = 0, gpf2 = 0, atccd12 = 0, atccd22 = 0, taexem2 = 0;
  bool isCea = false;
  bool isLoading = true;
  bool shouldRefetch = true;
  bool isEnabled = true;
  String errorMessage = '';
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);
  final List<String> months = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];


  Future<void> initializeData() async {
    await Future.wait(months.map((month) => fetchMonthData(month)));
    gis = gis2.toString();
    gpf = gpf2.toString();
    atccd1 = atccd12.toString();
    convcontuniform = taexem2.toString();
    await fetchArrData();
    await saveData();
  }

  Future<void> fetchMonthData(var month) async {
    try {
      DatabaseEvent event = await database.child(sharedData.userPlace).child('monthdata').child(month).child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> monthData = snapshot.value as Map<dynamic, dynamic>;

        // Parse values with default 0 if parsing fails
        final nps = int.tryParse(monthData['nps'] ?? '0') ?? 0;
        final bp = int.tryParse(monthData['bp'] ?? '0') ?? 0;
        final da = int.tryParse(monthData['da'] ?? '0') ?? 0;
        final npa = int.tryParse(monthData['npa'] ?? '0') ?? 0;
        final gisValue = int.tryParse(monthData['gis'] ?? '0') ?? 0;
        final gpfValue = int.tryParse(monthData['gpf'] ?? '0') ?? 0;
        final drive = int.tryParse(monthData['drive'] ?? '0') ?? 0;
        final conv = int.tryParse(monthData['conv'] ?? '0') ?? 0;
        final uniform = int.tryParse(monthData['uniform'] ?? '0') ?? 0;

        // Update fields conditionally
        if (nps > 0) {
          atccd22 += ((bp + da + npa)*0.14).round();
        }

        gis2 += gisValue;
        gpf2 += gpfValue;
        atccd12 += nps;
        taexem2 += drive+conv+uniform;

      }
    } catch (e) {
      return;
    }
  }


  Future<void> fetchArrData() async {
    try {
      DatabaseEvent event = await database.child(sharedData.userPlace).child('arrdata').child(biometricId).once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> arrData = snapshot.value as Map<dynamic, dynamic>;
        // Parse the values once and check for null
        final mmtution = int.tryParse(arrData['mmtution'] ?? '0') ?? 0;
        final jatution = int.tryParse(arrData['jatution'] ?? '0') ?? 0;
        final sntution = int.tryParse(arrData['sntution'] ?? '0') ?? 0;
        final dftution = int.tryParse(arrData['dftution'] ?? '0') ?? 0;

        // Set isCea based on the sum of values
        isCea = (mmtution + jatution + sntution + dftution) > 0;
      }
    } catch (e) {
      return;
    }
  }

  Future<void> saveData() async {
    await _validateValue();
    await _calculateData();

    try {
      await bioRef.child('deddata').child(biometricId).update({
        'biometricid': biometricId,
        'name': name,
        'hrr': hrr,
        'oname': oname,
        'opan': opan,
        'po': po,
        'ppf': ppf,
        'lic': lic,
        'hlp': hlp,
        'hli': hli,
        '80g': atg,
        'tution': tution,
        'cea': cea,
        'fd': fd,
        'nsc': nsc,
        '80c': atc,
        'ulip': ulip,
        '80ccd1': atccd1,
        'gpf': gpf,
        'gis': gis,
        'elss': elss,
        'ssy': ssy,
        '80ccdnps': atccdnps,
        '80d': atd,
        '80dp': atdp,
        '80dps': atdps,
        '80u': atu,
        '80e': ate,
        'relief': relief,
        '80ee': atee,
        'rpaid': rpaid,
        'taexem': convcontuniform,
        'other': other,
        '80ccd2': atccd2,
        'totalsav': totalsav,
        'maxsav': maxsav,
        'htype': htype,
        'rent': rent,
        'ext3': ext3,
        'ext4': ext4,
        'ext5': ext5,
      });
    } catch (error) {
      return;
    }

  }

  Future<void> _validateValue() async{
    if ((int.tryParse(hli) ?? 0)> 200000) {
      hli = '200000';
    } else if ((int.tryParse(atccdnps) ?? 0) > 50000) {
      atccdnps = '50000';
    } else if ((int.tryParse(atdp)?? 0) > 50000) {
      atdp = '50000';
    }else if ((int.tryParse(atdps) ?? 0) > 50000) {
      atdps = '50000';
    }else if ((int.tryParse(atd) ?? 0)> 25000) {
      atd = '25000';
    }
  }

  Future<void> _calculateData() async{
     int po2 = int.tryParse(po) ?? 0;
     int ppf2 = int.tryParse(ppf) ?? 0;
     int lic2 = int.tryParse(lic) ?? 0;
     int hlp2 = int.tryParse(hlp) ?? 0;
     int tution2 = int.tryParse(tution) ?? 0;
     int fd2 = int.tryParse(fd) ?? 0;
     int nsc2 = int.tryParse(nsc) ?? 0;
     int atc2 = int.tryParse(atc) ?? 0;
     int ulip2 = int.tryParse(ulip) ?? 0;
     int atccd12 = int.tryParse(atccd1) ?? 0;
     int gpf2 = int.tryParse(gpf) ?? 0;
     int gis2 = int.tryParse(gis) ?? 0;
     int elss2 = int.tryParse(elss) ?? 0;
     int ssy2 = int.tryParse(ssy) ?? 0;
     int ext32 = int.tryParse(ext3) ?? 0;
     int totalsav2 = po2 + ppf2 + lic2 + hlp2 + tution2 + fd2 + nsc2 + atc2 + ulip2 + atccd12 + gpf2 + gis2 + elss2 + ssy2 + ext32;
     totalsav = totalsav2.toString();
    if (totalsav2 > 150000){
      maxsav = '150000';
    } else {
      maxsav = totalsav;
    }
  }
}
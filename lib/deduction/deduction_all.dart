import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';

class DeductionAllPage {
  final String biometricId;
  final String name;
  final String hrr;
  final String oname;
  final String opan;
  final String po;
  final String ppf;
  final String lic;
  final String hlp;
  final String hli;
  final String atg;
  final String tution;
  final String cea;
  final String fd;
  final String nsc;
  final String atc;
  final String ulip;
  final String atccd1;
  final String gpf;
  final String gis;
  final String elss;
  final String ssy;
  final String atccdnps;
  final String atd;
  final String atdp;
  final String atdps;
  final String atu;
  final String ate;
  final String relief;
  final String atee;
  final String rpaid;
  final String taexem;
  final String other;
  final String atccd2;
  final String totalsav;
  final String maxsav;
  final String htype;
  final String rent;
  final String ext3;
  final String ext4;
  final String ext5;

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
    required this.taexem,
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
  // Text controllers for form inputs
  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();
  final hrrController = TextEditingController();
  final onameController = TextEditingController();
  final opanController = TextEditingController();
  final poController = TextEditingController();
  final ppfController = TextEditingController();
  final licController = TextEditingController();
  final hlpController = TextEditingController();
  final hliController = TextEditingController();
  final atgController = TextEditingController();
  final tutionController = TextEditingController();
  final ceaController = TextEditingController();
  final fdController = TextEditingController();
  final nscController = TextEditingController();
  final atcController = TextEditingController();
  final ulipController = TextEditingController();
  final atccd1Controller = TextEditingController();
  final gpfController = TextEditingController();
  final gisController = TextEditingController();
  final elssController = TextEditingController();
  final ssyController = TextEditingController();
  final atccdnpsController = TextEditingController();
  final atdController = TextEditingController();
  final atdpController = TextEditingController();
  final atdpsController = TextEditingController();
  final atuController = TextEditingController();
  final ateController = TextEditingController();
  final reliefController = TextEditingController();
  final ateeController = TextEditingController();
  final rpaidController = TextEditingController();
  final taexemController = TextEditingController();
  final otherController = TextEditingController();
  final atccd2Controller = TextEditingController();
  final totalsavController = TextEditingController();
  final maxsavController = TextEditingController();
  late String htypeController = 'SELF';
  final rentController = TextEditingController();
  final ext3Controller = TextEditingController();
  final ext4Controller = TextEditingController();
  final ext5Controller = TextEditingController();

  int gis2 = 0, gpf2 = 0, atccd12 = 0, atccd22 = 0;
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

    await fetchArrData();
    debugPrint("initialization called");

    atccd1Controller.text = atccd12.toString();
    gpfController.text = gpf2.toString();
    gisController.text = gis2.toString();
    atccd2Controller.text = atccd22.toString();


    biometricIdController.text = biometricId;
    nameController.text = name;
    hrrController.text = hrr;
    onameController.text = oname;
    opanController.text = opan;
    poController.text = po;
    ppfController.text = ppf;
    licController.text = lic;
    hlpController.text = hlp;
    hliController.text = hli;
    atgController.text = atg;
    tutionController.text = tution;
    ceaController.text = cea;
    fdController.text = fd;
    nscController.text = nsc;
    atcController.text = atc;
    ulipController.text = ulip;
    elssController.text = elss;
    ssyController.text = ssy;
    atccdnpsController.text = atccdnps;
    atdController.text = atd;
    atdpController.text = atdp;
    atdpsController.text = atdps;
    atuController.text = atu;
    ateController.text = ate;
    reliefController.text = relief;
    ateeController.text = atee;
    rpaidController.text = rpaid;
    otherController.text = other;
    totalsavController.text = totalsav;
    maxsavController.text = maxsav;
    htypeController = htype;
    rentController.text = rent;
    ext3Controller.text = ext3;
    ext4Controller.text = ext4;
    ext5Controller.text = ext5;

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

        // Update fields conditionally
        if (nps > 0) {
          atccd22 += bp + da + npa;
        }

        gis2 += gisValue;
        gpf2 += gpfValue;
        atccd12 += nps;

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
      await bioRef.child('deddata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,
        'hrr': hrrController.text,
        'oname': onameController.text,
        'opan': opanController.text,
        'po': poController.text,
        'ppf': ppfController.text,
        'lic': licController.text,
        'hlp': hlpController.text,
        'hli': hliController.text,
        'atg': atgController.text,
        'tution': tutionController.text,
        'cea': ceaController.text,
        'fd': fdController.text,
        'nsc': nscController.text,
        '80c': atcController.text,
        'ulip': ulipController.text,
        '80ccd1': atccd1Controller.text,
        'gpf': gpfController.text,
        'gis': gisController.text,
        'elss': elssController.text,
        'ssy': ssyController.text,
        '80ccdnps': atccdnpsController.text,
        '80d': atdController.text,
        '80dp': atdpController.text,
        '80dps': atdpsController.text,
        '80u': atuController.text,
        '80e': ateController.text,
        'relief': reliefController.text,
        '80ee': ateeController.text,
        'rpaid': rpaidController.text,
        '80ccd2': atccd2Controller.text,
        'totalsav': totalsavController.text,
        'maxsav': maxsavController.text,
        'htype': htypeController,
        'rent': rentController.text,
        'ext3': ext3Controller.text,
        'ext4': ext4Controller.text,
        'ext5': ext5Controller.text,
      });

    } catch (error) {
      return;
    }

  }

  Future<void> _validateValue() async{
    if (htypeController == 'SELF' && (int.tryParse(hliController.text) ?? 0)> 200000) {
      hliController.text = '200000';
    } else if ((int.tryParse(atccdnpsController.text) ?? 0) > 50000) {
      atccdnpsController.text = '50000';
    } else if ((int.tryParse(atdpController.text)?? 0) > 50000) {
      atdpController.text = '50000';
    }else if ((int.tryParse(atdpsController.text) ?? 0) > 50000) {
      atdpsController.text = '50000';
    }else if ((int.tryParse(atdController.text) ?? 0)> 25000) {
      atdController.text = '25000';
    }
  }
  
  Future<void> _calculateData() async{
    final po = int.tryParse(poController.text) ?? 0;
    final ppf = int.tryParse(ppfController.text) ?? 0;
    final lic = int.tryParse(licController.text) ?? 0;
    final hlp = int.tryParse(hlpController.text) ?? 0;
    final tution = int.tryParse(tutionController.text) ?? 0;
    final fd = int.tryParse(fdController.text) ?? 0;
    final nsc = int.tryParse(nscController.text) ?? 0;
    final atc = int.tryParse(atcController.text) ?? 0;
    final ulip = int.tryParse(ulipController.text) ?? 0;
    final atccd1 = int.tryParse(atccd1Controller.text) ?? 0;
    final gpf = int.tryParse(gpfController.text) ?? 0;
    final gis = int.tryParse(gisController.text) ?? 0;
    final elss = int.tryParse(elssController.text) ?? 0;
    final ssy = int.tryParse(ssyController.text) ?? 0;
    final ext3 = int.tryParse(ext3Controller.text) ?? 0;
    final totalsav = po + ppf + lic + hlp + tution + fd + nsc + atc + ulip + atccd1 + gpf + gis + elss + ssy + ext3;
    totalsavController.text = totalsav.toString();
    if (totalsav > 150000){
      maxsavController.text = '150000';
    } else {
      maxsavController.text = totalsavController.text;
    }
    debugPrint(totalsavController.text);
  }
}
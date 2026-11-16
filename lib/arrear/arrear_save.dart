import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/date_utils.dart';
import 'package:incometax/shared.dart';

class CustomOtherEntry {
  String id;
  TextEditingController nameController;
  TextEditingController amountController;

  CustomOtherEntry({
    required this.id,
    required String name,
    required String amount,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  Map<String, String> toMap() => {
        'name': nameController.text.trim(),
        'amount': amountController.text.trim(),
      };
}

class _ArrearFieldSpec {
  final String fieldKey;
  final TextEditingController controller;
  final Widget widget;
  _ArrearFieldSpec({required this.fieldKey, required this.controller, required this.widget});
}

class ArrearUpdatePage extends StatefulWidget {
  final String biometricId;
  final String name;
  final Map<String, dynamic>? arrearDataMap;

  // Quarterly fields
  final String mmda, mmhra, mmdaonta, mmpca, mmnpa, mmtution, mmother, mmext1, mmext2, mmext3;
  final String mmsplpay, mmconv, mmpg, mmannual, mmuniform, mmnursing, mmmedical, mmdirt, mmtb, mmnight, mmdrive, mmcycle, mmot, mmwashing;

  final String jada, jahra, jadaonta, japca, janpa, jatution, jaother, jaext1, jaext2, jaext3;
  final String jasplpay, jaconv, japg, jaannual, jauniform, janursing, jamedical, jadirt, jatb, janight, jadrive, jacycle, jaot, jawashing;

  final String snda, snhra, sndaonta, snpca, snnpa, sntution, snother, snext1, snext2, snext3;
  final String snsplpay, snconv, snpg, snannual, snuniform, snnursing, snmedical, sndirt, sntb, snight, sndrive, sncycle, snot, snwashing;

  final String dfda, dfhra, dfdaonta, dfpca, dfnpa, dftution, dfother, dfext1, dfext2, dfext3;
  final String dfsplpay, dfconv, dfpg, dfannual, dfuniform, dfnursing, dfmedical, dfdirt, dftb, dfnight, dfdrive, dfcycle, dfot, dfwashing;

  final String bonus, previnc, prevtax;

  const ArrearUpdatePage({
    super.key,
    required this.biometricId,
    required this.name,
    this.arrearDataMap,

    this.mmda = '0', this.mmhra = '0', this.mmdaonta = '0', this.mmpca = '0', this.mmnpa = '0', this.mmtution = '0', this.mmother = '0', this.mmext1 = '0', this.mmext2 = '0', this.mmext3 = '0',
    this.mmsplpay = '0', this.mmconv = '0', this.mmpg = '0', this.mmannual = '0', this.mmuniform = '0', this.mmnursing = '0', this.mmmedical = '0', this.mmdirt = '0', this.mmtb = '0', this.mmnight = '0', this.mmdrive = '0', this.mmcycle = '0', this.mmot = '0', this.mmwashing = '0',

    this.jada = '0', this.jahra = '0', this.jadaonta = '0', this.japca = '0', this.janpa = '0', this.jatution = '0', this.jaother = '0', this.jaext1 = '0', this.jaext2 = '0', this.jaext3 = '0',
    this.jasplpay = '0', this.jaconv = '0', this.japg = '0', this.jaannual = '0', this.jauniform = '0', this.janursing = '0', this.jamedical = '0', this.jadirt = '0', this.jatb = '0', this.janight = '0', this.jadrive = '0', this.jacycle = '0', this.jaot = '0', this.jawashing = '0',

    this.snda = '0', this.snhra = '0', this.sndaonta = '0', this.snpca = '0', this.snnpa = '0', this.sntution = '0', this.snother = '0', this.snext1 = '0', this.snext2 = '0', this.snext3 = '0',
    this.snsplpay = '0', this.snconv = '0', this.snpg = '0', this.snannual = '0', this.snuniform = '0', this.snnursing = '0', this.snmedical = '0', this.sndirt = '0', this.sntb = '0', this.snight = '0', this.sndrive = '0', this.sncycle = '0', this.snot = '0', this.snwashing = '0',

    this.dfda = '0', this.dfhra = '0', this.dfdaonta = '0', this.dfpca = '0', this.dfnpa = '0', this.dftution = '0', this.dfother = '0', this.dfext1 = '0', this.dfext2 = '0', this.dfext3 = '0',
    this.dfsplpay = '0', this.dfconv = '0', this.dfpg = '0', this.dfannual = '0', this.dfuniform = '0', this.dfnursing = '0', this.dfmedical = '0', this.dfdirt = '0', this.dftb = '0', this.dfnight = '0', this.dfdrive = '0', this.dfcycle = '0', this.dfot = '0', this.dfwashing = '0',

    this.bonus = '0',
    this.previnc = '0',
    this.prevtax = '0',
  });

  @override
  State<ArrearUpdatePage> createState() => ArrearUpdatePageState();
}

class ArrearUpdatePageState extends State<ArrearUpdatePage> with SingleTickerProviderStateMixin {
  final Map<String, FocusNode> _focusNodes = {};
  final Set<String> _zeroSectionFieldKeys = {};

  FocusNode _getFocusNode(String key) {
    return _focusNodes.putIfAbsent(key, () {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus && mounted) {
          setState(() {});
        }
      });
      return node;
    });
  }

  bool _isFieldZero(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return true;
    final val = double.tryParse(text);
    return val == null || val == 0;
  }

  bool _shouldBeInZeroSection(String key, TextEditingController controller) {
    final focusNode = _getFocusNode(key);
    if (focusNode.hasFocus) {
      return _zeroSectionFieldKeys.contains(key);
    }
    bool isZero = _isFieldZero(controller);
    if (isZero) {
      _zeroSectionFieldKeys.add(key);
    } else {
      _zeroSectionFieldKeys.remove(key);
    }
    return isZero;
  }

  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();

  // Q1 (MM)
  final mmdaController = TextEditingController();
  final mmhraController = TextEditingController();
  final mmdaontaController = TextEditingController();
  final mmpcaController = TextEditingController();
  final mmnpaController = TextEditingController();
  final mmtutionController = TextEditingController();
  final mmsplpayController = TextEditingController();
  final mmconvController = TextEditingController();
  final mmpgController = TextEditingController();
  final mmannualController = TextEditingController();
  final mmuniformController = TextEditingController();
  final mmnursingController = TextEditingController();
  final mmmedicalController = TextEditingController();
  final mmdirtController = TextEditingController();
  final mmtbController = TextEditingController();
  final mmnightController = TextEditingController();
  final mmdriveController = TextEditingController();
  final mmcycleController = TextEditingController();
  final mmotController = TextEditingController();
  final mmwashingController = TextEditingController();
  final mmotherController = TextEditingController();
  final mmext1Controller = TextEditingController();

  // Q2 (JA)
  final jadaController = TextEditingController();
  final jahraController = TextEditingController();
  final jadaontaController = TextEditingController();
  final japcaController = TextEditingController();
  final janpaController = TextEditingController();
  final jatutionController = TextEditingController();
  final jasplpayController = TextEditingController();
  final jaconvController = TextEditingController();
  final japgController = TextEditingController();
  final jaannualController = TextEditingController();
  final jauniformController = TextEditingController();
  final janursingController = TextEditingController();
  final jamedicalController = TextEditingController();
  final jadirtController = TextEditingController();
  final jatbController = TextEditingController();
  final janightController = TextEditingController();
  final jadriveController = TextEditingController();
  final jacycleController = TextEditingController();
  final jaotController = TextEditingController();
  final jawashingController = TextEditingController();
  final jaotherController = TextEditingController();
  final jaext1Controller = TextEditingController();

  // Q3 (SN)
  final sndaController = TextEditingController();
  final snhraController = TextEditingController();
  final sndaontaController = TextEditingController();
  final snpcaController = TextEditingController();
  final snnpaController = TextEditingController();
  final sntutionController = TextEditingController();
  final snsplpayController = TextEditingController();
  final snconvController = TextEditingController();
  final snpgController = TextEditingController();
  final snannualController = TextEditingController();
  final snuniformController = TextEditingController();
  final snnursingController = TextEditingController();
  final snmedicalController = TextEditingController();
  final sndirtController = TextEditingController();
  final sntbController = TextEditingController();
  final snightController = TextEditingController();
  final sndriveController = TextEditingController();
  final sncycleController = TextEditingController();
  final snotController = TextEditingController();
  final snwashingController = TextEditingController();
  final snotherController = TextEditingController();
  final snext1Controller = TextEditingController();

  // Q4 (DF)
  final dfdaController = TextEditingController();
  final dfhraController = TextEditingController();
  final dfdaontaController = TextEditingController();
  final dfpcaController = TextEditingController();
  final dfnpaController = TextEditingController();
  final dftutionController = TextEditingController();
  final dfsplpayController = TextEditingController();
  final dfconvController = TextEditingController();
  final dfpgController = TextEditingController();
  final dfannualController = TextEditingController();
  final dfuniformController = TextEditingController();
  final dfnursingController = TextEditingController();
  final dfmedicalController = TextEditingController();
  final dfdirtController = TextEditingController();
  final dftbController = TextEditingController();
  final dfnightController = TextEditingController();
  final dfdriveController = TextEditingController();
  final dfcycleController = TextEditingController();
  final dfotController = TextEditingController();
  final dfwashingController = TextEditingController();
  final dfotherController = TextEditingController();
  final dfext1Controller = TextEditingController();

  // Additional Adjustments
  final bonusController = TextEditingController();
  final previncController = TextEditingController();
  final prevtaxController = TextEditingController();

  // Custom Entries lists per quarter
  List<CustomOtherEntry> q1CustomEntries = [];
  List<CustomOtherEntry> q2CustomEntries = [];
  List<CustomOtherEntry> q3CustomEntries = [];
  List<CustomOtherEntry> q4CustomEntries = [];

  late AnimationController _entranceController;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);

  List<CustomOtherEntry> _getCustomEntriesForQuarter(int qIndex) {
    switch (qIndex) {
      case 1: return q1CustomEntries;
      case 2: return q2CustomEntries;
      case 3: return q3CustomEntries;
      case 4: return q4CustomEntries;
      default: return [];
    }
  }

  TextEditingController _getOtherControllerForQuarter(int qIndex) {
    switch (qIndex) {
      case 1: return mmotherController;
      case 2: return jaotherController;
      case 3: return snotherController;
      case 4: return dfotherController;
      default: return mmotherController;
    }
  }

  void _recalculateOtherTotal(int qIndex) {
    final entries = _getCustomEntriesForQuarter(qIndex);
    final otherController = _getOtherControllerForQuarter(qIndex);

    if (entries.isEmpty) return;

    double total = 0;
    for (var entry in entries) {
      final val = double.tryParse(entry.amountController.text.trim()) ?? 0;
      total += val;
    }
    otherController.text = total == total.roundToDouble() ? total.round().toString() : total.toString();
    if (mounted) setState(() {});
  }

  void _parseCustomEntriesFromData(Map<String, dynamic> data) {
    void populate(String key, List<CustomOtherEntry> list) {
      list.clear();
      final rawList = data[key];
      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            final name = (item['name'] ?? '').toString();
            final amount = (item['amount'] ?? '0').toString();
            list.add(CustomOtherEntry(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              amount: amount,
            ));
          }
        }
      }
    }

    populate('q1custom', q1CustomEntries);
    populate('q2custom', q2CustomEntries);
    populate('q3custom', q3CustomEntries);
    populate('q4custom', q4CustomEntries);
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceController.forward();

    final data = widget.arrearDataMap ?? {};

    biometricIdController.text = widget.biometricId;
    nameController.text = widget.name;

    // Q1
    mmdaController.text = data['mmda']?.toString() ?? widget.mmda;
    mmhraController.text = data['mmhra']?.toString() ?? widget.mmhra;
    mmdaontaController.text = data['mmdaonta']?.toString() ?? widget.mmdaonta;
    mmpcaController.text = data['mmpca']?.toString() ?? widget.mmpca;
    mmnpaController.text = data['mmnpa']?.toString() ?? widget.mmnpa;
    mmtutionController.text = data['mmtution']?.toString() ?? widget.mmtution;
    mmsplpayController.text = data['mmsplpay']?.toString() ?? widget.mmsplpay;
    mmconvController.text = data['mmconv']?.toString() ?? widget.mmconv;
    mmpgController.text = data['mmpg']?.toString() ?? widget.mmpg;
    mmannualController.text = data['mmannual']?.toString() ?? widget.mmannual;
    mmuniformController.text = data['mmuniform']?.toString() ?? widget.mmuniform;
    mmnursingController.text = data['mmnursing']?.toString() ?? widget.mmnursing;
    mmmedicalController.text = data['mmmedical']?.toString() ?? widget.mmmedical;
    mmdirtController.text = data['mmdirt']?.toString() ?? widget.mmdirt;
    mmtbController.text = data['mmtb']?.toString() ?? widget.mmtb;
    mmnightController.text = data['mmnight']?.toString() ?? widget.mmnight;
    mmdriveController.text = data['mmdrive']?.toString() ?? widget.mmdrive;
    mmcycleController.text = data['mmcycle']?.toString() ?? widget.mmcycle;
    mmotController.text = data['mmot']?.toString() ?? widget.mmot;
    mmwashingController.text = data['mmwashing']?.toString() ?? widget.mmwashing;
    mmotherController.text = data['mmother']?.toString() ?? widget.mmother;
    mmext1Controller.text = data['mmext1']?.toString() ?? widget.mmext1;

    // Q2
    jadaController.text = data['jada']?.toString() ?? widget.jada;
    jahraController.text = data['jahra']?.toString() ?? widget.jahra;
    jadaontaController.text = data['jadaonta']?.toString() ?? widget.jadaonta;
    japcaController.text = data['japca']?.toString() ?? widget.japca;
    janpaController.text = data['janpa']?.toString() ?? widget.janpa;
    jatutionController.text = data['jatution']?.toString() ?? widget.jatution;
    jasplpayController.text = data['jasplpay']?.toString() ?? widget.jasplpay;
    jaconvController.text = data['jaconv']?.toString() ?? widget.jaconv;
    japgController.text = data['japg']?.toString() ?? widget.japg;
    jaannualController.text = data['jaannual']?.toString() ?? widget.jaannual;
    jauniformController.text = data['jauniform']?.toString() ?? widget.jauniform;
    janursingController.text = data['janursing']?.toString() ?? widget.janursing;
    jamedicalController.text = data['jamedical']?.toString() ?? widget.jamedical;
    jadirtController.text = data['jadirt']?.toString() ?? widget.jadirt;
    jatbController.text = data['jatb']?.toString() ?? widget.jatb;
    janightController.text = data['janight']?.toString() ?? widget.janight;
    jadriveController.text = data['jadrive']?.toString() ?? widget.jadrive;
    jacycleController.text = data['jacycle']?.toString() ?? widget.jacycle;
    jaotController.text = data['jaot']?.toString() ?? widget.jaot;
    jawashingController.text = data['jawashing']?.toString() ?? widget.jawashing;
    jaotherController.text = data['jaother']?.toString() ?? widget.jaother;
    jaext1Controller.text = data['jaext1']?.toString() ?? widget.jaext1;

    // Q3
    sndaController.text = data['snda']?.toString() ?? widget.snda;
    snhraController.text = data['snhra']?.toString() ?? widget.snhra;
    sndaontaController.text = data['sndaonta']?.toString() ?? widget.sndaonta;
    snpcaController.text = data['snpca']?.toString() ?? widget.snpca;
    snnpaController.text = data['snnpa']?.toString() ?? widget.snnpa;
    sntutionController.text = data['sntution']?.toString() ?? widget.sntution;
    snsplpayController.text = data['snsplpay']?.toString() ?? widget.snsplpay;
    snconvController.text = data['snconv']?.toString() ?? widget.snconv;
    snpgController.text = data['snpg']?.toString() ?? widget.snpg;
    snannualController.text = data['snannual']?.toString() ?? widget.snannual;
    snuniformController.text = data['snuniform']?.toString() ?? widget.snuniform;
    snnursingController.text = data['snnursing']?.toString() ?? widget.snnursing;
    snmedicalController.text = data['snmedical']?.toString() ?? widget.snmedical;
    sndirtController.text = data['sndirt']?.toString() ?? widget.sndirt;
    sntbController.text = data['sntb']?.toString() ?? widget.sntb;
    snightController.text = data['snight']?.toString() ?? widget.snight;
    sndriveController.text = data['sndrive']?.toString() ?? widget.sndrive;
    sncycleController.text = data['sncycle']?.toString() ?? widget.sncycle;
    snotController.text = data['snot']?.toString() ?? widget.snot;
    snwashingController.text = data['snwashing']?.toString() ?? widget.snwashing;
    snotherController.text = data['snother']?.toString() ?? widget.snother;
    snext1Controller.text = data['snext1']?.toString() ?? widget.snext1;

    // Q4
    dfdaController.text = data['dfda']?.toString() ?? widget.dfda;
    dfhraController.text = data['dfhra']?.toString() ?? widget.dfhra;
    dfdaontaController.text = data['dfdaonta']?.toString() ?? widget.dfdaonta;
    dfpcaController.text = data['dfpca']?.toString() ?? widget.dfpca;
    dfnpaController.text = data['dfnpa']?.toString() ?? widget.dfnpa;
    dftutionController.text = data['dftution']?.toString() ?? widget.dftution;
    dfsplpayController.text = data['dfsplpay']?.toString() ?? widget.dfsplpay;
    dfconvController.text = data['dfconv']?.toString() ?? widget.dfconv;
    dfpgController.text = data['dfpg']?.toString() ?? widget.dfpg;
    dfannualController.text = data['dfannual']?.toString() ?? widget.dfannual;
    dfuniformController.text = data['dfuniform']?.toString() ?? widget.dfuniform;
    dfnursingController.text = data['dfnursing']?.toString() ?? widget.dfnursing;
    dfmedicalController.text = data['dfmedical']?.toString() ?? widget.dfmedical;
    dfdirtController.text = data['dfdirt']?.toString() ?? widget.dfdirt;
    dftbController.text = data['dftb']?.toString() ?? widget.dftb;
    dfnightController.text = data['dfnight']?.toString() ?? widget.dfnight;
    dfdriveController.text = data['dfdrive']?.toString() ?? widget.dfdrive;
    dfcycleController.text = data['dfcycle']?.toString() ?? widget.dfcycle;
    dfotController.text = data['dfot']?.toString() ?? widget.dfot;
    dfwashingController.text = data['dfwashing']?.toString() ?? widget.dfwashing;
    dfotherController.text = data['dfother']?.toString() ?? widget.dfother;
    dfext1Controller.text = data['dfext1']?.toString() ?? widget.dfext1;

    // Additional Adjustments
    bonusController.text = data['bonus']?.toString() ?? widget.bonus;
    previncController.text = data['previnc']?.toString() ?? widget.previnc;
    prevtaxController.text = data['prevtax']?.toString() ?? widget.prevtax;

    _parseCustomEntriesFromData(data);
  }

  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    _focusNodes.clear();
    _zeroSectionFieldKeys.clear();
    _entranceController.dispose();

    for (var e in q1CustomEntries) { e.dispose(); }
    for (var e in q2CustomEntries) { e.dispose(); }
    for (var e in q3CustomEntries) { e.dispose(); }
    for (var e in q4CustomEntries) { e.dispose(); }

    biometricIdController.dispose();
    nameController.dispose();

    mmdaController.dispose(); mmhraController.dispose(); mmdaontaController.dispose(); mmpcaController.dispose(); mmnpaController.dispose(); mmtutionController.dispose();
    mmsplpayController.dispose(); mmconvController.dispose(); mmpgController.dispose(); mmannualController.dispose(); mmuniformController.dispose(); mmnursingController.dispose();
    mmmedicalController.dispose(); mmdirtController.dispose(); mmtbController.dispose(); mmnightController.dispose(); mmdriveController.dispose(); mmcycleController.dispose();
    mmotController.dispose(); mmwashingController.dispose(); mmotherController.dispose(); mmext1Controller.dispose();

    jadaController.dispose(); jahraController.dispose(); jadaontaController.dispose(); japcaController.dispose(); janpaController.dispose(); jatutionController.dispose();
    jasplpayController.dispose(); jaconvController.dispose(); japgController.dispose(); jaannualController.dispose(); jauniformController.dispose(); janursingController.dispose();
    jamedicalController.dispose(); jadirtController.dispose(); jatbController.dispose(); janightController.dispose(); jadriveController.dispose(); jacycleController.dispose();
    jaotController.dispose(); jawashingController.dispose(); jaotherController.dispose(); jaext1Controller.dispose();

    sndaController.dispose(); snhraController.dispose(); sndaontaController.dispose(); snpcaController.dispose(); snnpaController.dispose(); sntutionController.dispose();
    snsplpayController.dispose(); snconvController.dispose(); snpgController.dispose(); snannualController.dispose(); snuniformController.dispose(); snnursingController.dispose();
    snmedicalController.dispose(); sndirtController.dispose(); sntbController.dispose(); snightController.dispose(); sndriveController.dispose(); sncycleController.dispose();
    snotController.dispose(); snwashingController.dispose(); snotherController.dispose(); snext1Controller.dispose();

    dfdaController.dispose(); dfhraController.dispose(); dfdaontaController.dispose(); dfpcaController.dispose(); dfnpaController.dispose(); dftutionController.dispose();
    dfsplpayController.dispose(); dfconvController.dispose(); dfpgController.dispose(); dfannualController.dispose(); dfuniformController.dispose(); dfnursingController.dispose();
    dfmedicalController.dispose(); dfdirtController.dispose(); dftbController.dispose(); dfnightController.dispose(); dfdriveController.dispose(); dfcycleController.dispose();
    dfotController.dispose(); dfwashingController.dispose(); dfotherController.dispose(); dfext1Controller.dispose();

    bonusController.dispose();
    previncController.dispose();
    prevtaxController.dispose();
    super.dispose();
  }

  void _showCustomOtherDialog(BuildContext context, int qIndex) {
    final quarterNames = {
      1: "Quarter 1 (March - May)",
      2: "Quarter 2 (June - August)",
      3: "Quarter 3 (September - November)",
      4: "Quarter 4 (December - February)",
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final entries = _getCustomEntriesForQuarter(qIndex);

            double currentTotal = 0;
            for (var entry in entries) {
              currentTotal += double.tryParse(entry.amountController.text.trim()) ?? 0;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.playlist_add_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Custom Other Allowances (${quarterNames[qIndex]})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No custom fields added yet. Click '+ Add Custom Field' below.",
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        )
                      else
                        ...entries.asMap().entries.map((itemMap) {
                          final idx = itemMap.key;
                          final entry = itemMap.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: entry.nameController,
                                    decoration: InputDecoration(
                                      labelText: "Field Name",
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onChanged: (_) {
                                      setDialogState(() {});
                                      _recalculateOtherTotal(qIndex);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: entry.amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Amount",
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onChanged: (_) {
                                      setDialogState(() {});
                                      _recalculateOtherTotal(qIndex);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                                  onPressed: () {
                                    setDialogState(() {
                                      entry.dispose();
                                      entries.removeAt(idx);
                                    });
                                    _recalculateOtherTotal(qIndex);
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            entries.add(
                              CustomOtherEntry(
                                id: DateTime.now().microsecondsSinceEpoch.toString(),
                                name: '',
                                amount: '0',
                              ),
                            );
                          });
                          _recalculateOtherTotal(qIndex);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Add Custom Field"),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Other Amount:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(
                              "₹ ${currentTotal == currentTotal.roundToDouble() ? currentTotal.round() : currentTotal}",
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB), fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _recalculateOtherTotal(qIndex);
                    Navigator.pop(ctx);
                  },
                  child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveData() async {
    if (checkYearFrozenAndShowDialog(context)) return;
    if (biometricIdController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Biometric ID cannot be blank."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Saving...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await bioRef.child('arrdata').child(biometricIdController.text).update({
        'biometricid': biometricIdController.text,
        'name': nameController.text,

        // Q1 (MM)
        'mmda': mmdaController.text,
        'mmhra': mmhraController.text,
        'mmdaonta': mmdaontaController.text,
        'mmpca': mmpcaController.text,
        'mmnpa': mmnpaController.text,
        'mmtution': mmtutionController.text,
        'mmsplpay': mmsplpayController.text,
        'mmconv': mmconvController.text,
        'mmpg': mmpgController.text,
        'mmannual': mmannualController.text,
        'mmuniform': mmuniformController.text,
        'mmnursing': mmnursingController.text,
        'mmmedical': mmmedicalController.text,
        'mmdirt': mmdirtController.text,
        'mmtb': mmtbController.text,
        'mmnight': mmnightController.text,
        'mmdrive': mmdriveController.text,
        'mmcycle': mmcycleController.text,
        'mmot': mmotController.text,
        'mmwashing': mmwashingController.text,
        'mmother': mmotherController.text,
        'mmext1': mmext1Controller.text,
        'q1custom': q1CustomEntries.map((e) => e.toMap()).toList(),

        // Q2 (JA)
        'jada': jadaController.text,
        'jahra': jahraController.text,
        'jadaonta': jadaontaController.text,
        'japca': japcaController.text,
        'janpa': janpaController.text,
        'jatution': jatutionController.text,
        'jasplpay': jasplpayController.text,
        'jaconv': jaconvController.text,
        'japg': japgController.text,
        'jaannual': jaannualController.text,
        'jauniform': jauniformController.text,
        'janursing': janursingController.text,
        'jamedical': jamedicalController.text,
        'jadirt': jadirtController.text,
        'jatb': jatbController.text,
        'janight': janightController.text,
        'jadrive': jadriveController.text,
        'jacycle': jacycleController.text,
        'jaot': jaotController.text,
        'jawashing': jawashingController.text,
        'jaother': jaotherController.text,
        'jaext1': jaext1Controller.text,
        'q2custom': q2CustomEntries.map((e) => e.toMap()).toList(),

        // Q3 (SN)
        'snda': sndaController.text,
        'snhra': snhraController.text,
        'sndaonta': sndaontaController.text,
        'snpca': snpcaController.text,
        'snnpa': snnpaController.text,
        'sntution': sntutionController.text,
        'snsplpay': snsplpayController.text,
        'snconv': snconvController.text,
        'snpg': snpgController.text,
        'snannual': snannualController.text,
        'snuniform': snuniformController.text,
        'snnursing': snnursingController.text,
        'snmedical': snmedicalController.text,
        'sndirt': sndirtController.text,
        'sntb': sntbController.text,
        'snight': snightController.text,
        'sndrive': sndriveController.text,
        'sncycle': sncycleController.text,
        'snot': snotController.text,
        'snwashing': snwashingController.text,
        'snother': snotherController.text,
        'snext1': snext1Controller.text,
        'q3custom': q3CustomEntries.map((e) => e.toMap()).toList(),

        // Q4 (DF)
        'dfda': dfdaController.text,
        'dfhra': dfhraController.text,
        'dfdaonta': dfdaontaController.text,
        'dfpca': dfpcaController.text,
        'dfnpa': dfnpaController.text,
        'dftution': dftutionController.text,
        'dfsplpay': dfsplpayController.text,
        'dfconv': dfconvController.text,
        'dfpg': dfpgController.text,
        'dfannual': dfannualController.text,
        'dfuniform': dfuniformController.text,
        'dfnursing': dfnursingController.text,
        'dfmedical': dfmedicalController.text,
        'dfdirt': dfdirtController.text,
        'dftb': dftbController.text,
        'dfnight': dfnightController.text,
        'dfdrive': dfdriveController.text,
        'dfcycle': dfcycleController.text,
        'dfot': dfotController.text,
        'dfwashing': dfwashingController.text,
        'dfother': dfotherController.text,
        'dfext1': dfext1Controller.text,
        'q4custom': q4CustomEntries.map((e) => e.toMap()).toList(),

        // Additional Adjustments
        'bonus': bonusController.text,
        'previnc': previncController.text,
        'prevtax': prevtaxController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Arrears data has been successfully updated."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to save data: \n$error"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final delay = (index * 0.1).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  Widget _buildOtherInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required int qIndex,
  }) {
    final focusNode = _getFocusNode('${qIndex}_other');
    return AnimatedInputField(
      label: label,
      controller: controller,
      icon: icon,
      keyboardType: TextInputType.number,
      focusNode: focusNode,
      suffixWidget: IconButton(
        icon: const Icon(Icons.playlist_add_rounded, color: Color(0xFF2563EB)),
        tooltip: "Manage Custom Other Entries",
        onPressed: () => _showCustomOtherDialog(context, qIndex),
      ),
    );
  }

  Widget _buildQuarterCard({
    required int qIndex,
    required String title,
    required IconData icon,
    required String prefix,
    required TextEditingController daController,
    required TextEditingController daontaController,
    required List<_ArrearFieldSpec> remainingSpecs,
  }) {
    final List<Widget> activeWidgets = [
      AnimatedInputField(
        label: "DA",
        controller: daController,
        icon: Icons.currency_rupee_rounded,
        keyboardType: TextInputType.number,
        focusNode: _getFocusNode('${prefix}_da'),
      ),
      AnimatedInputField(
        label: "DA ON TA",
        controller: daontaController,
        icon: Icons.currency_rupee_rounded,
        keyboardType: TextInputType.number,
        focusNode: _getFocusNode('${prefix}_daonta'),
      ),
    ];

    final List<Widget> zeroWidgets = [];

    for (var spec in remainingSpecs) {
      if (_shouldBeInZeroSection(spec.fieldKey, spec.controller)) {
        zeroWidgets.add(spec.widget);
      } else {
        activeWidgets.add(spec.widget);
      }
    }

    return _buildSectionCard(
      title,
      icon,
      activeWidgets,
      expandableTitle: "Other Allowances & Adjustments",
      expandableChildren: zeroWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Q1 (MM)
    final q1RemainingSpecs = [
      _ArrearFieldSpec(fieldKey: 'mm_hra', controller: mmhraController, widget: AnimatedInputField(label: "HRA", controller: mmhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_hra'))),
      _ArrearFieldSpec(fieldKey: 'mm_pca', controller: mmpcaController, widget: AnimatedInputField(label: "PCA", controller: mmpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_pca'))),
      _ArrearFieldSpec(fieldKey: 'mm_npa', controller: mmnpaController, widget: AnimatedInputField(label: "NPA", controller: mmnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_npa'))),
      _ArrearFieldSpec(fieldKey: 'mm_tution', controller: mmtutionController, widget: AnimatedInputField(label: "TUITION", controller: mmtutionController, icon: Icons.school_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_tution'))),
      _ArrearFieldSpec(fieldKey: 'mm_splpay', controller: mmsplpayController, widget: AnimatedInputField(label: "SPECIAL PAY", controller: mmsplpayController, icon: Icons.star_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_splpay'))),
      _ArrearFieldSpec(fieldKey: 'mm_conv', controller: mmconvController, widget: AnimatedInputField(label: "CONVEYANCE", controller: mmconvController, icon: Icons.directions_car_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_conv'))),
      _ArrearFieldSpec(fieldKey: 'mm_pg', controller: mmpgController, widget: AnimatedInputField(label: "PG", controller: mmpgController, icon: Icons.school_outlined, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_pg'))),
      _ArrearFieldSpec(fieldKey: 'mm_annual', controller: mmannualController, widget: AnimatedInputField(label: "ANNUAL", controller: mmannualController, icon: Icons.event_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_annual'))),
      _ArrearFieldSpec(fieldKey: 'mm_uniform', controller: mmuniformController, widget: AnimatedInputField(label: "UNIFORM", controller: mmuniformController, icon: Icons.checkroom_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_uniform'))),
      _ArrearFieldSpec(fieldKey: 'mm_nursing', controller: mmnursingController, widget: AnimatedInputField(label: "NURSING", controller: mmnursingController, icon: Icons.local_hospital_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_nursing'))),
      _ArrearFieldSpec(fieldKey: 'mm_medical', controller: mmmedicalController, widget: AnimatedInputField(label: "MEDICAL", controller: mmmedicalController, icon: Icons.medical_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_medical'))),
      _ArrearFieldSpec(fieldKey: 'mm_dirt', controller: mmdirtController, widget: AnimatedInputField(label: "DIRT", controller: mmdirtController, icon: Icons.cleaning_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_dirt'))),
      _ArrearFieldSpec(fieldKey: 'mm_tb', controller: mmtbController, widget: AnimatedInputField(label: "TB", controller: mmtbController, icon: Icons.sick_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_tb'))),
      _ArrearFieldSpec(fieldKey: 'mm_night', controller: mmnightController, widget: AnimatedInputField(label: "NIGHT", controller: mmnightController, icon: Icons.nights_stay_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_night'))),
      _ArrearFieldSpec(fieldKey: 'mm_drive', controller: mmdriveController, widget: AnimatedInputField(label: "CONTINGENCY", controller: mmdriveController, icon: Icons.warning_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_drive'))),
      _ArrearFieldSpec(fieldKey: 'mm_cycle', controller: mmcycleController, widget: AnimatedInputField(label: "CYCLE", controller: mmcycleController, icon: Icons.pedal_bike_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_cycle'))),
      _ArrearFieldSpec(fieldKey: 'mm_ot', controller: mmotController, widget: AnimatedInputField(label: "OT", controller: mmotController, icon: Icons.more_time_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_ot'))),
      _ArrearFieldSpec(fieldKey: 'mm_washing', controller: mmwashingController, widget: AnimatedInputField(label: "WASHING", controller: mmwashingController, icon: Icons.local_laundry_service_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_washing'))),
      _ArrearFieldSpec(fieldKey: 'mm_ext1', controller: mmext1Controller, widget: AnimatedInputField(label: "TAX", controller: mmext1Controller, icon: Icons.request_quote_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('mm_ext1'))),
      _ArrearFieldSpec(fieldKey: 'mm_other', controller: mmotherController, widget: _buildOtherInputField(label: "OTHER", controller: mmotherController, icon: Icons.more_horiz_rounded, qIndex: 1)),
    ];

    // Q2 (JA)
    final q2RemainingSpecs = [
      _ArrearFieldSpec(fieldKey: 'ja_hra', controller: jahraController, widget: AnimatedInputField(label: "HRA", controller: jahraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_hra'))),
      _ArrearFieldSpec(fieldKey: 'ja_pca', controller: japcaController, widget: AnimatedInputField(label: "PCA", controller: japcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_pca'))),
      _ArrearFieldSpec(fieldKey: 'ja_npa', controller: janpaController, widget: AnimatedInputField(label: "NPA", controller: janpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_npa'))),
      _ArrearFieldSpec(fieldKey: 'ja_tution', controller: jatutionController, widget: AnimatedInputField(label: "TUITION", controller: jatutionController, icon: Icons.school_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_tution'))),
      _ArrearFieldSpec(fieldKey: 'ja_splpay', controller: jasplpayController, widget: AnimatedInputField(label: "SPECIAL PAY", controller: jasplpayController, icon: Icons.star_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_splpay'))),
      _ArrearFieldSpec(fieldKey: 'ja_conv', controller: jaconvController, widget: AnimatedInputField(label: "CONVEYANCE", controller: jaconvController, icon: Icons.directions_car_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_conv'))),
      _ArrearFieldSpec(fieldKey: 'ja_pg', controller: japgController, widget: AnimatedInputField(label: "PG", controller: japgController, icon: Icons.school_outlined, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_pg'))),
      _ArrearFieldSpec(fieldKey: 'ja_annual', controller: jaannualController, widget: AnimatedInputField(label: "ANNUAL", controller: jaannualController, icon: Icons.event_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_annual'))),
      _ArrearFieldSpec(fieldKey: 'ja_uniform', controller: jauniformController, widget: AnimatedInputField(label: "UNIFORM", controller: jauniformController, icon: Icons.checkroom_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_uniform'))),
      _ArrearFieldSpec(fieldKey: 'ja_nursing', controller: janursingController, widget: AnimatedInputField(label: "NURSING", controller: janursingController, icon: Icons.local_hospital_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_nursing'))),
      _ArrearFieldSpec(fieldKey: 'ja_medical', controller: jamedicalController, widget: AnimatedInputField(label: "MEDICAL", controller: jamedicalController, icon: Icons.medical_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_medical'))),
      _ArrearFieldSpec(fieldKey: 'ja_dirt', controller: jadirtController, widget: AnimatedInputField(label: "DIRT", controller: jadirtController, icon: Icons.cleaning_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_dirt'))),
      _ArrearFieldSpec(fieldKey: 'ja_tb', controller: jatbController, widget: AnimatedInputField(label: "TB", controller: jatbController, icon: Icons.sick_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_tb'))),
      _ArrearFieldSpec(fieldKey: 'ja_night', controller: janightController, widget: AnimatedInputField(label: "NIGHT", controller: janightController, icon: Icons.nights_stay_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_night'))),
      _ArrearFieldSpec(fieldKey: 'ja_drive', controller: jadriveController, widget: AnimatedInputField(label: "CONTINGENCY", controller: jadriveController, icon: Icons.warning_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_drive'))),
      _ArrearFieldSpec(fieldKey: 'ja_cycle', controller: jacycleController, widget: AnimatedInputField(label: "CYCLE", controller: jacycleController, icon: Icons.pedal_bike_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_cycle'))),
      _ArrearFieldSpec(fieldKey: 'ja_ot', controller: jaotController, widget: AnimatedInputField(label: "OT", controller: jaotController, icon: Icons.more_time_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_ot'))),
      _ArrearFieldSpec(fieldKey: 'ja_washing', controller: jawashingController, widget: AnimatedInputField(label: "WASHING", controller: jawashingController, icon: Icons.local_laundry_service_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_washing'))),
      _ArrearFieldSpec(fieldKey: 'ja_ext1', controller: jaext1Controller, widget: AnimatedInputField(label: "TAX", controller: jaext1Controller, icon: Icons.request_quote_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('ja_ext1'))),
      _ArrearFieldSpec(fieldKey: 'ja_other', controller: jaotherController, widget: _buildOtherInputField(label: "OTHER", controller: jaotherController, icon: Icons.more_horiz_rounded, qIndex: 2)),
    ];

    // Q3 (SN)
    final q3RemainingSpecs = [
      _ArrearFieldSpec(fieldKey: 'sn_hra', controller: snhraController, widget: AnimatedInputField(label: "HRA", controller: snhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_hra'))),
      _ArrearFieldSpec(fieldKey: 'sn_pca', controller: snpcaController, widget: AnimatedInputField(label: "PCA", controller: snpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_pca'))),
      _ArrearFieldSpec(fieldKey: 'sn_npa', controller: snnpaController, widget: AnimatedInputField(label: "NPA", controller: snnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_npa'))),
      _ArrearFieldSpec(fieldKey: 'sn_tution', controller: sntutionController, widget: AnimatedInputField(label: "TUITION", controller: sntutionController, icon: Icons.school_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_tution'))),
      _ArrearFieldSpec(fieldKey: 'sn_splpay', controller: snsplpayController, widget: AnimatedInputField(label: "SPECIAL PAY", controller: snsplpayController, icon: Icons.star_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_splpay'))),
      _ArrearFieldSpec(fieldKey: 'sn_conv', controller: snconvController, widget: AnimatedInputField(label: "CONVEYANCE", controller: snconvController, icon: Icons.directions_car_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_conv'))),
      _ArrearFieldSpec(fieldKey: 'sn_pg', controller: snpgController, widget: AnimatedInputField(label: "PG", controller: snpgController, icon: Icons.school_outlined, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_pg'))),
      _ArrearFieldSpec(fieldKey: 'sn_annual', controller: snannualController, widget: AnimatedInputField(label: "ANNUAL", controller: snannualController, icon: Icons.event_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_annual'))),
      _ArrearFieldSpec(fieldKey: 'sn_uniform', controller: snuniformController, widget: AnimatedInputField(label: "UNIFORM", controller: snuniformController, icon: Icons.checkroom_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_uniform'))),
      _ArrearFieldSpec(fieldKey: 'sn_nursing', controller: snnursingController, widget: AnimatedInputField(label: "NURSING", controller: snnursingController, icon: Icons.local_hospital_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_nursing'))),
      _ArrearFieldSpec(fieldKey: 'sn_medical', controller: snmedicalController, widget: AnimatedInputField(label: "MEDICAL", controller: snmedicalController, icon: Icons.medical_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_medical'))),
      _ArrearFieldSpec(fieldKey: 'sn_dirt', controller: sndirtController, widget: AnimatedInputField(label: "DIRT", controller: sndirtController, icon: Icons.cleaning_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_dirt'))),
      _ArrearFieldSpec(fieldKey: 'sn_tb', controller: sntbController, widget: AnimatedInputField(label: "TB", controller: sntbController, icon: Icons.sick_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_tb'))),
      _ArrearFieldSpec(fieldKey: 'sn_night', controller: snightController, widget: AnimatedInputField(label: "NIGHT", controller: snightController, icon: Icons.nights_stay_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_night'))),
      _ArrearFieldSpec(fieldKey: 'sn_drive', controller: sndriveController, widget: AnimatedInputField(label: "CONTINGENCY", controller: sndriveController, icon: Icons.warning_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_drive'))),
      _ArrearFieldSpec(fieldKey: 'sn_cycle', controller: sncycleController, widget: AnimatedInputField(label: "CYCLE", controller: sncycleController, icon: Icons.pedal_bike_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_cycle'))),
      _ArrearFieldSpec(fieldKey: 'sn_ot', controller: snotController, widget: AnimatedInputField(label: "OT", controller: snotController, icon: Icons.more_time_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_ot'))),
      _ArrearFieldSpec(fieldKey: 'sn_washing', controller: snwashingController, widget: AnimatedInputField(label: "WASHING", controller: snwashingController, icon: Icons.local_laundry_service_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_washing'))),
      _ArrearFieldSpec(fieldKey: 'sn_ext1', controller: snext1Controller, widget: AnimatedInputField(label: "TAX", controller: snext1Controller, icon: Icons.request_quote_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('sn_ext1'))),
      _ArrearFieldSpec(fieldKey: 'sn_other', controller: snotherController, widget: _buildOtherInputField(label: "OTHER", controller: snotherController, icon: Icons.more_horiz_rounded, qIndex: 3)),
    ];

    // Q4 (DF)
    final q4RemainingSpecs = [
      _ArrearFieldSpec(fieldKey: 'df_hra', controller: dfhraController, widget: AnimatedInputField(label: "HRA", controller: dfhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_hra'))),
      _ArrearFieldSpec(fieldKey: 'df_pca', controller: dfpcaController, widget: AnimatedInputField(label: "PCA", controller: dfpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_pca'))),
      _ArrearFieldSpec(fieldKey: 'df_npa', controller: dfnpaController, widget: AnimatedInputField(label: "NPA", controller: dfnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_npa'))),
      _ArrearFieldSpec(fieldKey: 'df_tution', controller: dftutionController, widget: AnimatedInputField(label: "TUITION", controller: dftutionController, icon: Icons.school_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_tution'))),
      _ArrearFieldSpec(fieldKey: 'df_splpay', controller: dfsplpayController, widget: AnimatedInputField(label: "SPECIAL PAY", controller: dfsplpayController, icon: Icons.star_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_splpay'))),
      _ArrearFieldSpec(fieldKey: 'df_conv', controller: dfconvController, widget: AnimatedInputField(label: "CONVEYANCE", controller: dfconvController, icon: Icons.directions_car_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_conv'))),
      _ArrearFieldSpec(fieldKey: 'df_pg', controller: dfpgController, widget: AnimatedInputField(label: "PG", controller: dfpgController, icon: Icons.school_outlined, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_pg'))),
      _ArrearFieldSpec(fieldKey: 'df_annual', controller: dfannualController, widget: AnimatedInputField(label: "ANNUAL", controller: dfannualController, icon: Icons.event_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_annual'))),
      _ArrearFieldSpec(fieldKey: 'df_uniform', controller: dfuniformController, widget: AnimatedInputField(label: "UNIFORM", controller: dfuniformController, icon: Icons.checkroom_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_uniform'))),
      _ArrearFieldSpec(fieldKey: 'df_nursing', controller: dfnursingController, widget: AnimatedInputField(label: "NURSING", controller: dfnursingController, icon: Icons.local_hospital_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_nursing'))),
      _ArrearFieldSpec(fieldKey: 'df_medical', controller: dfmedicalController, widget: AnimatedInputField(label: "MEDICAL", controller: dfmedicalController, icon: Icons.medical_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_medical'))),
      _ArrearFieldSpec(fieldKey: 'df_dirt', controller: dfdirtController, widget: AnimatedInputField(label: "DIRT", controller: dfdirtController, icon: Icons.cleaning_services_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_dirt'))),
      _ArrearFieldSpec(fieldKey: 'df_tb', controller: dftbController, widget: AnimatedInputField(label: "TB", controller: dftbController, icon: Icons.sick_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_tb'))),
      _ArrearFieldSpec(fieldKey: 'df_night', controller: dfnightController, widget: AnimatedInputField(label: "NIGHT", controller: dfnightController, icon: Icons.nights_stay_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_night'))),
      _ArrearFieldSpec(fieldKey: 'df_drive', controller: dfdriveController, widget: AnimatedInputField(label: "CONTINGENCY", controller: dfdriveController, icon: Icons.warning_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_drive'))),
      _ArrearFieldSpec(fieldKey: 'df_cycle', controller: dfcycleController, widget: AnimatedInputField(label: "CYCLE", controller: dfcycleController, icon: Icons.pedal_bike_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_cycle'))),
      _ArrearFieldSpec(fieldKey: 'df_ot', controller: dfotController, widget: AnimatedInputField(label: "OT", controller: dfotController, icon: Icons.more_time_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_ot'))),
      _ArrearFieldSpec(fieldKey: 'df_washing', controller: dfwashingController, widget: AnimatedInputField(label: "WASHING", controller: dfwashingController, icon: Icons.local_laundry_service_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_washing'))),
      _ArrearFieldSpec(fieldKey: 'df_ext1', controller: dfext1Controller, widget: AnimatedInputField(label: "TAX", controller: dfext1Controller, icon: Icons.request_quote_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('df_ext1'))),
      _ArrearFieldSpec(fieldKey: 'df_other', controller: dfotherController, widget: _buildOtherInputField(label: "OTHER", controller: dfotherController, icon: Icons.more_horiz_rounded, qIndex: 4)),
    ];

    // Additional Adjustments specs
    final adjustmentRemainingSpecs = [
      _ArrearFieldSpec(fieldKey: 'adj_previnc', controller: previncController, widget: AnimatedInputField(label: "PREVIOUS EMPLOYER INCOME", controller: previncController, icon: Icons.business_center_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('adj_previnc'))),
      _ArrearFieldSpec(fieldKey: 'adj_prevtax', controller: prevtaxController, widget: AnimatedInputField(label: "PREVIOUS EMPLOYER TAX", controller: prevtaxController, icon: Icons.receipt_long_rounded, keyboardType: TextInputType.number, focusNode: _getFocusNode('adj_prevtax'))),
    ];

    final List<Widget> activeAdjWidgets = [
      AnimatedInputField(
        label: "BONUS",
        controller: bonusController,
        icon: Icons.monetization_on_rounded,
        keyboardType: TextInputType.number,
        focusNode: _getFocusNode('adj_bonus'),
      ),
    ];

    final List<Widget> zeroAdjWidgets = [];
    for (var spec in adjustmentRemainingSpecs) {
      if (_shouldBeInZeroSection(spec.fieldKey, spec.controller)) {
        zeroAdjWidgets.add(spec.widget);
      } else {
        activeAdjWidgets.add(spec.widget);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -40,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Update Arrears",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${widget.biometricId} - ${widget.name}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAnimatedSection(
                            0,
                            _buildSectionCard(
                              "Employee Information",
                              Icons.badge_rounded,
                              [
                                AnimatedInputField(label: "BIOMETRIC ID", controller: biometricIdController, icon: Icons.fingerprint_rounded, readOnly: true),
                                AnimatedInputField(label: "NAME", controller: nameController, icon: Icons.person_outline_rounded, readOnly: true),
                              ],
                              forceCrossAxisCount: 1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            1,
                            _buildQuarterCard(
                              qIndex: 1,
                              title: "Quarter 1: March to May",
                              icon: Icons.looks_one_rounded,
                              prefix: "mm",
                              daController: mmdaController,
                              daontaController: mmdaontaController,
                              remainingSpecs: q1RemainingSpecs,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            2,
                            _buildQuarterCard(
                              qIndex: 2,
                              title: "Quarter 2: June to August",
                              icon: Icons.looks_two_rounded,
                              prefix: "ja",
                              daController: jadaController,
                              daontaController: jadaontaController,
                              remainingSpecs: q2RemainingSpecs,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            3,
                            _buildQuarterCard(
                              qIndex: 3,
                              title: "Quarter 3: September to November",
                              icon: Icons.looks_3_rounded,
                              prefix: "sn",
                              daController: sndaController,
                              daontaController: sndaontaController,
                              remainingSpecs: q3RemainingSpecs,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            4,
                            _buildQuarterCard(
                              qIndex: 4,
                              title: "Quarter 4: December to February",
                              icon: Icons.looks_4_rounded,
                              prefix: "df",
                              daController: dfdaController,
                              daontaController: dfdaontaController,
                              remainingSpecs: q4RemainingSpecs,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            5,
                            _buildSectionCard(
                              "Additional Adjustments",
                              Icons.add_card_rounded,
                              activeAdjWidgets,
                              expandableTitle: "Other Adjustments",
                              expandableChildren: zeroAdjWidgets,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _AnimatedActionButton(
                      label: "SAVE ARREARS DATA",
                      icon: Icons.save_rounded,
                      gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      onPressed: _saveData,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    List<Widget> children, {
    int? forceCrossAxisCount,
    String? expandableTitle,
    List<Widget>? expandableChildren,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.06),
                  blurRadius: isMobile ? 10 : 20,
                  offset: Offset(0, isMobile ? 4 : 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 10 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMobile ? 14 : 22),
                      topRight: Radius.circular(isMobile ? 14 : 22),
                    ),
                    border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 6 : 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                        ),
                        child: Icon(icon, color: const Color(0xFF2563EB), size: isMobile ? 18 : 22),
                      ),
                      SizedBox(width: isMobile ? 10 : 16),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (children.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 10 : 24),
                    child: LayoutBuilder(
                      builder: (context, innerConstraints) {
                        int crossAxisCount = forceCrossAxisCount ?? (innerConstraints.maxWidth > 800 ? 3 : 2);
                        double spacing = isMobile ? 8.0 : 20.0;
                        double runSpacing = isMobile ? 10.0 : 24.0;
                        double itemWidth = (innerConstraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: runSpacing,
                          children: children.map<Widget>((child) => SizedBox(width: itemWidth, child: child)).toList(),
                        );
                      },
                    ),
                  ),
                if (expandableChildren != null && expandableChildren.isNotEmpty) ...[
                  if (children.isNotEmpty)
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  Material(
                    color: Colors.transparent,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 24,
                          vertical: isMobile ? 2 : 6,
                        ),
                        childrenPadding: EdgeInsets.fromLTRB(
                          isMobile ? 10 : 24,
                          0,
                          isMobile ? 10 : 24,
                          isMobile ? 12 : 24,
                        ),
                        title: Row(
                          children: [
                            Text(
                              expandableTitle ?? "Other Fields",
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                '${expandableChildren.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          LayoutBuilder(
                            builder: (context, innerConstraints) {
                              int crossAxisCount = forceCrossAxisCount ?? (innerConstraints.maxWidth > 800 ? 3 : 2);
                              double spacing = isMobile ? 8.0 : 20.0;
                              double runSpacing = isMobile ? 10.0 : 24.0;
                              double itemWidth = (innerConstraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: runSpacing,
                                children: expandableChildren.map<Widget>((child) => SizedBox(width: itemWidth, child: child)).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Widget? suffixWidget;

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
    this.suffixWidget,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  bool _isHovered = false;

  bool get _isDateField =>
      widget.label.toUpperCase().contains('DATE') ||
      widget.label.toUpperCase().contains('DOB') ||
      widget.label.toUpperCase().contains('DOA') ||
      widget.label.toUpperCase().contains('DORT') ||
      widget.label.toUpperCase().contains('DOJO') ||
      widget.label.toUpperCase().contains('DORN') ||
      widget.label.toUpperCase().contains('DOT') ||
      widget.label.toUpperCase().contains('DOD');

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0.0, _isHovered && !widget.readOnly ? -2.0 : 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: isMobile ? 3 : 8),
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                boxShadow: [
                  if (_isHovered && !widget.readOnly)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: isMobile ? 8 : 12,
                      offset: Offset(0, isMobile ? 2 : 4),
                    ),
                ],
              ),
              child: TextField(
                focusNode: widget.focusNode,
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                inputFormatters: [
                  if (!_isDateField) UpperCaseTextFormatter(),
                  ...widget.inputFormatters,
                ],
                controller: widget.controller,
                onTap: () {
                  if (!_isDateField &&
                      !widget.readOnly &&
                      widget.keyboardType == TextInputType.number &&
                      widget.controller.text == '0') {
                    widget.controller.text = '';
                  }
                },
                onEditingComplete: () {
                  if (_isDateField && widget.controller.text.isNotEmpty) {
                    widget.controller.text = formatToDDMMYYYY(widget.controller.text);
                    if (widget.onChanged != null) {
                      widget.onChanged!(widget.controller.text);
                    }
                  }
                },
                style: TextStyle(
                  color: widget.readOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: widget.readOnly ? FontWeight.w700 : FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.readOnly
                      ? const Color(0xFFE2E8F0).withValues(alpha: 0.5)
                      : (_isHovered ? Colors.white : const Color(0xFFF8FAFC)),
                  prefixIcon: Icon(
                    widget.icon,
                    color: widget.readOnly
                        ? const Color(0xFF94A3B8)
                        : (_isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                    size: isMobile ? 16 : 20,
                  ),
                  prefixIconConstraints: isMobile
                      ? const BoxConstraints(minWidth: 32, minHeight: 32)
                      : null,
                  suffixIcon: widget.suffixWidget ??
                      (_isDateField && !widget.readOnly
                          ? IconButton(
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                color: _isHovered ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                size: isMobile ? 18 : 22,
                              ),
                              tooltip: "Select Date",
                              onPressed: () {
                                selectDateDDMMYYYY(
                                  context,
                                  widget.controller,
                                  onChanged: widget.onChanged,
                                );
                              },
                            )
                          : null),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMobile ? 10 : 18,
                    horizontal: isMobile ? 8 : 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: BorderSide(
                      color: _isHovered && !widget.readOnly ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: BorderSide(
                      color: widget.readOnly ? const Color(0xFFE2E8F0) : const Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  String newValue = value;
                  if (!_isDateField &&
                      !widget.readOnly &&
                      widget.keyboardType == TextInputType.number &&
                      newValue.length > 1 &&
                      newValue.startsWith('0')) {
                    newValue = newValue.replaceFirst(RegExp(r'^0+'), '');
                    if (newValue.isEmpty) newValue = '0';
                  }
                  if (widget.controller.text != newValue) {
                    final cursorPosition = TextSelection.collapsed(offset: newValue.length);
                    widget.controller.value = TextEditingValue(
                      text: newValue,
                      selection: cursorPosition,
                    );
                  }
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isMobile ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isHovered
                        ? [widget.gradientColors.first.withValues(alpha: 0.9), widget.gradientColors.last.withValues(alpha: 0.9)]
                        : widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: _isHovered ? 0.4 : 0.2),
                      blurRadius: _isHovered ? (isMobile ? 12 : 20) : (isMobile ? 6 : 10),
                      offset: Offset(0, isMobile ? 4 : 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: isMobile ? 18 : 22),
                    SizedBox(width: isMobile ? 6 : 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

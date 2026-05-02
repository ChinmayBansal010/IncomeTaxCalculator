import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';

class ArrearUpdatePage extends StatefulWidget {
  final String biometricId;
  final String name;
  final String mmda;
  final String mmhra;
  final String mmdaonta;
  final String mmpca;
  final String mmnpa;
  final String mmtution;
  final String mmother;
  final String mmext1;
  final String mmext2;
  final String mmext3;
  final String jada;
  final String jahra;
  final String jadaonta;
  final String japca;
  final String janpa;
  final String jatution;
  final String jaother;
  final String jaext1;
  final String jaext2;
  final String jaext3;
  final String snda;
  final String snhra;
  final String sndaonta;
  final String snpca;
  final String snnpa;
  final String sntution;
  final String snother;
  final String snext1;
  final String snext2;
  final String snext3;
  final String dfda;
  final String dfhra;
  final String dfdaonta;
  final String dfpca;
  final String dfnpa;
  final String dftution;
  final String dfother;
  final String dfext1;
  final String dfext2;
  final String dfext3;
  final String bonus;

  const ArrearUpdatePage({
    super.key,
    required this.biometricId,
    required this.name,
    required this.mmda,
    required this.mmhra,
    required this.mmdaonta,
    required this.mmpca,
    required this.mmnpa,
    required this.mmtution,
    required this.mmother,
    required this.mmext1,
    required this.mmext2,
    required this.mmext3,
    required this.jada,
    required this.jahra,
    required this.jadaonta,
    required this.japca,
    required this.janpa,
    required this.jatution,
    required this.jaother,
    required this.jaext1,
    required this.jaext2,
    required this.jaext3,
    required this.snda,
    required this.snhra,
    required this.sndaonta,
    required this.snpca,
    required this.snnpa,
    required this.sntution,
    required this.snother,
    required this.snext1,
    required this.snext2,
    required this.snext3,
    required this.dfda,
    required this.dfhra,
    required this.dfdaonta,
    required this.dfpca,
    required this.dfnpa,
    required this.dftution,
    required this.dfother,
    required this.dfext1,
    required this.dfext2,
    required this.dfext3,
    required this.bonus,
  });

  @override
  State<ArrearUpdatePage> createState() => ArrearUpdatePageState();
}

class ArrearUpdatePageState extends State<ArrearUpdatePage> with SingleTickerProviderStateMixin {
  final biometricIdController = TextEditingController();
  final nameController = TextEditingController();
  final mmdaController = TextEditingController();
  final mmhraController = TextEditingController();
  final mmdaontaController = TextEditingController();
  final mmpcaController = TextEditingController();
  final mmnpaController = TextEditingController();
  final mmtutionController = TextEditingController();
  final mmotherController = TextEditingController();
  final mmext1Controller = TextEditingController();
  final mmext2Controller = TextEditingController();
  final mmext3Controller = TextEditingController();
  final jadaController = TextEditingController();
  final jahraController = TextEditingController();
  final jadaontaController = TextEditingController();
  final japcaController = TextEditingController();
  final janpaController = TextEditingController();
  final jatutionController = TextEditingController();
  final jaotherController = TextEditingController();
  final jaext1Controller = TextEditingController();
  final jaext2Controller = TextEditingController();
  final jaext3Controller = TextEditingController();
  final sndaController = TextEditingController();
  final snhraController = TextEditingController();
  final sndaontaController = TextEditingController();
  final snpcaController = TextEditingController();
  final snnpaController = TextEditingController();
  final sntutionController = TextEditingController();
  final snotherController = TextEditingController();
  final snext1Controller = TextEditingController();
  final snext2Controller = TextEditingController();
  final snext3Controller = TextEditingController();
  final dfdaController = TextEditingController();
  final dfhraController = TextEditingController();
  final dfdaontaController = TextEditingController();
  final dfpcaController = TextEditingController();
  final dfnpaController = TextEditingController();
  final dftutionController = TextEditingController();
  final dfotherController = TextEditingController();
  final dfext1Controller = TextEditingController();
  final dfext2Controller = TextEditingController();
  final dfext3Controller = TextEditingController();
  final bonusController = TextEditingController();

  late AnimationController _entranceController;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef = database.child(sharedData.userPlace);
  List<String> month = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceController.forward();

    biometricIdController.text = widget.biometricId;
    nameController.text = widget.name;
    mmdaController.text = widget.mmda;
    mmhraController.text = widget.mmhra;
    mmdaontaController.text = widget.mmdaonta;
    mmpcaController.text = widget.mmpca;
    mmnpaController.text = widget.mmnpa;
    mmtutionController.text = widget.mmtution;
    mmotherController.text = widget.mmother;
    mmext1Controller.text = widget.mmext1;
    mmext2Controller.text = widget.mmext2;
    mmext3Controller.text = widget.mmext3;
    jadaController.text = widget.jada;
    jahraController.text = widget.jahra;
    jadaontaController.text = widget.jadaonta;
    japcaController.text = widget.japca;
    janpaController.text = widget.janpa;
    jatutionController.text = widget.jatution;
    jaotherController.text = widget.jaother;
    jaext1Controller.text = widget.jaext1;
    jaext2Controller.text = widget.jaext2;
    jaext3Controller.text = widget.jaext3;
    sndaController.text = widget.snda;
    snhraController.text = widget.snhra;
    sndaontaController.text = widget.sndaonta;
    snpcaController.text = widget.snpca;
    snnpaController.text = widget.snnpa;
    sntutionController.text = widget.sntution;
    snotherController.text = widget.snother;
    snext1Controller.text = widget.snext1;
    snext2Controller.text = widget.snext2;
    snext3Controller.text = widget.snext3;
    dfdaController.text = widget.dfda;
    dfhraController.text = widget.dfhra;
    dfdaontaController.text = widget.dfdaonta;
    dfpcaController.text = widget.dfpca;
    dfnpaController.text = widget.dfnpa;
    dftutionController.text = widget.dftution;
    dfotherController.text = widget.dfother;
    dfext1Controller.text = widget.dfext1;
    dfext2Controller.text = widget.dfext2;
    dfext3Controller.text = widget.dfext3;
    bonusController.text = widget.bonus;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    biometricIdController.dispose();
    nameController.dispose();
    mmdaController.dispose();
    mmhraController.dispose();
    mmdaontaController.dispose();
    mmpcaController.dispose();
    mmnpaController.dispose();
    mmtutionController.dispose();
    mmotherController.dispose();
    mmext1Controller.dispose();
    mmext2Controller.dispose();
    mmext3Controller.dispose();
    jadaController.dispose();
    jahraController.dispose();
    jadaontaController.dispose();
    japcaController.dispose();
    janpaController.dispose();
    jatutionController.dispose();
    jaotherController.dispose();
    jaext1Controller.dispose();
    jaext2Controller.dispose();
    jaext3Controller.dispose();
    sndaController.dispose();
    snhraController.dispose();
    sndaontaController.dispose();
    snpcaController.dispose();
    snnpaController.dispose();
    sntutionController.dispose();
    snotherController.dispose();
    snext1Controller.dispose();
    snext2Controller.dispose();
    snext3Controller.dispose();
    dfdaController.dispose();
    dfhraController.dispose();
    dfdaontaController.dispose();
    dfpcaController.dispose();
    dfnpaController.dispose();
    dftutionController.dispose();
    dfotherController.dispose();
    dfext1Controller.dispose();
    dfext2Controller.dispose();
    dfext3Controller.dispose();
    bonusController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
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
          constraints: BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
        'mmda': mmdaController.text,
        'mmhra': mmhraController.text,
        'mmdaonta': mmdaontaController.text,
        'mmpca': mmpcaController.text,
        'mmnpa': mmnpaController.text,
        'mmtution': mmtutionController.text,
        'mmother': mmotherController.text,
        'mmext1': mmext1Controller.text,
        'mmext2': mmext2Controller.text,
        'mmext3': mmext3Controller.text,
        'jada': jadaController.text,
        'jahra': jahraController.text,
        'jadaonta': jadaontaController.text,
        'japca': japcaController.text,
        'janpa': janpaController.text,
        'jatution': jatutionController.text,
        'jaother': jaotherController.text,
        'jaext1': jaext1Controller.text,
        'jaext2': jaext2Controller.text,
        'jaext3': jaext3Controller.text,
        'snda': sndaController.text,
        'snhra': snhraController.text,
        'sndaonta': sndaontaController.text,
        'snpca': snpcaController.text,
        'snnpa': snnpaController.text,
        'sntution': sntutionController.text,
        'snother': snotherController.text,
        'snext1': snext1Controller.text,
        'snext2': snext2Controller.text,
        'snext3': snext3Controller.text,
        'dfda': dfdaController.text,
        'dfhra': dfhraController.text,
        'dfdaonta': dfdaontaController.text,
        'dfpca': dfpcaController.text,
        'dfnpa': dfnpaController.text,
        'dftution': dftutionController.text,
        'dfother': dfotherController.text,
        'dfext1': dfext1Controller.text,
        'dfext2': dfext2Controller.text,
        'dfext3': dfext3Controller.text,
        'bonus': bonusController.text,
      });
      if(mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Employee data has been successfully updated."),
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
            content: Text("Failed to add data: \n$error"),
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

  @override
  Widget build(BuildContext context) {
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
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            1,
                            _buildSectionCard(
                              "Quarter 1: March to May",
                              Icons.looks_one_rounded,
                              [
                                AnimatedInputField(label: "DA", controller: mmdaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "HRA", controller: mmhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "DA ON TA", controller: mmdaontaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "PCA", controller: mmpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "NPA", controller: mmnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TUTION", controller: mmtutionController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "OTHER", controller: mmotherController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TAX", controller: mmext1Controller, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            2,
                            _buildSectionCard(
                              "Quarter 2: June to August",
                              Icons.looks_two_rounded,
                              [
                                AnimatedInputField(label: "DA", controller: jadaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "HRA", controller: jahraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "DA ON TA", controller: jadaontaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "PCA", controller: japcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "NPA", controller: janpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TUTION", controller: jatutionController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "OTHER", controller: jaotherController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TAX", controller: jaext1Controller, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            3,
                            _buildSectionCard(
                              "Quarter 3: September to November",
                              Icons.looks_3_rounded,
                              [
                                AnimatedInputField(label: "DA", controller: sndaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "HRA", controller: snhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "DA ON TA", controller: sndaontaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "PCA", controller: snpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "NPA", controller: snnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TUTION", controller: sntutionController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "OTHER", controller: snotherController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TAX", controller: snext1Controller, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            4,
                            _buildSectionCard(
                              "Quarter 4: December to February",
                              Icons.looks_4_rounded,
                              [
                                AnimatedInputField(label: "DA", controller: dfdaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "HRA", controller: dfhraController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "DA ON TA", controller: dfdaontaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "PCA", controller: dfpcaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "NPA", controller: dfnpaController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TUTION", controller: dftutionController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "OTHER", controller: dfotherController, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                                AnimatedInputField(label: "TAX", controller: dfext1Controller, icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAnimatedSection(
                            5,
                            _buildSectionCard(
                              "Additional Adjustments",
                              Icons.add_card_rounded,
                              [
                                AnimatedInputField(label: "BONUS", controller: bonusController, icon: Icons.monetization_on_rounded, keyboardType: TextInputType.number),
                              ],
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
                  ),
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                double spacing = 20.0;
                double itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 24.0,
                  children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
                );
              },
            ),
          ),
        ],
      ),
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

  const AnimatedInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.readOnly = false,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered && !widget.readOnly ? -2.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (_isHovered && !widget.readOnly)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                style: TextStyle(
                  color: widget.readOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: widget.readOnly ? FontWeight.w700 : FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.readOnly
                      ? const Color(0xFFF1F5F9)
                      : (_isHovered ? Colors.white : const Color(0xFFF8FAFC)),
                  prefixIcon: Icon(
                    widget.icon,
                    color: widget.readOnly
                        ? const Color(0xFF94A3B8)
                        : (_isHovered ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _isHovered && !widget.readOnly ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  if (widget.controller.text != value) {
                    final cursorPosition = widget.controller.selection;
                    widget.controller.value = TextEditingValue(
                      text: value,
                      selection: cursorPosition,
                    );
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: _isHovered ? 0.4 : 0.2),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
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
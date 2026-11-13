import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';
import 'package:incometax/tds.dart';
import 'main.dart';
import 'main_data.dart';
import 'da.dart';
import 'month_data.dart';
import 'itax.dart';
import 'arrear_data.dart';
import 'deduction_data.dart';
import 'tax.dart';
import 'arrear_calc.dart';
import 'exportall.dart';
import 'admin_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;

  int _totalEmployeeRecords = 0;
  bool _isFetchingRecords = true;

  String _selectedArrearDeductionOption = 'ARREAR';
  String _selectedTdsOption = 'TDS - 0';

  List<Map<String, dynamic>> get _menuItems => [
        {
          "key": "MAIN",
          "label": "MAIN",
          "subtitle": "Core tax entries",
          "icon": Icons.dashboard_customize_rounded,
          "color": const Color(0xFF2563EB),
        },
        {
          "key": "MONTH",
          "label": "MONTH",
          "subtitle": "Monthly salary",
          "icon": Icons.calendar_month_rounded,
          "color": const Color(0xFFD97706),
        },
        {
          "key": "ARREAR_DEDUCTION",
          "label": "ARREAR AND DEDUCTION",
          "subtitle": _selectedArrearDeductionOption == 'ARREAR' ? "Pending clearings" : "Tax deductions",
          "icon": _selectedArrearDeductionOption == 'ARREAR'
              ? Icons.account_balance_wallet_rounded
              : Icons.remove_circle_outline_rounded,
          "color": _selectedArrearDeductionOption == 'ARREAR'
              ? const Color(0xFF7C3AED)
              : const Color(0xFFDC2626),
          "hasDropdown": true,
          "currentValue": _selectedArrearDeductionOption,
          "dropdownOptions": [
            {"value": "ARREAR", "label": "ARREAR", "subtitle": "Pending clearings"},
            {"value": "DEDUCTION", "label": "DEDUCTION", "subtitle": "Tax deductions"},
          ],
          "onOptionChanged": (String val) {
            setState(() {
              _selectedArrearDeductionOption = val;
            });
          },
        },
        {
          "key": "ITAX FORM",
          "label": "ITAX FORM",
          "subtitle": "Official generation",
          "icon": Icons.description_rounded,
          "color": const Color(0xFF2563EB),
        },
        {
          "key": "TAX EXPORT",
          "label": "TAX EXPORT",
          "subtitle": "Download current",
          "icon": Icons.file_download_rounded,
          "color": const Color(0xFF0891B2),
        },
        {
          "key": "ARREAR - CALC",
          "label": "ARREAR - CALC",
          "subtitle": "Arrear calculation",
          "icon": Icons.calculate_rounded,
          "color": const Color(0xFF4F46E5),
        },
        {
          "key": "EXPORT ALL",
          "label": "EXPORT ALL",
          "subtitle": "Complete backup",
          "icon": Icons.archive_rounded,
          "color": const Color(0xFF0D9488),
        },
        {
          "key": "TDS_COMBINED",
          "label": "TDS AND TDS-0",
          "subtitle": _selectedTdsOption == 'TDS - 0' ? "Zero rate standard" : "Standard deduction",
          "icon": _selectedTdsOption == 'TDS - 0'
              ? Icons.receipt_rounded
              : Icons.receipt_long_rounded,
          "color": _selectedTdsOption == 'TDS - 0'
              ? const Color(0xFFCA8A04)
              : const Color(0xFFEA580C),
          "hasDropdown": true,
          "currentValue": _selectedTdsOption,
          "dropdownOptions": [
            {"value": "TDS - 0", "label": "TDS - 0", "subtitle": "Zero rate standard"},
            {"value": "TDS", "label": "TDS", "subtitle": "Standard deduction"},
          ],
          "onOptionChanged": (String val) {
            setState(() {
              _selectedTdsOption = val;
            });
          },
        },
        {
          "key": "DA%",
          "label": "DA%",
          "subtitle": "Dearness allowance",
          "icon": Icons.percent_rounded,
          "color": const Color(0xFF059669),
        },
      ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
    _fetchTotalRecords();
  }

  Future<void> _fetchTotalRecords() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref();
      final mainDataSnap = await dbRef.child('${sharedData.userPlace}/maindata').get();
      int count = 0;
      if (mainDataSnap.exists && mainDataSnap.value != null) {
        final recordsMap = parseFirebaseSnapshotToMap(mainDataSnap.value);
        count = recordsMap.length;
      }
      if (mounted) {
        setState(() {
          _totalEmployeeRecords = count;
          _isFetchingRecords = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching total records on home page: $e');
      if (mounted) {
        setState(() {
          _isFetchingRecords = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final nav = Navigator.of(context);
    final confirmLogout = await _showConfirmDialog(
      "Confirm Logout",
      "Are you sure you want to end your current session?",
      Icons.logout_rounded,
      isDestructive: true,
    );
    if (confirmLogout == true && mounted) {
      if (sharedData.isAdmin) {
        nav.pushReplacement(MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
      } else {
        nav.pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          Column(
            children: [
              if (sharedData.isAdmin) _buildAdminBanner(),
              if (sharedData.isYearFrozen) _buildFrozenBanner(),
              _buildTopNavigation(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildGrid(),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Admin Mode: Viewing Dashboard for "${sharedData.viewingAsUsername ?? sharedData.userPlace.split('/').last}" (Center: ${sharedData.zone})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                  );
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrozenBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF2F2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFDC2626), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Financial Year ${sharedData.ccurrentYear} is FROZEN by Administrator. All data is read-only.',
                  style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (isMobile ? 10 : 16),
        bottom: isMobile ? 10 : 16,
        left: isMobile ? 12 : 20,
        right: isMobile ? 12 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Income Tax Portal',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Select a module to manage entries',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout_rounded, size: 14),
                          label: const Text('Logout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            foregroundColor: const Color(0xFFE11D48),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 14, color: Color(0xFF2563EB)),
                              const SizedBox(width: 4),
                              Text(
                                _isFetchingRecords
                                    ? 'Loading...'
                                    : 'Records: $_totalEmployeeRecords',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFF475569)),
                              const SizedBox(width: 4),
                              Text(
                                'FY: ${sharedData.ccurrentYear}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1D4ED8), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Income Tax Portal',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Select a module to manage your entries',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 6),
                              Text(
                                _isFetchingRecords
                                    ? 'Loading...'
                                    : 'Total Records: $_totalEmployeeRecords',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF475569)),
                              const SizedBox(width: 6),
                              Text(
                                'FY: ${sharedData.ccurrentYear}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text('Logout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            foregroundColor: const Color(0xFFE11D48),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: isMobile
              ? const EdgeInsets.fromLTRB(12, 12, 12, 20)
              : const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: isMobile ? 600 : 360,
              mainAxisExtent: isMobile ? 68 : 96,
              crossAxisSpacing: isMobile ? 8 : 24,
              mainAxisSpacing: isMobile ? 8 : 24,
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final delay = (index * 0.04).clamp(0.0, 1.0);

              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
                ),
              );

              final fadeAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(delay, 1.0, curve: Curves.easeOut),
                ),
              );

              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: DashboardActionTile(
                    label: item["label"],
                    subtitle: item["subtitle"],
                    icon: item["icon"],
                    color: item["color"],
                    hasDropdown: item["hasDropdown"] ?? false,
                    dropdownOptions: item["dropdownOptions"] != null
                        ? List<Map<String, String>>.from(item["dropdownOptions"])
                        : null,
                    currentValue: item["currentValue"],
                    onOptionChanged: item["onOptionChanged"],
                    onPressed: () => _handleMenuAction(item, context),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        color: const Color(0xFF0F172A).withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  height: 44,
                  width: 44,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(Map<String, dynamic> item, BuildContext context) async {
    final nav = Navigator.of(context);
    String key = item["key"] ?? item["label"];
    Widget? page;

    switch (key) {
      case "MAIN":
        page = const MainDataPage();
        break;
      case "MONTH":
        page = const MonthDataPage();
        break;
      case "ARREAR_DEDUCTION":
        if (_selectedArrearDeductionOption == 'ARREAR') {
          page = const ArrearPage();
        } else {
          page = const DeductionPage();
        }
        break;
      case "ITAX FORM":
        page = const ItaxPage();
        break;
      case "TAX EXPORT":
        final confirm = await _showConfirmDialog(
          "Export Tax Data",
          "Are you sure you want to generate and export the tax data?",
          Icons.file_download_rounded,
        );
        if (confirm == true) {
          _executeExport(createExcel);
        }
        return;
      case "ARREAR - CALC":
        page = const CalcArrearPage();
        break;
      case "EXPORT ALL":
        final confirmAll = await _showConfirmDialog(
          "Export All Data",
          "Are you sure you want to export the entire database?",
          Icons.archive_rounded,
        );
        if (confirmAll == true) {
          _executeExport(exportAll);
        }
        return;
      case "TDS_COMBINED":
        if (_selectedTdsOption == 'TDS - 0') {
          final confirmTDSZero = await _showConfirmDialog(
            "Export TDS (0%)",
            "Are you sure you want to export TDS data with a 0% rate?",
            Icons.receipt_rounded,
          );
          if (confirmTDSZero == true) {
            _executeExport(() => exportExcel(true));
          }
        } else {
          final confirmTDS = await _showConfirmDialog(
            "Export TDS",
            "Are you sure you want to export the standard TDS data?",
            Icons.receipt_long_rounded,
          );
          if (confirmTDS == true) {
            _executeExport(() => exportExcel(false));
          }
        }
        return;
      case "DA%":
        page = const DaPage();
        break;
    }

    if (page != null) {
      nav.push(MaterialPageRoute(builder: (context) => page!)).then((_) {
        _fetchTotalRecords();
      });
    }
  }

  Future<void> _executeExport(Future<void> Function() exportFunction) async {
    setState(() => _isLoading = true);
    try {
      await exportFunction();
    } catch (e) {
      if (!mounted) return;
      _showModernSnackbar('Operation Failed', e.toString(), Icons.error_outline_rounded, const Color(0xFFEF4444));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content, IconData icon, {bool isDestructive = false}) {
    final primaryColor = isDestructive ? const Color(0xFFE11D48) : const Color(0xFF2563EB);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 40.0,
                offset: const Offset(0.0, 15.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
                ),
                child: Icon(icon, color: primaryColor, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernSnackbar(String title, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class DashboardActionTile extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool hasDropdown;
  final List<Map<String, String>>? dropdownOptions;
  final String? currentValue;
  final ValueChanged<String>? onOptionChanged;

  const DashboardActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.hasDropdown = false,
    this.dropdownOptions,
    this.currentValue,
    this.onOptionChanged,
    super.key,
  });

  @override
  State<DashboardActionTile> createState() => _DashboardActionTileState();
}

class _DashboardActionTileState extends State<DashboardActionTile> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() => _isHovered = isHovered);
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) {
          _hoverController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  border: Border.all(
                    color: _isHovered ? widget.color : const Color(0xFFCBD5E1),
                    width: _isHovered ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? widget.color.withValues(alpha: 0.15)
                          : const Color(0xFF64748B).withValues(alpha: 0.04),
                      blurRadius: _isHovered ? 12 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 16,
                    vertical: isMobile ? 8 : 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: isMobile ? 40 : 52,
                        width: isMobile ? 40 : 52,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          border: Border.all(
                            color: widget.color.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: isMobile ? 22 : 26,
                          color: widget.color,
                        ),
                      ),
                      SizedBox(width: isMobile ? 10 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: isMobile ? 1 : 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (widget.hasDropdown && widget.dropdownOptions != null) ...[
                        PopupMenuButton<String>(
                          tooltip: 'Switch Mode',
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 6 : 8,
                              vertical: isMobile ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.color.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.unfold_more_rounded,
                                  color: widget.color,
                                  size: isMobile ? 16 : 18,
                                ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          elevation: 8,
                          onSelected: (val) {
                            if (widget.onOptionChanged != null) {
                              widget.onOptionChanged!(val);
                            }
                          },
                          itemBuilder: (context) => widget.dropdownOptions!.map((opt) {
                            bool isSelected = opt["value"] == widget.currentValue;
                            return PopupMenuItem<String>(
                              value: opt["value"]!,
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? widget.color : const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt["label"]!,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                          color: isSelected
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF475569),
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        opt["subtitle"]!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: isMobile ? 4 : 6),
                      ],
                      SizedBox(width: isMobile ? 6 : 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(isMobile ? 4 : 6),
                        decoration: BoxDecoration(
                          color: _isHovered ? widget.color : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                          border: Border.all(
                            color: _isHovered ? widget.color : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: _isHovered ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
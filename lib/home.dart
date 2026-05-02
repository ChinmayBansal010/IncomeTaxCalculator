import 'dart:ui';
import 'package:flutter/material.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _menuItems = [
    {"label": "MAIN", "subtitle": "Core tax entries", "icon": Icons.dashboard_customize_rounded, "color": const Color(0xFF2563EB)},
    {"label": "DA%", "subtitle": "Dearness allowance", "icon": Icons.percent_rounded, "color": const Color(0xFF059669)},
    {"label": "MONTH", "subtitle": "Monthly statements", "icon": Icons.calendar_month_rounded, "color": const Color(0xFFD97706)},
    {"label": "ARREAR", "subtitle": "Pending clearings", "icon": Icons.account_balance_wallet_rounded, "color": const Color(0xFF7C3AED)},
    {"label": "DEDUCTION", "subtitle": "Tax deductions", "icon": Icons.remove_circle_outline_rounded, "color": const Color(0xFFDC2626)},
    {"label": "ITAX FORM", "subtitle": "Official generation", "icon": Icons.description_rounded, "color": const Color(0xFF2563EB)},
    {"label": "TAX EXPORT", "subtitle": "Download current", "icon": Icons.file_download_rounded, "color": const Color(0xFF0891B2)},
    {"label": "ARREAR - CALC", "subtitle": "Arrear processing", "icon": Icons.calculate_rounded, "color": const Color(0xFF4F46E5)},
    {"label": "EXPORT ALL", "subtitle": "Complete backup", "icon": Icons.archive_rounded, "color": const Color(0xFF0D9488)},
    {"label": "TDS", "subtitle": "Standard deduction", "icon": Icons.receipt_long_rounded, "color": const Color(0xFFEA580C)},
    {"label": "TDS - 0", "subtitle": "Zero rate standard", "icon": Icons.receipt_rounded, "color": const Color(0xFFCA8A04)},
    {"label": "LOGOUT", "subtitle": "End session securely", "icon": Icons.logout_rounded, "color": const Color(0xFFE11D48)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
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

  Widget _buildTopNavigation() {
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
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 32,
        right: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1D4ED8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Income Tax Portal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Select a module to manage your entries',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Text(
                      'FY: ${sharedData.ccurrentYear}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisExtent: 96,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
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
                onPressed: () => _handleMenuAction(item["label"], context),
              ),
            ),
          );
        },
      ),
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

  Future<void> _handleMenuAction(String label, BuildContext context) async {
    switch (label) {
      case "MAIN":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainDataPage()));
        break;
      case "DA%":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DaPage()));
        break;
      case "MONTH":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthDataPage()));
        break;
      case "ARREAR":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ArrearPage()));
        break;
      case "DEDUCTION":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeductionPage()));
        break;
      case "ITAX FORM":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ItaxPage()));
        break;
      case "TAX EXPORT":
        final confirm = await _showConfirmDialog(
          "Export Tax Data",
          "Are you sure you want to generate and export the tax data?",
          Icons.file_download_rounded,
        );
        if (confirm != true) break;
        _executeExport(createExcel);
        break;
      case "ARREAR - CALC":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalcArrearPage()));
        break;
      case "EXPORT ALL":
        final confirmAll = await _showConfirmDialog(
          "Export All Data",
          "Are you sure you want to export the entire database?",
          Icons.archive_rounded,
        );
        if (confirmAll != true) break;
        _executeExport(exportAll);
        break;
      case "TDS":
        final confirmTDS = await _showConfirmDialog(
          "Export TDS",
          "Are you sure you want to export the standard TDS data?",
          Icons.receipt_long_rounded,
        );
        if (confirmTDS != true) break;
        _executeExport(() => exportExcel(false));
        break;
      case "TDS - 0":
        final confirmTDSZero = await _showConfirmDialog(
          "Export TDS (0%)",
          "Are you sure you want to export TDS data with a 0% rate?",
          Icons.receipt_rounded,
        );
        if (confirmTDSZero != true) break;
        _executeExport(() => exportExcel(true));
        break;
      case "LOGOUT":
        final confirmLogout = await _showConfirmDialog(
          "Confirm Logout",
          "Are you sure you want to end your current session?",
          Icons.logout_rounded,
          isDestructive: true,
        );
        if (confirmLogout == true && mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        }
        break;
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

  const DashboardActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
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
                  borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.color.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 26,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isHovered ? widget.color : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
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
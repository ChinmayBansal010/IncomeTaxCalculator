import 'package:flutter/material.dart';
import 'month_update.dart';

class MonthNavigationPage extends StatefulWidget {
  final String biometricId;

  const MonthNavigationPage({required this.biometricId, super.key});

  @override
  State<MonthNavigationPage> createState() => _MonthNavigationPageState();
}

class _MonthNavigationPageState extends State<MonthNavigationPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _monthsData = [
    {'label': 'MARCH', 'short': 'mar', 'icon': Icons.local_florist_rounded, 'color': const Color(0xFF2563EB)},   // Spring bloom
    {'label': 'APRIL', 'short': 'apr', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF059669)},      // Rainy vibe
    {'label': 'MAY', 'short': 'may', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFD97706)},         // Summer starts
    {'label': 'JUNE', 'short': 'jun', 'icon': Icons.beach_access_rounded, 'color': const Color(0xFF7C3AED)},    // Vacation season
    {'label': 'JULY', 'short': 'jul', 'icon': Icons.thermostat_rounded, 'color': const Color(0xFFDC2626)},      // Peak heat, humanity melting
    {'label': 'AUGUST', 'short': 'aug', 'icon': Icons.flag_rounded, 'color': const Color(0xFF0891B2)},          // Independence month in India
    {'label': 'SEPTEMBER', 'short': 'sept', 'icon': Icons.school_rounded, 'color': const Color(0xFF4F46E5)},    // Academic mood returns
    {'label': 'OCTOBER', 'short': 'oct', 'icon': Icons.celebration_rounded, 'color': const Color(0xFF0D9488)}, // Festival season
    {'label': 'NOVEMBER', 'short': 'nov', 'icon': Icons.nights_stay_rounded, 'color': const Color(0xFFEA580C)}, // Cooler nights
    {'label': 'DECEMBER', 'short': 'dec', 'icon': Icons.ac_unit_rounded, 'color': const Color(0xFFCA8A04)},     // Winter
    {'label': 'JANUARY', 'short': 'jan', 'icon': Icons.restart_alt_rounded, 'color': const Color(0xFFE11D48)},  // New year, new lies
    {'label': 'FEBRUARY', 'short': 'feb', 'icon': Icons.favorite_rounded, 'color': const Color(0xFF4F46E5)},    // Valentine's capitalism
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    height: 250,
                    width: 250,
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildCustomAppBar(),
                    Expanded(
                      child: _buildGrid(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Monthly Statements",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "ID: ${widget.biometricId}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;

    final int crossAxisCount =
    screenWidth < 600 ? 1 :
    screenWidth < 1000 ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 100,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _monthsData.length,
      itemBuilder: (context, index) {
        final month = _monthsData[index];
        final delay = (index * 0.05).clamp(0.0, 1.0);

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.4),
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
            child: MonthActionTile(
              label: month['label'],
              subtitle: "Edit statements for ${month['label'].toLowerCase()}",
              icon: month['icon'],
              color: month['color'],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthDataPage(
                      biometricId: widget.biometricId,
                      shortMonth: month['short'],
                      longMonth: month['label'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MonthActionTile extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const MonthActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    super.key,
  });

  @override
  State<MonthActionTile> createState() => _MonthActionTileState();
}

class _MonthActionTileState extends State<MonthActionTile> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _hoverController.reverse(),
        onTapUp: (_) {
          if (_isHovered) _hoverController.forward();
          widget.onPressed();
        },
        onTapCancel: () {
          if (_isHovered) _hoverController.forward();
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -3 * _elevationAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered ? widget.color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                      width: _isHovered ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.05 + (0.1 * _elevationAnimation.value)),
                        blurRadius: 10 + (10 * _elevationAnimation.value),
                        offset: Offset(0, 4 + (4 * _elevationAnimation.value)),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 28,
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isHovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: _isHovered ? widget.color : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
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
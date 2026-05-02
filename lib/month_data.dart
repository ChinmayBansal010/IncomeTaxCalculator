import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/monthpages/month_navigation.dart';
import 'shared.dart';

class MonthDataPage extends StatefulWidget {
  const MonthDataPage({super.key});
  @override
  State<MonthDataPage> createState() => _MonthDataPageState();
}

class _MonthDataPageState extends State<MonthDataPage> with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late DatabaseReference bioRef;
  Map<String, Map<String, dynamic>> biometricData = {};
  Map<String, Map<String, dynamic>> filteredData = {};
  List<String> sortedKeys = [];
  bool isLoading = true;
  bool shouldRefetch = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    bioRef = _dbRef.child(sharedData.userPlace).child('maindata');
    fetchData();
    searchController.addListener(_filterData);
  }

  Future<void> fetchData() async {
    try {
      DatabaseEvent event = await bioRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        Map<String, Map<String, dynamic>> data = {};

        rawData.forEach((key, value) {
          if (key is String && value is Map) {
            data[key] = Map<String, dynamic>.from(value);
          }
        });

        if (mounted) {
          setState(() {
            biometricData = data;
            filteredData = data;
            _updateSortedKeys();
            isLoading = false;
            shouldRefetch = false;
          });
          _animationController.forward(from: 0.0);
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'No data available';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error fetching data: $e';
          isLoading = false;
        });
      }
    }
  }

  void _filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = Map.fromEntries(biometricData.entries.where((entry) {
        String biometricId = entry.key.toLowerCase();
        String name = entry.value['name']?.toLowerCase() ?? '';
        return biometricId.contains(query) || name.contains(query);
      }));
      _updateSortedKeys();
    });
  }

  void _updateSortedKeys() {
    sortedKeys = filteredData.keys.toList()..sort();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.removeListener(_filterData);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Container(
            height: 260,
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
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildCustomAppBar(),
                    _buildFloatingSearchBar(),
                    Expanded(
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Stack(
      //   fit: StackFit.expand,
      //   children: [
      //     Positioned(
      //       bottom: 16,
      //       right: 16,
      //       child: CustomFloatingButton(
      //         label: 'COPY',
      //         icon: Icons.copy_rounded,
      //         onPressed: () {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text('Copy functionality executed!')),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              onPressed: () => Navigator.pop(context, true),
              tooltip: 'Go Back',
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
                          const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isLoading ? "Loading..." : "FY: ${sharedData.ccurrentYear}",
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
              Icons.date_range_rounded,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 12),
              child: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 26),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search by employee name or ID...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  onPressed: () {
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return _buildLoadingState();
    }
    if (errorMessage.isNotEmpty) {
      return _buildErrorState();
    }
    if (sortedKeys.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String biometricId = sortedKeys[index];
        Map<String, dynamic> details = filteredData[biometricId]!;

        final delay = (index * 0.03).clamp(0.0, 1.0);
        final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
          ),
        );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EmployeeMonthCard(
                biometricId: biometricId,
                name: details['name'] ?? 'Unknown',
                onTap: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthNavigationPage(
                        biometricId: biometricId,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      isLoading = true;
                      shouldRefetch = true;
                    });
                    bioRef = _dbRef.child(sharedData.userPlace).child('maindata');
                    fetchData();
                    searchController.addListener(_filterData);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Fetching Directory...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we load the data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Employees Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adjust your search criteria and try again.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFECACA), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                "Try Again",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeMonthCard extends StatefulWidget {
  final String biometricId;
  final String name;
  final VoidCallback onTap;

  const EmployeeMonthCard({
    required this.biometricId,
    required this.name,
    required this.onTap,
    super.key,
  });

  @override
  State<EmployeeMonthCard> createState() => _EmployeeMonthCardState();
}

class _EmployeeMonthCardState extends State<EmployeeMonthCard> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color _getAvatarColor(String name) {
    final colors = const [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    int hash = name.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Color avatarColor = _getAvatarColor(widget.name);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _hoverController.reverse(),
        onTapUp: (_) {
          _hoverController.forward();
          widget.onTap();
        },
        onTapCancel: () => _hoverController.forward(),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered ? avatarColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                    width: _isHovered ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? avatarColor.withValues(alpha: 0.15)
                          : const Color(0xFF64748B).withValues(alpha: 0.05),
                      blurRadius: _isHovered ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isHovered ? 8 : 4,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: avatarColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: avatarColor.withValues(alpha: 0.2), width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(widget.name),
                                    style: TextStyle(
                                      color: avatarColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.badge_rounded, size: 12, color: Color(0xFF475569)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "ID: ${widget.biometricId}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _isHovered ? avatarColor : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isHovered ? avatarColor : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: _isHovered ? Colors.white : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
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

class CustomFloatingButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomFloatingButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  CustomFloatingButtonState createState() => CustomFloatingButtonState();
}

class CustomFloatingButtonState extends State<CustomFloatingButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: isHovered ? 0.3 : 0.15),
                blurRadius: isHovered ? 20 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: Icon(widget.icon, size: 24, color: Colors.white),
            label: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
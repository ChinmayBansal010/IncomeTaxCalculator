import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incometax/arrear/arrear_save.dart';
import 'package:incometax/monthpages/month_update.dart';
import 'package:incometax/shared.dart';

class EcrPreviewPage extends StatefulWidget {
  final String biometricId;

  const EcrPreviewPage({
    super.key,
    required this.biometricId,
  });

  @override
  State<EcrPreviewPage> createState() => _EcrPreviewPageState();
}

class _EcrPreviewPageState extends State<EcrPreviewPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('en_IN');
  final ScrollController _matrixScrollController = ScrollController();

  bool _isLoading = true;
  String _errorMessage = '';
  _EcrPreviewData? _previewData;
  bool _showNewTaxSheet = false;
  bool _showOldTaxSheet = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _matrixScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userRef = _dbRef.child(sharedData.userPlace);

      final results = await Future.wait([
        userRef.child('maindata').child(widget.biometricId).once(),
        userRef.child('monthdata').once(),
        userRef.child('arrdata').child(widget.biometricId).once(),
        userRef.child('deddata').child(widget.biometricId).once(),
        userRef.child('itfdata').child(widget.biometricId).once(),
        userRef.child('itaxnew').child(widget.biometricId).once(),
        userRef.child('itaxold').child(widget.biometricId).once(),
      ]);

      final mainData = _snapshotMap(results[0].snapshot.value);
      final allMonthData = _snapshotMap(results[1].snapshot.value);
      final arrearData = _snapshotMap(results[2].snapshot.value);
      final dedData = _snapshotMap(results[3].snapshot.value);
      final itfData = _snapshotMap(results[4].snapshot.value);
      final itaxNew = _snapshotMap(results[5].snapshot.value);
      final itaxOld = _snapshotMap(results[6].snapshot.value);

      if (mainData.isEmpty) {
        throw Exception('No employee data found for ${widget.biometricId}.');
      }

      final monthData = <String, Map<String, dynamic>>{};
      for (final month in _orderedMonthKeys) {
        monthData[month] =
            _snapshotMap(allMonthData[month]?[widget.biometricId]);
      }

      final previewData = _buildPreviewData(
        mainData: mainData,
        monthData: monthData,
        arrearData: arrearData,
        dedData: dedData,
        itfData: itfData,
        itaxNew: itaxNew,
        itaxOld: itaxOld,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _previewData = previewData;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Failed to load ECR preview:\n$error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewData;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          Container(
            height: 320,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020617), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF59E0B), width: 5),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 15,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -80,
                  child: Container(
                    height: 320,
                    width: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.transparent
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ))
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : preview == null
                ? _buildErrorState()
                : RefreshIndicator(
              onRefresh: _loadPreview,
              color: const Color(0xFF1D4ED8),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _buildHeader(preview),
                  const SizedBox(height: 24),
                  _buildSummaryStrip(preview),
                  const SizedBox(height: 24),
                  _buildEmployeeCard(preview),
                  const SizedBox(height: 24),
                  // _buildTaxSnapshotCard(preview),
                  // const SizedBox(height: 24),
                  _buildTaxSheetDetailSection(preview),
                  const SizedBox(height: 24),
                  _buildCombinedMatrixCard(preview),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_EcrPreviewData preview) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF60A5FA), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF93C5FD), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return Text(
                    'ECR PREVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth < 250 ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border:
                    Border.all(color: const Color(0xFF64748B), width: 2),
                  ),
                  child: Text(
                    '${preview.mainData['name'] ?? ''}  \nID: ${widget.biometricId}',
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: _buildHeaderChip(
                      Icons.apartment_rounded,
                      sharedData.zone.toUpperCase(),
                      const Color(0xFF10B981)),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Forces elements to align to the left
                  children: [
                    _buildHeaderChip(
                        Icons.calendar_month_rounded,
                        sharedData.ccurrentYear,
                        const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              tooltip: 'Refresh Preview',
              onPressed: _loadPreview,
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 2.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(_EcrPreviewData preview) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final children = [
          _buildSummaryCard(
            title: 'New Regime Payable',
            value:  _formatCurrency(_toInt(preview.itaxNew['ttp'])),
            icon: Icons.payments_rounded,
            accent: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
          _buildSummaryCard(
            title: 'New Regime Balance',
            value:  _formatCurrency(_toInt(preview.itaxNew['nitpi'])),
            icon: Icons.payments_rounded,
            accent: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
          _buildSummaryCard(
            title: 'New Regime Excess Paid',
            value: _formatCurrency(_toInt(preview.itaxNew['ep'])),
            icon: Icons.remove_circle_outline_rounded,
            accent: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
          ),
          _buildSummaryCard(
            title: 'Old Regime Payable',
            value:  _formatCurrency(_toInt(preview.itaxOld['ttp'])),
            icon: Icons.payments_rounded,
            accent: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
          _buildSummaryCard(
            title: 'Old Regime Balance',
            value: _formatCurrency(_toInt(preview.itaxOld['nitpi'])),
            icon: Icons.account_balance_wallet_rounded,
            accent: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
          ),
          _buildSummaryCard(
            title: 'Old Regime Excess Paid',
            value: _formatCurrency(_toInt(preview.itaxOld['ep'])),
            icon: Icons.receipt_rounded,
            accent: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF5F3FF),
          ),
          _buildSummaryCard(
            title: 'Tax Already Paid',
            value:  _formatCurrency(_toInt(preview.itaxNew['deduct'])),
            icon: Icons.payments_rounded,
            accent: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ];

        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 840
                ? 3
                : width >= 560
                    ? 2
                    : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 126,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
    required Color bgColor,
  }) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: accent.withValues(alpha: 0.8),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: accent.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(_EcrPreviewData preview) {
    final items = [
      _InfoItem('Biometric ID', widget.biometricId),
      _InfoItem('Name', '${preview.mainData['name'] ?? ''}'),
      _InfoItem('F/H Name', '${preview.mainData['fhname'] ?? ''}'),
      _InfoItem('Designation', '${preview.mainData['designation'] ?? ''}'),
      _InfoItem('Group', '${preview.mainData['group'] ?? ''}'),
      _InfoItem('Employee Type', '${preview.mainData['emptype'] ?? ''}'),
      _InfoItem('PAN No.', '${preview.mainData['panno'] ?? ''}'),
      _InfoItem('GPF No.', '${preview.mainData['gpfno'] ?? ''}'),
      _InfoItem('NPS No.', '${preview.mainData['npsno'] ?? ''}'),
      _InfoItem('DOB', '${preview.mainData['dob'] ?? ''}'),
      _InfoItem('Pay Scale', '${preview.mainData['payscale'] ?? ''}'),
      _InfoItem('Place of Duty', '${preview.mainData['place'] ?? ''}'),
      _InfoItem('Address', '${preview.mainData['address'] ?? ''}'),
    ];

    return _buildSurfaceCard(
      title: 'Employee Snapshot',
      subtitle:
      'Core identity fields copied from the same employee record used during export.',
      icon: Icons.badge_rounded,
      accent: const Color(0xFF2563EB),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
          constraints.maxWidth > 600 ? 280.0 : constraints.maxWidth;
          const itemSpacing = 16.0;
          final columnCount = constraints.maxWidth > 600
              ? ((constraints.maxWidth + itemSpacing) /
                      (cardWidth + itemSpacing))
                  .floor()
                  .clamp(1, items.length)
              : 1;
          final rowWidth =
              (columnCount * cardWidth) + ((columnCount - 1) * itemSpacing);

          return Wrap(
            spacing: itemSpacing,
            runSpacing: itemSpacing,
            children: items
                .map(
                  (item) => SizedBox(
                width: item.label == 'Address'
                    ? rowWidth
                    : cardWidth,
                child: Container(
                  clipBehavior: Clip.antiAlias, // Ensures inner border trims correctly
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF94A3B8), width: 1.5), // Uniform border for radius
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF2563EB), width: 6), // Inner straight left border
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.value.isEmpty ? 'N/A' : item.value,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: item.label == 'Address' ? 1 : null,
                          overflow: item.label == 'Address'
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                          softWrap: item.label != 'Address',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          );
        },
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTaxSnapshotCard(_EcrPreviewData preview) {
    final metrics = [
      _InfoItem(
          'Taxable Gross', _formatCurrency(_toInt(preview.itaxNew['tg']))),
      _InfoItem('Conv + Drive',
          _formatCurrency(_toInt(preview.itaxNew['convdrive']))),
      _InfoItem('Uniform Exemption',
          _formatCurrency(_toInt(preview.itaxNew['uniform']))),
      _InfoItem('Gross Taxable Income',
          _formatCurrency(_toInt(preview.itaxNew['gti']))),
      _InfoItem('Employer NPS 80CCD(2)',
          _formatCurrency(_toInt(preview.itaxNew['atccd2']))),
      _InfoItem('Total Income', _formatCurrency(_toInt(preview.itaxNew['ti']))),
      _InfoItem(
          'Standard Deduction', _formatCurrency(_toInt(preview.itaxNew['sd']))),
      _InfoItem(
          'Other Deduction', _formatCurrency(_toInt(preview.itaxNew['other']))),
      _InfoItem('Taxable Total Income',
          _formatCurrency(_toInt(preview.itaxNew['tti']))),
      _InfoItem(
          'Education Cess', _formatCurrency(_toInt(preview.itaxNew['ec']))),
      _InfoItem('Tax Payable', _formatCurrency(_toInt(preview.itaxNew['ttp']))),
      _InfoItem('Already Deducted',
          _formatCurrency(_toInt(preview.itaxNew['deduct']))),
      _InfoItem('Balance Before Relief',
          _formatCurrency(_toInt(preview.itaxNew['nitp']))),
      _InfoItem('Relief', _formatCurrency(_toInt(preview.itaxNew['relief']))),
      _InfoItem('Final New Regime Balance',
          _formatCurrency(_toInt(preview.itaxNew['nitpi']))),
      _InfoItem('New Regime Excess Paid',
          _formatCurrency(_toInt(preview.itaxNew['ep']))),
      _InfoItem('Old Regime Balance',
          _formatCurrency(_toInt(preview.itaxOld['nitpi']))),
      _InfoItem('Old Regime Excess Paid',
          _formatCurrency(_toInt(preview.itaxOld['ep']))),
    ];

    return _buildSurfaceCard(
      title: 'Tax Snapshot',
      subtitle:
      'Read-only figures from the generated ITAX calculation used by the ECR preview.',
      icon: Icons.calculate_rounded,
      accent: const Color(0xFF7C3AED),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
          constraints.maxWidth > 600 ? 220.0 : constraints.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: metrics
                .map(
                  (metric) => SizedBox(
                width: cardWidth,
                child: Container(
                  clipBehavior: Clip.antiAlias, // Ensures inner border trims correctly
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF94A3B8), width: 1.5), // Uniform border for radius
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF7C3AED), width: 6), // Inner straight left border
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.label.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            metric.value,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildTaxSheetDetailSection(_EcrPreviewData preview) {
    final showBoth = _showNewTaxSheet && _showOldTaxSheet;

    return _buildSurfaceCard(
      title: 'Income Tax Sheet Details',
      subtitle:
      'Full old-regime and new-regime sheet fields from the ITAX calculation, available side by side.',
      icon: Icons.view_sidebar_rounded,
      accent: const Color(0xFF0F766E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTaxToggleButton(
                label: _showNewTaxSheet ? 'HIDE NEW SHEET' : 'SHOW NEW SHEET',
                icon: Icons.auto_graph_rounded,
                isActive: _showNewTaxSheet,
                accent: const Color(0xFF2563EB),
                onTap: () =>
                    setState(() => _showNewTaxSheet = !_showNewTaxSheet),
              ),
              _buildTaxToggleButton(
                label: _showOldTaxSheet ? 'HIDE OLD SHEET' : 'SHOW OLD SHEET',
                icon: Icons.history_edu_rounded,
                isActive: _showOldTaxSheet,
                accent: const Color(0xFF0F766E),
                onTap: () =>
                    setState(() => _showOldTaxSheet = !_showOldTaxSheet),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_showNewTaxSheet || _showOldTaxSheet)
            LayoutBuilder(
              builder: (context, constraints) {
                final canShowSideBySide =
                    showBoth && constraints.maxWidth > 1100;

                if (canShowSideBySide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTaxSheetPanel(
                          preview.newSheetDetail,
                          accent: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildTaxSheetPanel(
                          preview.oldSheetDetail,
                          accent: const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    if (_showNewTaxSheet)
                      _buildTaxSheetPanel(
                        preview.newSheetDetail,
                        accent: const Color(0xFF2563EB),
                      ),
                    if (_showNewTaxSheet && _showOldTaxSheet)
                      const SizedBox(height: 24),
                    if (_showOldTaxSheet)
                      _buildTaxSheetPanel(
                        preview.oldSheetDetail,
                        accent: const Color(0xFF0F766E),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaxToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
            colors: [accent, accent.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Colors.white, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? accent.withValues(alpha: 0.9) : accent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isActive ? 0.4 : 0.1),
              blurRadius: isActive ? 12 : 4,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? Colors.white : accent),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : accent,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSheetPanel(
      _TaxSheetDetail detail, {
        required Color accent,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(detail.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    detail.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: detail.sections
                  .map(
                    (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildTaxSheetSectionCard(section, accent: accent),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSheetSectionCard(
      _TaxSheetSection section, {
        required Color accent,
      }) {
    final hasCodes = section.entries.any((e) => e.code.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                border: Border(
                  bottom: BorderSide(color: accent, width: 2),
                ),
              ),
              child: Text(
                section.title.toUpperCase(),
                style: TextStyle(
                  color: accent.withValues(alpha: 1.0),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Table(
              columnWidths: {
                if (hasCodes) 0: const IntrinsicColumnWidth(),
                if (hasCodes) 1: const FlexColumnWidth(),
                if (!hasCodes) 0: const FlexColumnWidth(),
                hasCodes ? 2 : 1: const IntrinsicColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: accent.withValues(alpha: 0.3), width: 1.5),
                verticalInside: BorderSide(
                    color: accent.withValues(alpha: 0.3), width: 1.5),
              ),
              children: section.entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                final codeCell = hasCodes
                    ? TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          item.code,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : null;

                final labelCell = TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: item.highlight
                            ? const Color(0xFF92400E)
                            : const Color(0xFF0F172A),
                        fontSize: 13.5,
                        fontWeight:
                        item.highlight ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ),
                );

                final valueCell = TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.highlight
                              ? Colors.white
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.highlight
                                ? const Color(0xFFD97706)
                                : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          item.value,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: item.highlight
                                ? const Color(0xFF92400E)
                                : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: item.highlight
                                ? FontWeight.w900
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                return TableRow(
                  decoration: BoxDecoration(
                    color: item.highlight
                        ? const Color(0xFFFDE68A)
                        : index.isEven
                        ? Colors.white
                        : const Color(0xFFF1F5F9),
                  ),
                  children: hasCodes
                      ? [codeCell!, labelCell, valueCell]
                      : [labelCell, valueCell],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedMatrixCard(_EcrPreviewData preview) {
    final visibleEarnings = _visibleColumns(preview.rows, _earningColumns);
    final visibleDeductions = _visibleColumns(preview.rows, _deductionColumns);
    final visibleColumns = [...visibleEarnings, ...visibleDeductions];

    final headerStyle = const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.5,
    );

    final cellStyle = const TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );

    return _buildSurfaceCard(
      title: 'ECR COMPLETE MATRIX',
      subtitle:
      'Unified Earnings and Deductions layout with distinct quarter and gross totals.',
      icon: Icons.table_view_rounded,
      accent: const Color(0xFF0EA5E9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Scrollbar(
                controller: _matrixScrollController,
                thumbVisibility: true,
                interactive: true,
                thickness: 8,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _matrixScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: const Color(0xFF94A3B8),
                    ),
                    child: DataTable(
                      border: const TableBorder(
                        horizontalInside:
                        BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        verticalInside:
                        BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      ),
                      columnSpacing: 7,
                      horizontalMargin: 0,
                      headingRowHeight: 45,
                      dataRowMinHeight: 25,
                      dataRowMaxHeight: 35,
                      headingRowColor:
                      const WidgetStatePropertyAll(Color(0xFF0F172A)),
                      columns: [
                        DataColumn(
                          label: Container(
                            width: 120,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF020617),
                            ),
                            child: Text(
                              'PERIOD',
                              textAlign: TextAlign.center,
                              style: headerStyle.copyWith(
                                color: const Color(0xFF38BDF8),
                                fontSize: 15,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        ...visibleColumns.map(
                              (column) {
                            final isNetSalary = column.key == 'netsalary';
                            return DataColumn(
                              label: Container(
                                width: 100,
                                alignment: Alignment.center,
                                child: Text(
                                  column.label.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: headerStyle.copyWith(
                                    color: isNetSalary
                                        ? const Color(0xFFFBBF24)
                                        : _earningColumns.contains(column)
                                        ? const Color(0xFF60A5FA)
                                        : const Color(0xFF34D399),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      rows: preview.rows.asMap().entries.map((entry) {
                        final rowIndex = entry.key;
                        final row = entry.value;
                        final isTotalRow = row.label.contains('QTR') ||
                            row.label == 'GROSS TOTAL';
                        final monthRoute = _monthRouteForPeriod(row.label);
                        final isArrearPeriod = _isArrearPeriod(row.label);
                        final canOpenPeriod =
                            monthRoute != null || isArrearPeriod;

                        return DataRow(
                          color: WidgetStatePropertyAll(
                            isTotalRow
                                ? const Color(0xFFCFD2EF)
                                : rowIndex.isEven
                                ? Colors.white
                                : const Color(0xFFF1F5F9),
                          ),
                          cells: [
                            DataCell(
                              MouseRegion(
                                cursor: canOpenPeriod
                                    ? SystemMouseCursors.click
                                    : MouseCursor.defer,
                                child: Tooltip(
                                  message: monthRoute != null
                                      ? 'Open ${monthRoute['long']} page'
                                      : isArrearPeriod
                                      ? 'Open arrear page'
                                      : '',
                                  child: Container(
                                    width: 120,
                                    height: double.infinity, // Forces edge-to-edge fill in cell
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isTotalRow
                                          ? const Color(0xFF4F46E5) // Vibrant Indigo for Total period
                                          : const Color(0xFF1E293B), // Deep Slate for normal period
                                    ),
                                    child: Text(
                                      row.label,
                                      style: TextStyle(
                                        color: canOpenPeriod
                                            ? const Color(0xFFBAE6FD)
                                            : Colors.white,
                                        fontSize: isTotalRow ? 16 : 14, // Larger, distinct size
                                        fontWeight: canOpenPeriod || isTotalRow
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        letterSpacing: 0.8,
                                        decoration: canOpenPeriod
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor:
                                        const Color(0xFFBAE6FD),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: canOpenPeriod
                                  ? () {
                                if (monthRoute != null) {
                                  _openMonthPage(monthRoute);
                                } else {
                                  _openArrearPage(preview);
                                }
                              }
                                  : null,
                            ),
                            ...visibleColumns.map(
                                  (column) {
                                final isNetSalary = column.key == 'netsalary';
                                return DataCell(
                                  Container(
                                    width: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _numberFormat.format(
                                        row.values[column.key] ?? 0,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: cellStyle.copyWith(
                                        color: isNetSalary
                                            ? const Color(0xFF059669)
                                            : isTotalRow
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFF0F172A),
                                        fontWeight: isNetSalary || isTotalRow
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        fontSize: isNetSalary ? 14 : 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
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

  Widget _buildSurfaceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF94A3B8), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF94A3B8), width: 2.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: accent.withValues(alpha: 0.3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDC2626), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444), width: 3),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFDC2626), size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'UNABLE TO LOAD PREVIEW',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: Text(
                  _errorMessage.isEmpty
                      ? 'No preview data available.'
                      : _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadPreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                  side: const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 24),
                label: const Text('RETRY LOADING',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return 'Rs ${_numberFormat.format(value)}';
  }

  List<_PreviewColumn> _visibleColumns(
      List<_EcrRow> rows,
      List<_PreviewColumn> columns,
      ) {
    return columns.where((column) {
      return rows.any((row) => (row.values[column.key] ?? 0) != 0);
    }).toList();
  }

  Map<String, String>? _monthRouteForPeriod(String period) {
    const monthRoutes = {
      'MAR': {'short': 'mar', 'long': 'MARCH'},
      'APR': {'short': 'apr', 'long': 'APRIL'},
      'MAY': {'short': 'may', 'long': 'MAY'},
      'JUN': {'short': 'jun', 'long': 'JUNE'},
      'JUL': {'short': 'jul', 'long': 'JULY'},
      'AUG': {'short': 'aug', 'long': 'AUGUST'},
      'SEPT': {'short': 'sept', 'long': 'SEPTEMBER'},
      'OCT': {'short': 'oct', 'long': 'OCTOBER'},
      'NOV': {'short': 'nov', 'long': 'NOVEMBER'},
      'DEC': {'short': 'dec', 'long': 'DECEMBER'},
      'JAN': {'short': 'jan', 'long': 'JANUARY'},
      'FEB': {'short': 'feb', 'long': 'FEBRUARY'},
    };

    return monthRoutes[period.toUpperCase()];
  }

  bool _isArrearPeriod(String period) {
    return const {
      'ARREAR Q1',
      'ARREAR Q2',
      'ARREAR Q3',
      'ARREAR Q4',
    }.contains(period.toUpperCase());
  }

  void _openMonthPage(Map<String, String> monthRoute) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthDataPage(
          biometricId: widget.biometricId,
          shortMonth: monthRoute['short']!,
          longMonth: monthRoute['long']!,
        ),
      ),
    );
  }

  Future<void> _openArrearPage(_EcrPreviewData preview) async {
    final arrearData = preview.arrearData;
    String value(String key) => arrearData[key]?.toString() ?? '0';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArrearUpdatePage(
          biometricId: widget.biometricId,
          name: preview.mainData['name']?.toString() ?? '',
          mmda: value('mmda'),
          mmhra: value('mmhra'),
          mmdaonta: value('mmdaonta'),
          mmpca: value('mmpca'),
          mmnpa: value('mmnpa'),
          mmtution: value('mmtution'),
          mmother: value('mmother'),
          mmext1: value('mmext1'),
          mmext2: value('mmext2'),
          mmext3: value('mmext3'),
          jada: value('jada'),
          jahra: value('jahra'),
          jadaonta: value('jadaonta'),
          japca: value('japca'),
          janpa: value('janpa'),
          jatution: value('jatution'),
          jaother: value('jaother'),
          jaext1: value('jaext1'),
          jaext2: value('jaext2'),
          jaext3: value('jaext3'),
          snda: value('snda'),
          snhra: value('snhra'),
          sndaonta: value('sndaonta'),
          snpca: value('snpca'),
          snnpa: value('snnpa'),
          sntution: value('sntution'),
          snother: value('snother'),
          snext1: value('snext1'),
          snext2: value('snext2'),
          snext3: value('snext3'),
          dfda: value('dfda'),
          dfhra: value('dfhra'),
          dfdaonta: value('dfdaonta'),
          dfpca: value('dfpca'),
          dfnpa: value('dfnpa'),
          dftution: value('dftution'),
          dfother: value('dfother'),
          dfext1: value('dfext1'),
          dfext2: value('dfext2'),
          dfext3: value('dfext3'),
          bonus: value('bonus'),
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadPreview();
    }
  }
}

_EcrPreviewData _buildPreviewData({
  required Map<String, dynamic> mainData,
  required Map<String, Map<String, dynamic>> monthData,
  required Map<String, dynamic> arrearData,
  required Map<String, dynamic> dedData,
  required Map<String, dynamic> itfData,
  required Map<String, dynamic> itaxNew,
  required Map<String, dynamic> itaxOld,
}) {
  final februaryEcrTax = _toInt(itaxNew['nitpi']);

  final marRow = _buildMonthRow('MAR', monthData['mar'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final aprRow = _buildMonthRow('APR', monthData['apr'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final mayRow = _buildMonthRow('MAY', monthData['may'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final arrearQ1Row = _buildArrearRow('ARREAR Q1', arrearData, 0);
  final qtr1Row =
  _sumRows('QTR - 1 TOTAL', [marRow, aprRow, mayRow, arrearQ1Row]);

  final junRow = _buildMonthRow('JUN', monthData['jun'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final julRow = _buildMonthRow('JUL', monthData['jul'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final augRow = _buildMonthRow('AUG', monthData['aug'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final arrearQ2Row = _buildArrearRow('ARREAR Q2', arrearData, 1);
  final qtr2Row =
  _sumRows('QTR - 2 TOTAL', [junRow, julRow, augRow, arrearQ2Row]);

  final septRow = _buildMonthRow('SEPT', monthData['sept'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final octRow = _buildMonthRow('OCT', monthData['oct'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final novRow = _buildMonthRow('NOV', monthData['nov'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final arrearQ3Row = _buildArrearRow('ARREAR Q3', arrearData, 2);
  final qtr3Row =
  _sumRows('QTR - 3 TOTAL', [septRow, octRow, novRow, arrearQ3Row]);

  final decRow = _buildMonthRow('DEC', monthData['dec'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final janRow = _buildMonthRow('JAN', monthData['jan'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: false);
  final febRow = _buildMonthRow('FEB', monthData['feb'] ?? {},
      februaryEcrTax: februaryEcrTax, isFebruary: true);
  final arrearQ4Row = _buildArrearRow('ARREAR Q4', arrearData, 3);
  final tutionRow = _buildTutionRow(arrearData);
  final bonusRow = _buildBonusRow(arrearData);
  final qtr4Row = _sumRows('QTR - 4 TOTAL',
      [decRow, janRow, febRow, arrearQ4Row, tutionRow, bonusRow]);

  final grossTotalRow =
  _sumRows('GROSS TOTAL', [qtr1Row, qtr2Row, qtr3Row, qtr4Row]);

  return _EcrPreviewData(
    mainData: mainData,
    arrearData: arrearData,
    dedData: dedData,
    itfData: itfData,
    itaxNew: itaxNew,
    itaxOld: itaxOld,
    rows: [
      marRow,
      aprRow,
      mayRow,
      arrearQ1Row,
      qtr1Row,
      junRow,
      julRow,
      augRow,
      arrearQ2Row,
      qtr2Row,
      septRow,
      octRow,
      novRow,
      arrearQ3Row,
      qtr3Row,
      decRow,
      janRow,
      febRow,
      arrearQ4Row,
      tutionRow,
      bonusRow,
      qtr4Row,
      grossTotalRow,
    ],
    grossTotal: grossTotalRow.values['gross'] ?? 0,
    totalDeduction: grossTotalRow.values['totalded'] ?? 0,
    netSalary: grossTotalRow.values['netsalary'] ?? 0,
    februaryEcrTax: februaryEcrTax,
    newSheetDetail: _buildNewTaxSheetDetail(itaxNew, dedData),
    oldSheetDetail: _buildOldTaxSheetDetail(mainData, itfData, dedData),
  );
}

_EcrRow _buildMonthRow(
    String label,
    Map<String, dynamic> monthValues, {
      required int februaryEcrTax,
      required bool isFebruary,
    }) {
  final values = _emptyValueMap();

  for (final column in _earningColumns) {
    if (column.key == 'otherEarning' || column.key == 'gross') {
      continue;
    }
    final monthKey = _earningMonthKeys[column.key];
    values[column.key] = monthKey == null ? 0 : _toInt(monthValues[monthKey]);
  }

  values['otherEarning'] = 0;
  values['gross'] = _sumValueMap(values, _earningComponentKeys);

  for (final column in _deductionColumns) {
    if (column.key == 'totalded' || column.key == 'netsalary') {
      continue;
    }
    final monthKey = _deductionMonthKeys[column.key];
    values[column.key] = monthKey == null ? 0 : _toInt(monthValues[monthKey]);
  }

  int totalDed = _toInt(monthValues['totalded']);
  int netSalary = _toInt(monthValues['netsalary']);

  if (isFebruary) {
    values['incometax'] = februaryEcrTax;
    totalDed += februaryEcrTax;
    netSalary -= februaryEcrTax;
  }

  values['totalded'] = totalDed;
  values['netsalary'] = netSalary;

  return _EcrRow(label: label, values: values);
}

_EcrRow _buildArrearRow(
    String label, Map<String, dynamic> arrearValues, int quarterIndex) {
  final values = _emptyValueMap();

  for (final column in _earningColumns) {
    if (column.key == 'gross') {
      continue;
    }

    if (column.key == 'otherEarning') {
      values[column.key] = _toInt(_arrearOtherKeys[quarterIndex].isEmpty
          ? 0
          : arrearValues[_arrearOtherKeys[quarterIndex]]);
      continue;
    }

    final arrearKey = _earningArrearKeys[column.key]?[quarterIndex];
    values[column.key] =
    arrearKey == null ? 0 : _toInt(arrearValues[arrearKey]);
  }

  values['gross'] = _sumValueMap(values, _earningComponentKeys);

  for (final column in _deductionColumns) {
    if (column.key == 'totalded' || column.key == 'netsalary') {
      continue;
    }
    values[column.key] = 0;
  }

  values['incometax'] = _toInt(arrearValues[_arrearTaxKeys[quarterIndex]]);
  values['totalded'] = values['incometax'] ?? 0;
  values['netsalary'] = (values['gross'] ?? 0) - (values['totalded'] ?? 0);

  return _EcrRow(label: label, values: values);
}

_EcrRow _buildTutionRow(Map<String, dynamic> arrearValues) {
  final values = _emptyValueMap();
  final tution = [
    _toInt(arrearValues['mmtution']),
    _toInt(arrearValues['jatution']),
    _toInt(arrearValues['sntution']),
    _toInt(arrearValues['dftution']),
  ].fold<int>(0, (sum, value) => sum + value);

  values['otherEarning'] = tution;
  values['gross'] = tution;
  values['netsalary'] = tution;

  return _EcrRow(label: 'TUTION', values: values);
}

_EcrRow _buildBonusRow(Map<String, dynamic> arrearValues) {
  final values = _emptyValueMap();
  final bonus = _toInt(arrearValues['bonus']);

  values['otherEarning'] = bonus;
  values['gross'] = bonus;
  values['netsalary'] = bonus;

  return _EcrRow(label: 'BONUS', values: values);
}

_EcrRow _sumRows(String label, List<_EcrRow> rows) {
  final values = _emptyValueMap();
  for (final row in rows) {
    for (final entry in row.values.entries) {
      values[entry.key] = (values[entry.key] ?? 0) + entry.value;
    }
  }
  return _EcrRow(label: label, values: values);
}

Map<String, int> _emptyValueMap() {
  final values = <String, int>{};
  for (final column in [..._earningColumns, ..._deductionColumns]) {
    values[column.key] = 0;
  }
  return values;
}

int _sumValueMap(Map<String, int> values, List<String> keys) {
  return keys.fold<int>(0, (sum, key) => sum + (values[key] ?? 0));
}

Map<String, dynamic> _snapshotMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '0') ?? 0;
}

String _detailAmount(int value) {
  return 'Rs ${NumberFormat.decimalPattern('en_IN').format(value)}';
}

_TaxSheetDetail _buildNewTaxSheetDetail(
    Map<String, dynamic> itaxNew,
    Map<String, dynamic> dedData,
    ) {
  final slabLabels = _newTaxSlabLabels();
  final slabValues = [
    _toInt(itaxNew['t1']),
    _toInt(itaxNew['t2']),
    _toInt(itaxNew['t3']),
    _toInt(itaxNew['t4']),
    _toInt(itaxNew['t5']),
    _toInt(itaxNew['t6']),
    _toInt(itaxNew['t7']),
  ];

  final slabEntries = <_TaxSheetEntry>[];
  for (int i = 0; i < slabLabels.length; i++) {
    slabEntries.add(
      _TaxSheetEntry(
        code: '(${_romanNumerals[i]})',
        label: slabLabels[i],
        value: _detailAmount(slabValues[i]),
      ),
    );
  }

  slabEntries.add(
    _TaxSheetEntry(
      code: '',
      label: 'TOTAL TAX',
      value: _detailAmount(_toInt(itaxNew['tt'])),
      highlight: true,
    ),
  );
  slabEntries.add(
    _TaxSheetEntry(
      code: '',
      label: 'SURCHARGE',
      value: _detailAmount(_toInt(itaxNew['sur'])),
    ),
  );

  return _TaxSheetDetail(
    title: 'New Income Tax Sheet',
    icon: Icons.auto_graph_rounded,
    sections: [
      _TaxSheetSection(
        title: 'Core Summary',
        entries: [
          _TaxSheetEntry(
            code: '1',
            label: 'Total Gross Salary',
            value: _detailAmount(_toInt(itaxNew['tg'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '2',
            label: 'Conveyance & Contigency Exempted',
            value: _detailAmount(_toInt(itaxNew['convdrive'])),
          ),
          _TaxSheetEntry(
            code: '3',
            label: 'Uniform Exempted',
            value: _detailAmount(_toInt(itaxNew['uniform'])),
          ),
          _TaxSheetEntry(
            code: '4',
            label: 'Gross Total Income',
            value: _detailAmount(_toInt(itaxNew['gti'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '5',
            label: 'U/S 80CCD (2)',
            value: _detailAmount(_toInt(itaxNew['atccd2'])),
          ),
          _TaxSheetEntry(
            code: '6',
            label: 'Taxable Income',
            value: _detailAmount(_toInt(itaxNew['ti'])),
          ),
          _TaxSheetEntry(
            code: '7',
            label: 'Standard Deduction',
            value: _detailAmount(_toInt(itaxNew['sd'])),
          ),
          _TaxSheetEntry(
            code: '8',
            label: 'Other',
            value: _detailAmount(_toInt(itaxNew['other'])),
          ),
          _TaxSheetEntry(
            code: '9',
            label: 'Total Taxable Income (Round off)',
            value: _detailAmount(_toInt(itaxNew['tti'])),
            highlight: true,
          ),
        ],
      ),
      _TaxSheetSection(
        title: 'Rate of Income Table Leviable',
        entries: slabEntries,
      ),
      _TaxSheetSection(
        title: 'Liability & Settlement',
        entries: [
          _TaxSheetEntry(
            code: '11',
            label: 'Tax Liability',
            value: _detailAmount(_toInt(itaxNew['tl'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '12',
            label: 'Tax rebate (Sec.87A):if applicable',
            value: _detailAmount(_toInt(itaxNew['tre'])),
          ),
          _TaxSheetEntry(
            code: '13',
            label: 'Total Tax Liability',
            value: _detailAmount(_toInt(itaxNew['ttl'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '14',
            label: 'Education Cess 4%',
            value: _detailAmount(_toInt(itaxNew['ec'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '15',
            label: 'Total Tax Payble Rs.',
            value: _detailAmount(_toInt(itaxNew['ttp'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '16',
            label: 'Deduct :-Income Tax already Paid',
            value: _detailAmount(_toInt(itaxNew['deduct'])),
          ),
          _TaxSheetEntry(
            code: '17',
            label: 'Income Tax Payble',
            value: _detailAmount(_toInt(itaxNew['nitp'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '18',
            label: 'Relief u/s 89(i)',
            value: _detailAmount(_toInt(itaxNew['relief'])),
          ),
          _TaxSheetEntry(
            code: '19',
            label: 'Net Income Tax Payble',
            value: _detailAmount(_toInt(itaxNew['nitpi'])),
            highlight: true,
          ),
          _TaxSheetEntry(
            code: '20',
            label: 'Excess Paid',
            value: _detailAmount(_toInt(itaxNew['ep'])),
          ),
          _TaxSheetEntry(
            code: '',
            label: 'Other deduction value used from deduction sheet',
            value: _detailAmount(_toInt(dedData['other'])),
          ),
        ],
      ),
    ],
  );
}

_TaxSheetDetail _buildOldTaxSheetDetail(
    Map<String, dynamic> mainData,
    Map<String, dynamic> itfData,
    Map<String, dynamic> dedData,
    ) {
  final varTg = _toInt(itfData['tgross']);
  final varConvContUniform = _toInt(itfData['tconv']) +
      _toInt(itfData['tdrive']) +
      _toInt(itfData['tuniform']);
  final varBasic = ((_toInt(itfData['tbp']) +
      _toInt(itfData['tda']) +
      _toInt(itfData['tnpa'])) *
      0.5)
      .round();
  final varGti = varTg - varConvContUniform;

  final hraClaim = _toInt(dedData['hrr']);
  var rentPaid = 0;
  if ((hraClaim - (varBasic * 0.2).round()) >= 0) {
    rentPaid = hraClaim - (varBasic * 0.2).round();
  }
  final hraAmount = _toInt(itfData['thra']);
  final varArp =
  [varBasic, rentPaid, hraAmount].reduce((a, b) => a < b ? a : b);

  final varTotali = varGti - varArp;
  final varHli = _toInt(dedData['hli']);
  final varAtee = _toInt(dedData['80ee']);
  final varIncome = varTotali - (varHli + varAtee);

  final varAtc = _toInt(dedData['totalsav']) - _toInt(dedData['80ccd1']);
  final varNps = _toInt(dedData['80ccd1']);
  final varAgg = _toInt(dedData['maxsav']);
  final varAtd = _toInt(dedData['80d']);
  final varAtdp = _toInt(dedData['80dp']);
  final varAtdps = _toInt(dedData['80dps']);
  final varAccd1b = _toInt(dedData['80ccdnps']);
  final varAte = _toInt(dedData['80e']);
  final varAtg = _toInt(dedData['80g']);
  final varCea = _toInt(dedData['cea']);
  final varAtccd2 = _toInt(dedData['80ccd2']);
  final varAtu = _toInt(dedData['80u']);
  final varTr = varAtd +
      varAtdp +
      varAtdps +
      varAccd1b +
      varAte +
      varAtg +
      varCea +
      varAtccd2 +
      varAtu;
  final varTd = varAgg + varTr;
  final varTi = (varIncome - varTd).abs();
  final varSd = 50000;
  final varTti = varTi - varSd;

  var varT1 = 0;
  var varT2 = 0;
  var varT3 = 0;
  var varT4 = 0;
  var varTt = 0;
  var varSur = 0;

  bool seniorCitizen = false;
  try {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final referenceDate = dateFormat.parse('01-04-2024');
    final givenDate = dateFormat.parse('${mainData['dob'] ?? ''}');
    final dateDiff =
    DateTime(givenDate.year + 60, givenDate.month, givenDate.day);
    seniorCitizen = referenceDate.isAfter(dateDiff) ||
        referenceDate.isAtSameMomentAs(dateDiff);
  } catch (_) {
    seniorCitizen = false;
  }

  if (seniorCitizen) {
    if (varTti > 500000) {
      varT2 = 10000;
    } else if (varTti > 300000 && varTti <= 500000) {
      varT2 = ((varTti - 300000) * 0.05).round();
    }
  } else {
    if (varTti > 500000) {
      varT2 = 12500;
    } else if (varTti > 250000 && varTti <= 500000) {
      varT2 = ((varTti - 250000) * 0.05).round();
    }
  }

  if (varTti > 1000000) {
    varT3 = 100000;
    varT4 = ((varTti - 1000000) * 0.3).round();
  } else if (varTti > 500000 && varTti <= 1000000) {
    varT3 = ((varTti - 500000) * 0.2).round();
  }

  varTt = varT1 + varT2 + varT3 + varT4;

  var varTre = 0;
  if (varTti <= 500000) {
    varTre = [12500, varT2 + varT3].reduce((a, b) => a < b ? a : b);
  }

  var varTtl = 0;
  if ((varTt - varTre) >= 0) {
    varTtl = varTt - varTre;
  }

  var varEc = 0;
  var varTtp = 0;
  if (varTti > 5000000) {
    varSur = (varTtl * 0.1).round();
    varEc = ((varTtl + varSur) * 0.04).round();
    varTtp = varTtl + varEc + varSur;
    final excess = varTtp - 1312500;
    if ((varTti - 5000000) < excess) {
      varSur = (varTti - 5000000 - (varTtl - 1312500));
      if (varSur > (varTtl * 0.1)) {
        varSur = (varTtl * 0.1).round();
      }
    }
  }

  final varTl = varSur + varTt;
  varTtl = varTl - varTre;
  varEc = (varTtl * 0.04).round();
  varTtp = varTtl + varEc;
  if (sharedData.userPlace.split(r'/')[1] == 'mcd-camo' &&
      sharedData.ccurrentYear == '2024-25') {
    varTtp = ((varTtp + 9) ~/ 10) * 10;
  }

  final varDeduct = _toInt(itfData['tincometax']);
  var varNitp = varTtp - varDeduct;
  if (varNitp < 0) {
    varNitp = 0;
  }
  final varRelief = _toInt(dedData['relief']);
  var varNitpi = varTtp - varDeduct - varRelief;
  var varEp = 0;
  if (varNitpi < 0) {
    varEp = varNitpi.abs();
    varNitpi = 0;
  }

  final slabLabels = seniorCitizen
      ? const [
    'Upto Rs. 3,00,000/-                                NIL',
    'Rs. 3,00,001/- To 5,00,000                     5%',
    'Rs. 5,00,001/- To Rs. 10,00,000            20%',
    'EXCEEDING Rs. 15,00,001                       30%',
  ]
      : const [
    'Upto Rs. 2,50,000/-                                NIL',
    'Rs. 2,50,001/- To 5,00,000                     5%',
    'Rs. 5,00,001/- To Rs. 10,00,000            20%',
    'EXCEEDING Rs. 15,00,001                       30%',
  ];

  final slabValues = [varT1, varT2, varT3, varT4];

  return _TaxSheetDetail(
    title: 'Old Income Tax Sheet',
    icon: Icons.history_edu_rounded,
    sections: [
      _TaxSheetSection(
        title: 'Core Summary',
        entries: [
          _TaxSheetEntry(
              code: '1',
              label: 'Total Gross Salary',
              value: _detailAmount(varTg),
              highlight: true),
          _TaxSheetEntry(
              code: '2',
              label: 'Conveyance , Contigency & Uniform Exempted',
              value: _detailAmount(varConvContUniform)),
          _TaxSheetEntry(
              code: '3',
              label: 'Gross Total Income',
              value: _detailAmount(varGti),
              highlight: true),
          _TaxSheetEntry(
              code: '4', label: 'HRA Rebate', value: _detailAmount(varArp)),
          _TaxSheetEntry(
              code: '5',
              label: 'Total Income',
              value: _detailAmount(varTotali),
              highlight: true),
          _TaxSheetEntry(
              code: '6(i)',
              label: 'Interest on Housing Loan ( MAX 2,00,000 )',
              value: _detailAmount(varHli)),
          _TaxSheetEntry(
              code: '6(ii)',
              label: '80EE(Max.Rs.1 Lacs)',
              value: _detailAmount(varAtee)),
          _TaxSheetEntry(
              code: '6(iii)',
              label: 'Income After Deduction',
              value: _detailAmount(varIncome),
              highlight: true),
        ],
      ),
      _TaxSheetSection(
        title: 'Chapter VI-A Deductions',
        entries: [
          _TaxSheetEntry(
              code: '6(iv)(a)', label: 'U/S 80C', value: _detailAmount(varAtc)),
          _TaxSheetEntry(
              code: '6(iv)(b)',
              label: 'U/S 80CCD (NPS)',
              value: _detailAmount(varNps)),
          _TaxSheetEntry(
              code: '',
              label:
              'The aggregate amount U/S 80C & 80CCD Not Exceeding Rs.150000',
              value: _detailAmount(varAgg),
              highlight: true),
          _TaxSheetEntry(
              code: '6(iv)(c)',
              label: 'U/S 80D (Mode of payment other than Cash)',
              value: _detailAmount(varAtd)),
          _TaxSheetEntry(
              code: '6(iv)(d)',
              label: 'Mediclaim for parents Rs.50000/- 80DP',
              value: _detailAmount(varAtdp)),
          _TaxSheetEntry(
              code: '6(iv)(e)',
              label: 'U/S 80 DPS(Rs.50000/-)',
              value: _detailAmount(varAtdps)),
          _TaxSheetEntry(
              code: '6(iv)(f)',
              label: 'U/S 80 CCD (1B)',
              value: _detailAmount(varAccd1b)),
          _TaxSheetEntry(
              code: '6(iv)(g)',
              label: 'U/S 80 E(Intt. On Educational Loan)',
              value: _detailAmount(varAte)),
          _TaxSheetEntry(
              code: '6(iv)(h)',
              label: 'U/S 80G (Donation)',
              value: _detailAmount(varAtg)),
          _TaxSheetEntry(
              code: '6(iv)(i)', label: 'CEA', value: _detailAmount(varCea)),
          _TaxSheetEntry(
              code: '6(iv)(j)',
              label: 'U/S 80 CCD (2)',
              value: _detailAmount(varAtccd2)),
          _TaxSheetEntry(
              code: '6(iv)(k)',
              label: 'U/S 80U (Physically Handicapped)',
              value: _detailAmount(varAtu)),
          _TaxSheetEntry(
              code: '',
              label: 'Total Rs.',
              value: _detailAmount(varTr),
              highlight: true),
          _TaxSheetEntry(
              code: '7', label: 'Total Deduction', value: _detailAmount(varTd)),
          _TaxSheetEntry(
              code: '8',
              label: 'Taxable Income',
              value: _detailAmount(varTi),
              highlight: true),
          _TaxSheetEntry(
              code: '9',
              label: 'Standard Deduction',
              value: _detailAmount(varSd)),
          _TaxSheetEntry(
              code: '10',
              label: 'Total Taxable Income',
              value: _detailAmount(varTti),
              highlight: true),
        ],
      ),
      _TaxSheetSection(
        title: 'Rate of Income Table Leviable',
        entries: [
          for (int i = 0; i < slabLabels.length; i++)
            _TaxSheetEntry(
              code: '11(${_romanNumerals[i]})',
              label: slabLabels[i],
              value: _detailAmount(slabValues[i]),
            ),
          _TaxSheetEntry(
              code: '',
              label: 'Total Tax',
              value: _detailAmount(varTt),
              highlight: true),
          _TaxSheetEntry(
              code: '', label: 'Surcharge', value: _detailAmount(varSur)),
        ],
      ),
      _TaxSheetSection(
        title: 'Liability & Settlement',
        entries: [
          _TaxSheetEntry(
              code: '12',
              label: 'Tax Liability',
              value: _detailAmount(varTl),
              highlight: true),
          _TaxSheetEntry(
              code: '12(i)',
              label: 'Tax rebate (Sec.87A):if applicable',
              value: _detailAmount(varTre)),
          _TaxSheetEntry(
              code: '12(ii)',
              label: 'Total Tax Liability',
              value: _detailAmount(varTtl),
              highlight: true),
          _TaxSheetEntry(
              code: '12(iii)',
              label: 'Education Cess  4%',
              value: _detailAmount(varEc),
              highlight: true),
          _TaxSheetEntry(
              code: '12(iv)',
              label: 'Total Tax Payble Rs.',
              value: _detailAmount(varTtp),
              highlight: true),
          _TaxSheetEntry(
              code: '12(v)',
              label: 'Deduct :-Income Tax already Paid',
              value: _detailAmount(varDeduct)),
          _TaxSheetEntry(
              code: '12(vi)',
              label: 'Income Tax Payble',
              value: _detailAmount(varNitp),
              highlight: true),
          _TaxSheetEntry(
              code: '13',
              label: 'Relief u/s 89(i)',
              value: _detailAmount(varRelief)),
          _TaxSheetEntry(
              code: '14',
              label: 'Net Income Tax Payble',
              value: _detailAmount(varNitpi),
              highlight: true),
          _TaxSheetEntry(
              code: '15', label: 'Excess Paid', value: _detailAmount(varEp)),
        ],
      ),
    ],
  );
}

List<String> _newTaxSlabLabels() {
  if (sharedData.ccurrentYear == '2024-25') {
    return const [
      'Upto Rs. 3,00,000/-                                NIL',
      'Rs. 3,00,001/- To 7,00,000                     5%',
      'Rs. 7,00,001/- To Rs. 10,00,000            10%',
      'Rs. 10,00,001/- To Rs. 12,00,000          15%',
      'Rs. 12,00,001/- To Rs. 15,00,000          20%',
      'ABOVE Rs. 15,00,001                               30%',
    ];
  }

  return const [
    'Upto Rs. 4,00,000/-                                NIL',
    'Rs. 4,00,001/- To 8,00,000                     5%',
    'Rs. 8,00,001/- To Rs. 12,00,000            10%',
    'Rs. 12,00,001/- To Rs. 16,00,000          15%',
    'Rs. 16,00,001/- To Rs. 20,00,000          20%',
    'Rs. 20,00,001/- To Rs. 24,00,000          25%',
    'ABOVE Rs. 24,00,001                               30%',
  ];
}

const List<String> _romanNumerals = [
  'i',
  'ii',
  'iii',
  'iv',
  'v',
  'vi',
  'vii',
  'viii',
  'ix',
];

class _TaxSheetDetail {
  final String title;
  final IconData icon;
  final List<_TaxSheetSection> sections;

  const _TaxSheetDetail({
    required this.title,
    required this.icon,
    required this.sections,
  });
}

class _TaxSheetSection {
  final String title;
  final List<_TaxSheetEntry> entries;

  const _TaxSheetSection({
    required this.title,
    required this.entries,
  });
}

class _TaxSheetEntry {
  final String code;
  final String label;
  final String value;
  final bool highlight;

  const _TaxSheetEntry({
    required this.code,
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class _EcrPreviewData {
  final Map<String, dynamic> mainData;
  final Map<String, dynamic> arrearData;
  final Map<String, dynamic> dedData;
  final Map<String, dynamic> itfData;
  final Map<String, dynamic> itaxNew;
  final Map<String, dynamic> itaxOld;
  final List<_EcrRow> rows;
  final int grossTotal;
  final int totalDeduction;
  final int netSalary;
  final int februaryEcrTax;
  final _TaxSheetDetail newSheetDetail;
  final _TaxSheetDetail oldSheetDetail;

  const _EcrPreviewData({
    required this.mainData,
    required this.arrearData,
    required this.dedData,
    required this.itfData,
    required this.itaxNew,
    required this.itaxOld,
    required this.rows,
    required this.grossTotal,
    required this.totalDeduction,
    required this.netSalary,
    required this.februaryEcrTax,
    required this.newSheetDetail,
    required this.oldSheetDetail,
  });
}

class _EcrRow {
  final String label;
  final Map<String, int> values;

  const _EcrRow({
    required this.label,
    required this.values,
  });
}

class _PreviewColumn {
  final String key;
  final String label;

  const _PreviewColumn(this.key, this.label);
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}

const List<String> _orderedMonthKeys = [
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sept',
  'oct',
  'nov',
  'dec',
  'jan',
  'feb',
];

const List<_PreviewColumn> _earningColumns = [
  _PreviewColumn('bp', 'BP'),
  _PreviewColumn('da', 'DA'),
  _PreviewColumn('hra', 'HRA'),
  _PreviewColumn('npa', 'NPA'),
  _PreviewColumn('splpay', 'SPL PAY'),
  _PreviewColumn('conv', 'CONVEYANCE'),
  _PreviewColumn('pg', 'PG'),
  _PreviewColumn('annual', 'ANNUAL'),
  _PreviewColumn('uniform', 'UNIFORM'),
  _PreviewColumn('nursing', 'NURSING'),
  _PreviewColumn('ta', 'TA'),
  _PreviewColumn('daonta', 'DA ON TA'),
  _PreviewColumn('medical', 'MEDICAL'),
  _PreviewColumn('dirt', 'DIRT'),
  _PreviewColumn('washing', 'WASHING'),
  _PreviewColumn('tb', 'TB'),
  _PreviewColumn('night', 'NIGHT'),
  _PreviewColumn('drive', 'CONTINGENCY'),
  _PreviewColumn('cycle', 'CYCLE'),
  _PreviewColumn('pca', 'PCA'),
  _PreviewColumn('otherEarning', 'OTHER'),
  _PreviewColumn('daext1', 'EXT 1'),
  _PreviewColumn('daext2', 'EXT 2'),
  _PreviewColumn('daext3', 'EXT 3'),
  _PreviewColumn('daext4', 'EXT 4'),
  _PreviewColumn('gross', 'GROSS'),
];

const List<_PreviewColumn> _deductionColumns = [
  _PreviewColumn('incometax', 'INCOME TAX'),
  _PreviewColumn('gis', 'GIS'),
  _PreviewColumn('gpf', 'GPF'),
  _PreviewColumn('nps', 'NPS'),
  _PreviewColumn('slf', 'SLF'),
  _PreviewColumn('society', 'SOCIETY'),
  _PreviewColumn('recovery', 'RECOVERY'),
  _PreviewColumn('wf', 'WF'),
  _PreviewColumn('epf', 'EPF'),
  _PreviewColumn('esi', 'ESI'),
  _PreviewColumn('med', 'MCD-EHS'),
  _PreviewColumn('water', 'WATER'),
  _PreviewColumn('otherDed', 'OTHER'),
  _PreviewColumn('ddext1', 'EXT 1'),
  _PreviewColumn('ddext2', 'EXT 2'),
  _PreviewColumn('ddext3', 'EXT 3'),
  _PreviewColumn('ddext4', 'EXT 4'),
  _PreviewColumn('totalded', 'TOTAL DED'),
  _PreviewColumn('netsalary', 'NET SALARY'),
];

const Map<String, String> _earningMonthKeys = {
  'bp': 'bp',
  'da': 'da',
  'hra': 'hra',
  'npa': 'npa',
  'splpay': 'splpay',
  'conv': 'conv',
  'pg': 'pg',
  'annual': 'annual',
  'uniform': 'uniform',
  'nursing': 'nursing',
  'ta': 'ta',
  'daonta': 'daonta',
  'medical': 'medical',
  'dirt': 'dirt',
  'washing': 'washing',
  'tb': 'tb',
  'night': 'night',
  'drive': 'drive',
  'cycle': 'cycle',
  'pca': 'pca',
  'daext1': 'daext1',
  'daext2': 'daext2',
  'daext3': 'daext3',
  'daext4': 'daext4',
};

const Map<String, String> _deductionMonthKeys = {
  'incometax': 'incometax',
  'gis': 'gis',
  'gpf': 'gpf',
  'nps': 'nps',
  'slf': 'slf',
  'society': 'society',
  'recovery': 'recovery',
  'wf': 'wf',
  'epf': 'epf',
  'esi': 'esi',
  'med': 'med',
  'water': 'water',
  'otherDed': 'other',
  'ddext1': 'ddext1',
  'ddext2': 'ddext2',
  'ddext3': 'ddext3',
  'ddext4': 'ddext4',
};

const Map<String, List<String?>> _earningArrearKeys = {
  'bp': [null, null, null, null],
  'da': ['mmda', 'jada', 'snda', 'dfda'],
  'hra': ['mmhra', 'jahra', 'snhra', 'dfhra'],
  'npa': ['mmnpa', 'janpa', 'snnpa', 'dfnpa'],
  'splpay': [null, null, null, null],
  'conv': [null, null, null, null],
  'pg': [null, null, null, null],
  'annual': [null, null, null, null],
  'uniform': [null, null, null, null],
  'nursing': [null, null, null, null],
  'ta': [null, null, null, null],
  'daonta': ['mmdaonta', 'jadaonta', 'sndaonta', 'dfdaonta'],
  'medical': [null, null, null, null],
  'dirt': [null, null, null, null],
  'washing': [null, null, null, null],
  'tb': [null, null, null, null],
  'night': [null, null, null, null],
  'drive': [null, null, null, null],
  'cycle': [null, null, null, null],
  'pca': ['mmpca', 'japca', 'snpca', 'dfpca'],
  'daext1': [null, null, null, null],
  'daext2': [null, null, null, null],
  'daext3': [null, null, null, null],
  'daext4': [null, null, null, null],
};

const List<String> _arrearOtherKeys = [
  'mmother',
  'jaother',
  'snother',
  'dfother'
];
const List<String> _arrearTaxKeys = ['mmext1', 'jaext1', 'snext1', 'dfext1'];

const List<String> _earningComponentKeys = [
  'bp',
  'da',
  'hra',
  'npa',
  'splpay',
  'conv',
  'pg',
  'annual',
  'uniform',
  'nursing',
  'ta',
  'daonta',
  'medical',
  'dirt',
  'washing',
  'tb',
  'night',
  'drive',
  'cycle',
  'pca',
  'otherEarning',
  'daext1',
  'daext2',
  'daext3',
  'daext4',
];

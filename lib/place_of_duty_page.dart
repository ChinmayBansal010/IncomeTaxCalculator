import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared.dart';

class PlaceOfDutyPage extends StatefulWidget {
  const PlaceOfDutyPage({super.key});

  @override
  State<PlaceOfDutyPage> createState() => _PlaceOfDutyPageState();
}

class _PlaceOfDutyPageState extends State<PlaceOfDutyPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _addController = TextEditingController();

  bool _isLoading = true;
  String _errorMessage = '';
  List<_PlaceItem> _places = [];
  Map<String, int> _employeePlaceCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final placesRef = _dbRef.child(sharedData.userPlace).child('places');
      final mainRef = _dbRef.child(sharedData.userPlace).child('maindata');

      final placesSnap = await placesRef.once();
      final mainSnap = await mainRef.once();

      final Map<String, String> existingPlacesByKey = {};
      final Set<String> placesSet = {};

      if (placesSnap.snapshot.exists && placesSnap.snapshot.value != null) {
        final rawPlaces = placesSnap.snapshot.value;
        if (rawPlaces is Map) {
          for (final entry in rawPlaces.entries) {
            final k = entry.key;
            final v = entry.value;
            if (v != null && v.toString().trim().isNotEmpty) {
              final placeName = v.toString().trim().toUpperCase();
              existingPlacesByKey[k.toString()] = placeName;
              placesSet.add(placeName);
            }
          }
        }
      }

      final Map<String, int> placeCounts = {};
      if (mainSnap.snapshot.exists && mainSnap.snapshot.value != null) {
        final mainMap = mainSnap.snapshot.value as Map;
        for (final record in mainMap.values) {
          if (record is Map && record['place'] != null) {
            final pName = record['place'].toString().trim().toUpperCase();
            if (pName.isNotEmpty) {
              placeCounts[pName] = (placeCounts[pName] ?? 0) + 1;
              // If this place exists in maindata but not yet in /places, seed it to /places
              if (!placesSet.contains(pName)) {
                final newKey = placesRef.push().key;
                if (newKey != null) {
                  placesRef.child(newKey).set(pName);
                  existingPlacesByKey[newKey] = pName;
                  placesSet.add(pName);
                }
              }
            }
          }
        }
      }

      final List<_PlaceItem> list = [];
      for (final entry in existingPlacesByKey.entries) {
        list.add(_PlaceItem(key: entry.key, name: entry.value));
      }

      list.sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _places = list;
          _employeePlaceCounts = placeCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading Place of Duty entries: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addPlace() async {
    final name = _addController.text.trim().toUpperCase();
    if (name.isEmpty) {
      _showSnackBar('Please enter a Place of Duty name.');
      return;
    }

    if (_places.any((p) => p.name == name)) {
      _showSnackBar('Place of Duty "$name" already exists.');
      return;
    }

    try {
      final placesRef = _dbRef.child(sharedData.userPlace).child('places');
      final newRef = placesRef.push();
      await newRef.set(name);
      _addController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _showSnackBar('Place of Duty "$name" added successfully.');
      _loadData();
    } catch (e) {
      _showSnackBar('Failed to add entry: $e');
    }
  }

  Future<void> _editPlace(_PlaceItem item) async {
    final editController = TextEditingController(text: item.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Place of Duty',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: TextField(
          controller: editController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'PLACE OF DUTY',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = editController.text.trim().toUpperCase();
              if (val.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty.')),
                );
                return;
              }
              if (_places.any((p) => p.key != item.key && p.name == val)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('"$val" already exists.')),
                );
                return;
              }
              Navigator.pop(ctx, val);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (newName != null && newName != item.name) {
      try {
        final oldName = item.name;
        await _dbRef
            .child(sharedData.userPlace)
            .child('places')
            .child(item.key)
            .set(newName);

        int updatedEmployeesCount = 0;
        final mainSnap = await _dbRef.child(sharedData.userPlace).child('maindata').once();
        if (mainSnap.snapshot.exists && mainSnap.snapshot.value != null) {
          final mainMap = mainSnap.snapshot.value as Map;
          for (final entry in mainMap.entries) {
            final empBioId = entry.key.toString();
            final record = entry.value;
            if (record is Map && record['place'] != null) {
              final pName = record['place'].toString().trim().toUpperCase();
              if (pName == oldName) {
                await _dbRef
                    .child(sharedData.userPlace)
                    .child('maindata')
                    .child(empBioId)
                    .child('place')
                    .set(newName);
                updatedEmployeesCount++;
              }
            }
          }
        }

        _showSnackBar(updatedEmployeesCount > 0
            ? 'Updated Place of Duty to "$newName" and updated $updatedEmployeesCount assigned employee(s).'
            : 'Updated Place of Duty to "$newName".');
        _loadData();
      } catch (e) {
        _showSnackBar('Failed to update: $e');
      }
    }
  }

  Future<void> _deletePlace(_PlaceItem item) async {
    try {
      final mainSnap = await _dbRef.child(sharedData.userPlace).child('maindata').once();
      final List<Map<String, String>> affectedEmployees = [];

      if (mainSnap.snapshot.exists && mainSnap.snapshot.value != null) {
        final mainMap = mainSnap.snapshot.value as Map;
        for (final entry in mainMap.entries) {
          final empBioId = entry.key.toString();
          final record = entry.value;
          if (record is Map && record['place'] != null) {
            final pName = record['place'].toString().trim().toUpperCase();
            if (pName == item.name) {
              final empName = (record['name'] ?? 'Unknown').toString();
              affectedEmployees.add({'bioId': empBioId, 'name': empName});
            }
          }
        }
      }

      final otherPlaces = _places.where((p) => p.name != item.name).map((p) => p.name).toList();

      if (!mounted) return;
      if (affectedEmployees.isEmpty) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Place of Duty?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            content: Text('Are you sure you want to delete "${item.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('DELETE'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await _dbRef.child(sharedData.userPlace).child('places').child(item.key).remove();
          _showSnackBar('Place of Duty "${item.name}" deleted.');
          _loadData();
        }
        return;
      }

      if (!mounted) return;
      await _showReassignmentDialog(item, affectedEmployees, otherPlaces);
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _showReassignmentDialog(
    _PlaceItem itemToDelete,
    List<Map<String, String>> affectedEmployees,
    List<String> availableTargetPlaces,
  ) async {
    if (availableTargetPlaces.isEmpty) {
      _showSnackBar('Cannot reassign employees because no other Place of Duty exists. Please add another Place of Duty first.');
      return;
    }

    final Map<String, String> selectedTargetMap = {
      for (var emp in affectedEmployees) emp['bioId']!: availableTargetPlaces.first
    };
    String bulkSelectedTarget = availableTargetPlaces.first;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isMobile = MediaQuery.of(ctx).size.width < 600;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reassign Employees before Deleting',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 16 : 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${affectedEmployees.length} employee(s) currently assigned to "${itemToDelete.name}"',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              content: SizedBox(
                width: isMobile ? double.maxFinite : 550,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BULK REASSIGNMENT (CHANGE FOR ALL)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: bulkSelectedTarget,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    items: availableTargetPlaces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setDialogState(() {
                                          bulkSelectedTarget = v;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      for (var emp in affectedEmployees) {
                                        selectedTargetMap[emp['bioId']!] = bulkSelectedTarget;
                                      }
                                    });
                                  },
                                  child: const Text('CHANGE ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AFFECTED EMPLOYEES',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: affectedEmployees.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, idx) {
                            final emp = affectedEmployees[idx];
                            final bioId = emp['bioId']!;
                            final empName = emp['name']!;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(empName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                        Text('ID: $bioId', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 140,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: selectedTargetMap[bioId],
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      items: availableTargetPlaces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setDialogState(() {
                                            selectedTargetMap[bioId] = v;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      for (var emp in affectedEmployees) {
                        final bioId = emp['bioId']!;
                        final targetPlace = selectedTargetMap[bioId]!;
                        await _dbRef
                            .child(sharedData.userPlace)
                            .child('maindata')
                            .child(bioId)
                            .child('place')
                            .set(targetPlace);
                      }
                      await _dbRef
                          .child(sharedData.userPlace)
                          .child('places')
                          .child(itemToDelete.key)
                          .remove();

                      _showSnackBar('Reassigned ${affectedEmployees.length} employee(s) and deleted "${itemToDelete.name}".');
                      _loadData();
                    } catch (e) {
                      _showSnackBar('Failed to reassign/delete: $e');
                    }
                  },
                  child: const Text('REASSIGN & DELETE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Container(
            height: isMobile ? 180 : 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildAppBar(isMobile),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildAddSection(isMobile),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            Expanded(child: _buildListContent(isMobile)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        isMobile ? 12 : 20,
        isMobile ? 12 : 20,
        isMobile ? 16 : 24,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: isMobile ? 20 : 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Place of Duty",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Manage available duty station entries",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ADD NEW PLACE OF DUTY",
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.G. CENTRAL ZONE',
                    prefixIcon: Icon(Icons.place_rounded, color: const Color(0xFF2563EB), size: isMobile ? 18 : 20),
                    prefixIconConstraints: isMobile
                        ? const BoxConstraints(minWidth: 32, minHeight: 32)
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isMobile ? 10 : 16,
                      horizontal: isMobile ? 10 : 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              ElevatedButton.icon(
                onPressed: _addPlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.add_rounded, size: isMobile ? 18 : 22),
                label: Text(
                  "ADD",
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Color(0xFFDC2626))),
      );
    }
    if (_places.isEmpty) {
      return const Center(
        child: Text(
          "No Place of Duty entries found.",
          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      itemCount: _places.length,
      separatorBuilder: (_, __) => SizedBox(height: isMobile ? 6 : 10),
      itemBuilder: (context, index) {
        final item = _places[index];
        final count = _employeePlaceCounts[item.name] ?? 0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on_rounded, color: const Color(0xFF2563EB), size: isMobile ? 18 : 22),
              ),
              SizedBox(width: isMobile ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        "$count assigned employee(s)",
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_rounded, color: const Color(0xFF2563EB), size: isMobile ? 18 : 22),
                onPressed: () => _editPlace(item),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: const Color(0xFFDC2626), size: isMobile ? 18 : 22),
                onPressed: () => _deletePlace(item),
                tooltip: 'Delete',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceItem {
  final String key;
  final String name;

  _PlaceItem({required this.key, required this.name});
}

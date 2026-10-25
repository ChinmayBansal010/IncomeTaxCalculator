import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shared.dart';
import 'home.dart';
import 'main.dart';

class UserModel {
  final String username;
  final String biometricId;
  final String centerName;
  final String password;

  UserModel({
    required this.username,
    required this.biometricId,
    required this.centerName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'biometricId': biometricId,
      'zone': centerName,
      'password': password,
    };
  }

  UserModel copyWith({
    String? username,
    String? biometricId,
    String? centerName,
    String? password,
  }) {
    return UserModel(
      username: username ?? this.username,
      biometricId: biometricId ?? this.biometricId,
      centerName: centerName ?? this.centerName,
      password: password ?? this.password,
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String _selectedYear = '2024-25';
  List<String> _availableYears = ['2024-25', '2025-26', '2026-27', '2027-28'];

  // Freeze state maps
  Map<String, bool> _globalFrozenYearsMap = {};
  Map<String, bool> _userAllYearsFrozenMap = {};
  Map<String, Map<String, bool>> _userSpecificYearsFrozenMap = {};

  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<DatabaseEvent>? _frozenYearsSub;
  StreamSubscription<DatabaseEvent>? _frozenUsersSub;

  @override
  void initState() {
    super.initState();
    if (sharedData.ccurrentYear.isNotEmpty && _availableYears.contains(sharedData.ccurrentYear)) {
      _selectedYear = sharedData.ccurrentYear;
    } else {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int startYear = now.month >= 3 ? currentYear : currentYear - 1;
      _selectedYear = '$startYear-${(startYear + 1).toString().substring(2)}';
      if (!_availableYears.contains(_selectedYear)) {
        _availableYears.add(_selectedYear);
      }
    }
    _loadDashboardData();
    _listenToFreezeData();
  }

  void _listenToFreezeData() {
    _frozenYearsSub = _dbRef.child('_admin/frozen_years').onValue.listen((event) {
      Map<String, bool> globalFrozen = {};
      if (event.snapshot.exists && event.snapshot.value is Map) {
        Map map = event.snapshot.value as Map;
        map.forEach((key, value) {
          globalFrozen[key.toString()] = value == true;
        });
      }
      if (mounted) {
        setState(() {
          _globalFrozenYearsMap = globalFrozen;
        });
      }
    });

    _frozenUsersSub = _dbRef.child('_admin/frozen_users').onValue.listen((event) {
      Map<String, bool> userAllYears = {};
      Map<String, Map<String, bool>> userSpecificYears = {};

      if (event.snapshot.exists && event.snapshot.value is Map) {
        Map userMap = event.snapshot.value as Map;
        userMap.forEach((userKey, userVal) {
          String uname = userKey.toString();
          if (userVal is Map) {
            if (userVal['all_years'] == true) {
              userAllYears[uname] = true;
            }
            if (userVal['years'] is Map) {
              Map yrMap = userVal['years'] as Map;
              Map<String, bool> specYr = {};
              yrMap.forEach((yk, yv) {
                specYr[yk.toString()] = yv == true;
              });
              userSpecificYears[uname] = specYr;
            }
          }
        });
      }
      if (mounted) {
        setState(() {
          _userAllYearsFrozenMap = userAllYears;
          _userSpecificYearsFrozenMap = userSpecificYears;
        });
      }
    });
  }

  @override
  void dispose() {
    _frozenYearsSub?.cancel();
    _frozenUsersSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fetchAvailableYears();
      await _fetchFrozenData();
      await _fetchUsers();
    } catch (e) {
      debugPrint('Error loading admin dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAvailableYears() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        Map dbMap = snapshot.value as Map;
        Set<String> yearSet = Set.from(_availableYears);
        dbMap.forEach((key, value) {
          if (key.toString().startsWith('20') && key.toString().contains('-')) {
            yearSet.add(key.toString());
          }
        });
        List<String> sortedYears = yearSet.toList()..sort();
        setState(() {
          _availableYears = sortedYears;
          if (!_availableYears.contains(_selectedYear) && _availableYears.isNotEmpty) {
            _selectedYear = _availableYears.last;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching available years: $e');
    }
  }

  Future<void> _fetchFrozenData() async {
    try {
      // 1. Global Year Freezes
      final yearSnap = await _dbRef.child('_admin/frozen_years').get();
      Map<String, bool> globalFrozen = {};
      if (yearSnap.exists && yearSnap.value is Map) {
        Map map = yearSnap.value as Map;
        map.forEach((key, value) {
          globalFrozen[key.toString()] = value == true;
        });
      }

      // 2. User Freezes
      final userSnap = await _dbRef.child('_admin/frozen_users').get();
      Map<String, bool> userAllYears = {};
      Map<String, Map<String, bool>> userSpecificYears = {};

      if (userSnap.exists && userSnap.value is Map) {
        Map userMap = userSnap.value as Map;
        userMap.forEach((userKey, userVal) {
          String uname = userKey.toString();
          if (userVal is Map) {
            if (userVal['all_years'] == true) {
              userAllYears[uname] = true;
            }
            if (userVal['years'] is Map) {
              Map yrMap = userVal['years'] as Map;
              Map<String, bool> specYr = {};
              yrMap.forEach((yk, yv) {
                specYr[yk.toString()] = yv == true;
              });
              userSpecificYears[uname] = specYr;
            }
          }
        });
      }

      setState(() {
        _globalFrozenYearsMap = globalFrozen;
        _userAllYearsFrozenMap = userAllYears;
        _userSpecificYearsFrozenMap = userSpecificYears;
      });
    } catch (e) {
      debugPrint('Error fetching freeze data: $e');
    }
  }

  Future<void> _fetchUsers() async {
    List<UserModel> loadedUsers = [];
    try {
      final yearSnapshot = await _dbRef.child(_selectedYear).get();
      if (yearSnapshot.exists && yearSnapshot.value is Map) {
        Map yearMap = yearSnapshot.value as Map;

        yearMap.forEach((userKey, userVal) {
          String keyStr = userKey.toString();
          if (keyStr == '_admin' || keyStr == '_metadata' || keyStr == 'frozen_years' || keyStr == 'frozen_users') return;

          if (userVal is Map) {
            Map userNodeMap = userVal;
            Map? profileMap;

            if (userNodeMap.containsKey(keyStr) && userNodeMap[keyStr] is Map) {
              profileMap = userNodeMap[keyStr] as Map;
            } else {
              userNodeMap.forEach((k, v) {
                if (v is Map && (v.containsKey('password') || v.containsKey('zone'))) {
                  profileMap = v;
                }
              });
            }

            String username = profileMap?['username']?.toString() ?? keyStr;
            String biometricId = profileMap?['biometricId']?.toString() ?? profileMap?['biometricid']?.toString() ?? '';
            String centerName = profileMap?['zone']?.toString() ?? profileMap?['centerName']?.toString() ?? profileMap?['facilityId']?.toString() ?? '';
            String password = profileMap?['password']?.toString() ?? '';

            if (biometricId.isEmpty && userNodeMap.containsKey('maindata') && userNodeMap['maindata'] is Map) {
              Map mainData = userNodeMap['maindata'] as Map;
              if (mainData.isNotEmpty) {
                biometricId = mainData.keys.first.toString();
              }
            }

            loadedUsers.add(UserModel(
              username: username,
              biometricId: biometricId,
              centerName: centerName,
              password: password,
            ));
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching users for year $_selectedYear: $e');
    }

    loadedUsers.sort((a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()));
    if (mounted) {
      setState(() {
        _users = loadedUsers;
      });
    }
  }

  Future<void> _toggleGlobalYearFreeze(String year, bool freeze) async {
    try {
      await _dbRef.child('_admin/frozen_years/$year').set(freeze);
      setState(() {
        _globalFrozenYearsMap[year] = freeze;
      });
      _showSnackBar(
        freeze
            ? 'Financial Year $year has been FROZEN globally.'
            : 'Financial Year $year has been UNFROZEN globally.',
        isError: freeze,
      );
    } catch (e) {
      _showSnackBar('Error updating year freeze: $e', isError: true);
    }
  }

  Future<void> _toggleUserAllYearsFreeze(String username, bool freeze) async {
    try {
      await _dbRef.child('_admin/frozen_users/$username/all_years').set(freeze);
      setState(() {
        _userAllYearsFrozenMap[username] = freeze;
      });
      _showSnackBar(
        freeze
            ? 'User "$username" is now FROZEN across ALL financial years.'
            : 'User "$username" ALL-years freeze removed.',
        isError: freeze,
      );
    } catch (e) {
      _showSnackBar('Error updating user freeze: $e', isError: true);
    }
  }

  Future<void> _toggleUserSpecificYearFreeze(String username, String year, bool freeze) async {
    try {
      await _dbRef.child('_admin/frozen_users/$username/years/$year').set(freeze);
      setState(() {
        if (!_userSpecificYearsFrozenMap.containsKey(username)) {
          _userSpecificYearsFrozenMap[username] = {};
        }
        _userSpecificYearsFrozenMap[username]![year] = freeze;
      });
      _showSnackBar(
        freeze
            ? 'User "$username" FROZEN for FY $year.'
            : 'User "$username" UNFROZEN for FY $year.',
        isError: freeze,
      );
    } catch (e) {
      _showSnackBar('Error updating user FY freeze: $e', isError: true);
    }
  }

  Future<void> _saveUser({
    UserModel? existingUser,
    required String username,
    required String biometricId,
    required String centerName,
    required String password,
  }) async {
    username = username.trim();
    biometricId = biometricId.trim();
    centerName = centerName.trim();
    password = password.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username and password cannot be blank.', isError: true);
      return;
    }

    try {
      if (existingUser == null) {
        final userCheckSnap = await _dbRef.child('$_selectedYear/$username/$username').get();
        if (userCheckSnap.exists) {
          _showSnackBar('Username "$username" already exists in FY $_selectedYear.', isError: true);
          return;
        }

        Map<String, dynamic> userProfile = {
          'username': username,
          'biometricId': biometricId,
          'zone': centerName,
          'password': password,
        };

        await _dbRef.child('$_selectedYear/$username/$username').set(userProfile);
        _showSnackBar('User "$username" created successfully.');
      } else {
        String oldUsername = existingUser.username;
        Map<String, dynamic> updatedProfile = {
          'username': username,
          'biometricId': biometricId,
          'zone': centerName,
          'password': password,
        };

        if (oldUsername == username) {
          await _dbRef.child('$_selectedYear/$username/$username').set(updatedProfile);
          _showSnackBar('User "$username" updated successfully.');
        } else {
          final oldUserSnap = await _dbRef.child('$_selectedYear/$oldUsername').get();
          if (oldUserSnap.exists && oldUserSnap.value is Map) {
            Map<String, dynamic> oldData = Map<String, dynamic>.from(oldUserSnap.value as Map);
            oldData.remove(oldUsername);
            oldData[username] = updatedProfile;

            await _dbRef.child('$_selectedYear/$username').set(oldData);
            await _dbRef.child('$_selectedYear/$oldUsername').remove();
          } else {
            await _dbRef.child('$_selectedYear/$username/$username').set(updatedProfile);
            await _dbRef.child('$_selectedYear/$oldUsername').remove();
          }
          _showSnackBar('User renamed from "$oldUsername" to "$username" and updated.');
        }
      }

      await _fetchUsers();
    } catch (e) {
      _showSnackBar('Error saving user: $e', isError: true);
    }
  }

  Future<void> _deleteUser(String username) async {
    try {
      await _dbRef.child('$_selectedYear/$username').remove();
      _showSnackBar('User "$username" and all associated records deleted for FY $_selectedYear.');
      await _fetchUsers();
    } catch (e) {
      _showSnackBar('Error deleting user: $e', isError: true);
    }
  }

  void _accessUserDashboard(UserModel user) async {
    sharedData.userPlace = '$_selectedYear/${user.username}';
    sharedData.ccurrentYear = _selectedYear;
    sharedData.zone = user.centerName;
    sharedData.isAdmin = true;
    sharedData.viewingAsUsername = user.username;
    sharedData.isYearFrozen = false; // Admin bypasses user freeze restrictions

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    ).then((_) {
      _fetchUsers();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUserFormDialog({UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(
        user: user,
        onSave: _saveUser,
      ),
    );
  }

  void _showTransferFyDataDialog({UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) => _TransferFyDataModal(
        allUsers: _users,
        selectedUser: user,
        availableYears: _availableYears,
        currentSelectedYear: _selectedYear,
        dbRef: _dbRef,
        showSnackBar: _showSnackBar,
        onTransferSuccess: () {
          _loadDashboardData();
        },
      ),
    );
  }

  void _showUserFreezeDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _UserFreezeModal(
        username: user.username,
        availableYears: _availableYears,
        isAllYearsFrozen: _userAllYearsFrozenMap[user.username] ?? false,
        specificYearsMap: _userSpecificYearsFrozenMap[user.username] ?? {},
        globalFrozenYearsMap: _globalFrozenYearsMap,
        onToggleAllYears: (freeze) => _toggleUserAllYearsFreeze(user.username, freeze),
        onToggleSpecificYear: (year, freeze) => _toggleUserSpecificYearFreeze(user.username, year, freeze),
      ),
    );
  }

  void _showChangeAdminPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => _ChangeAdminPasswordModal(
        onPasswordChanged: (newPassword) async {
          try {
            await _dbRef.child('_admin/credentials/password').set(newPassword);
            _showSnackBar('Admin password changed successfully.');
          } catch (e) {
            _showSnackBar('Error changing admin password: $e', isError: true);
          }
        },
        fetchCurrentAdminPassword: () async {
          try {
            final snap = await _dbRef.child('_admin/credentials/password').get();
            if (snap.exists && snap.value != null && snap.value.toString().isNotEmpty) {
              return snap.value.toString();
            }
          } catch (e) {
            debugPrint('Error reading admin password: $e');
          }
          return 'admin';
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
              SizedBox(width: 12),
              Text('Delete User'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete user "${user.username}" and all associated data for Financial Year $_selectedYear?\n\nThis action cannot be undone.',
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(user.username);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showManageYearsDialog() {
    showDialog(
      context: context,
      builder: (context) => _ManageYearsDialog(
        availableYears: _availableYears,
        frozenYearsMap: _globalFrozenYearsMap,
        onToggleFreeze: _toggleGlobalYearFreeze,
        onAddYear: (newYr) {
          if (!_availableYears.contains(newYr)) {
            setState(() {
              _availableYears.add(newYr);
              _availableYears.sort();
            });
          }
        },
      ),
    );
  }

  void _logout() {
    sharedData.isAdmin = false;
    sharedData.adminUsername = null;
    sharedData.viewingAsUsername = null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  bool _isUserFrozenInCurrentYear(String username) {
    if (_globalFrozenYearsMap[_selectedYear] == true) return true;
    if (_userAllYearsFrozenMap[username] == true) return true;
    if (_userSpecificYearsFrozenMap[username]?[_selectedYear] == true) return true;
    return false;
  }

  String _getUserFreezeReason(String username) {
    if (_globalFrozenYearsMap[_selectedYear] == true) return 'Global FY $_selectedYear Frozen';
    if (_userAllYearsFrozenMap[username] == true) return 'User Frozen (All Years)';
    if (_userSpecificYearsFrozenMap[username]?[_selectedYear] == true) return 'User Frozen (FY $_selectedYear)';
    return 'ACTIVE';
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentYearGloballyFrozen = _globalFrozenYearsMap[_selectedYear] ?? false;
    List<UserModel> filteredUsers = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      String q = _searchQuery.toLowerCase();
      return u.username.toLowerCase().contains(q) ||
          u.biometricId.toLowerCase().contains(q) ||
          u.centerName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: OutlinedButton.icon(
              onPressed: _showChangeAdminPasswordDialog,
              icon: const Icon(Icons.key_rounded, color: Color(0xFF2563EB), size: 18),
              label: const Text(
                'Change Password',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                backgroundColor: const Color(0xFFEFF6FF),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF2563EB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopYearSelector(isCurrentYearGloballyFrozen),
              const SizedBox(height: 20),
              _buildStatsSection(isCurrentYearGloballyFrozen),
              const SizedBox(height: 24),
              _buildSearchAndActionsSection(),
              const SizedBox(height: 20),
              _buildUserListSection(filteredUsers),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserFormDialog(),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTopYearSelector(bool isGlobalFrozen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Year Selection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showManageYearsDialog,
                icon: const Icon(Icons.ac_unit_rounded, size: 16),
                label: const Text('Global Freeze Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Color(0xFF2563EB)),
                items: _availableYears.map((yr) {
                  bool yrFrozen = _globalFrozenYearsMap[yr] ?? false;
                  return DropdownMenuItem<String>(
                    value: yr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Financial Year $yr', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        if (yrFrozen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: const Text('GLOBAL FROZEN', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newYear) {
                  if (newYear != null && newYear != _selectedYear) {
                    setState(() {
                      _selectedYear = newYear;
                      sharedData.ccurrentYear = newYear;
                    });
                    _fetchUsers();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isGlobalFrozen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 600;

        List<Widget> cards = [
          _buildStatCard(
            title: 'Total Users (FY $_selectedYear)',
            value: '${_users.length}',
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF2563EB),
          ),
          _buildFreezeCard(isGlobalFrozen),
        ];

        if (isMobile) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreezeCard(bool isGlobalFrozen) {
    Color cardColor = isGlobalFrozen ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isGlobalFrozen ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0)),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isGlobalFrozen ? Icons.lock_rounded : Icons.lock_open_rounded, color: cardColor, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FY $_selectedYear Global Status', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    isGlobalFrozen ? 'GLOBAL FROZEN' : 'ACTIVE (Editable)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cardColor),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isGlobalFrozen,
            activeThumbColor: const Color(0xFFDC2626),
            onChanged: (val) => _toggleGlobalYearFreeze(_selectedYear, val),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActionsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        Widget searchField = TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search users by username, biometric ID, or center...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
        );

        Widget transferButton = ElevatedButton.icon(
          onPressed: () => _showTransferFyDataDialog(),
          icon: const Icon(Icons.swap_horiz_rounded, size: 20),
          label: const Text(
            'Transfer FY Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );

        if (isMobile) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: transferButton),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 14),
              transferButton,
            ],
          );
        }
      },
    );
  }

  Widget _buildUserListSection(List<UserModel> filteredUsers) {
    if (filteredUsers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_off_rounded, size: 56, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No users found in FY $_selectedYear' : 'No users match "$_searchQuery"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Add User" to create a new user account.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        bool isUserFrozen = _isUserFrozenInCurrentYear(user.username);
        String freezeReason = _getUserFreezeReason(user.username);

        return _UserCard(
          user: user,
          isFrozen: isUserFrozen,
          freezeReason: freezeReason,
          onAccessDashboard: () => _accessUserDashboard(user),
          onEdit: () => _showUserFormDialog(user: user),
          onFreezeSettings: () => _showUserFreezeDialog(user),
          onDelete: () => _showDeleteConfirmDialog(user),
        );
      },
    );
  }
}

class _ChangeAdminPasswordModal extends StatefulWidget {
  final Future<String> Function() fetchCurrentAdminPassword;
  final Function(String newPassword) onPasswordChanged;

  const _ChangeAdminPasswordModal({
    required this.fetchCurrentAdminPassword,
    required this.onPasswordChanged,
  });

  @override
  State<_ChangeAdminPasswordModal> createState() => _ChangeAdminPasswordModalState();
}

class _ChangeAdminPasswordModalState extends State<_ChangeAdminPasswordModal> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    String currentPass = _currentPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorMessage = 'All password fields are required.';
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = 'New password and confirm password do not match.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    String activePassword = await widget.fetchCurrentAdminPassword();
    if (currentPass != activePassword) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Current admin password is incorrect.';
      });
      return;
    }

    widget.onPasswordChanged(newPass);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 480 : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.key_rounded, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Change Admin Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Update the password used to log in as administrator.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF64748B)),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF64748B)),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF64748B)),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Update Password'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final Function({
    UserModel? existingUser,
    required String username,
    required String biometricId,
    required String centerName,
    required String password,
  }) onSave;

  const _UserFormDialog({
    this.user,
    required this.onSave,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _biometricController;
  late final TextEditingController _centerNameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _biometricController = TextEditingController(text: widget.user?.biometricId ?? '');
    _centerNameController = TextEditingController(text: widget.user?.centerName ?? '');
    _passwordController = TextEditingController(text: widget.user?.password ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _biometricController.dispose();
    _centerNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.user != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEditing ? Icons.manage_accounts_rounded : Icons.person_add_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isEditing ? 'Edit User (${widget.user!.username})' : 'Create New User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _biometricController,
              decoration: InputDecoration(
                labelText: 'Biometric ID',
                hintText: 'Enter Biometric ID (e.g. 1001)',
                prefixIcon: const Icon(Icons.fingerprint_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _centerNameController,
              decoration: InputDecoration(
                labelText: 'Center Name / Facility ID',
                hintText: 'Enter center name or zone',
                prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSave(
                      existingUser: widget.user,
                      username: _usernameController.text,
                      biometricId: _biometricController.text,
                      centerName: _centerNameController.text,
                      password: _passwordController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Create User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFreezeModal extends StatefulWidget {
  final String username;
  final List<String> availableYears;
  final bool isAllYearsFrozen;
  final Map<String, bool> specificYearsMap;
  final Map<String, bool> globalFrozenYearsMap;
  final Function(bool freeze) onToggleAllYears;
  final Function(String year, bool freeze) onToggleSpecificYear;

  const _UserFreezeModal({
    required this.username,
    required this.availableYears,
    required this.isAllYearsFrozen,
    required this.specificYearsMap,
    required this.globalFrozenYearsMap,
    required this.onToggleAllYears,
    required this.onToggleSpecificYear,
  });

  @override
  State<_UserFreezeModal> createState() => _UserFreezeModalState();
}

class _UserFreezeModalState extends State<_UserFreezeModal> {
  late bool _allYears;
  late Map<String, bool> _specYears;

  @override
  void initState() {
    super.initState();
    _allYears = widget.isAllYearsFrozen;
    _specYears = Map.from(widget.specificYearsMap);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.ac_unit_rounded, color: Color(0xFFDC2626)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Freeze Settings: ${widget.username}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Freeze this user across ALL financial years or for specific years individually.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),
            Material(
              color: const Color(0xFFFEF2F2),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Freeze across ALL Financial Years',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                ),
                subtitle: const Text('Completely blocks user edits regardless of FY', style: TextStyle(fontSize: 12)),
                value: _allYears,
                activeThumbColor: const Color(0xFFDC2626),
                onChanged: (val) {
                  setState(() {
                    _allYears = val;
                  });
                  widget.onToggleAllYears(val);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Specific Financial Year Restrictions:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.availableYears.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  String yr = widget.availableYears[index];
                  bool isGlobalFrozen = widget.globalFrozenYearsMap[yr] == true;
                  bool isAllYearsFrozen = _allYears;
                  bool isSpecFrozen = _specYears[yr] == true;
                  bool isEffectiveFrozen = isGlobalFrozen || isAllYearsFrozen || isSpecFrozen;

                  String statusSubtitle;
                  Color statusColor;
                  if (isGlobalFrozen) {
                    if (isSpecFrozen) {
                      statusSubtitle = 'GLOBAL FROZEN (Overlaps with User FY $yr Switch)';
                    } else if (isAllYearsFrozen) {
                      statusSubtitle = 'GLOBAL FROZEN (Overlaps with User All-Years)';
                    } else {
                      statusSubtitle = 'GLOBAL FROZEN (Global FY Settings)';
                    }
                    statusColor = const Color(0xFFDC2626);
                  } else if (isAllYearsFrozen) {
                    if (isSpecFrozen) {
                      statusSubtitle = 'USER FROZEN (All-Years + Specific FY $yr)';
                    } else {
                      statusSubtitle = 'USER FROZEN (User All-Years Switch)';
                    }
                    statusColor = const Color(0xFFDC2626);
                  } else if (isSpecFrozen) {
                    statusSubtitle = 'USER FROZEN (User FY $yr Switch)';
                    statusColor = const Color(0xFFDC2626);
                  } else {
                    statusSubtitle = 'ACTIVE (Editable)';
                    statusColor = const Color(0xFF059669);
                  }

                  return SwitchListTile(
                    title: Text('FY $yr', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      statusSubtitle,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    value: isEffectiveFrozen,
                    activeThumbColor: const Color(0xFFDC2626),
                    onChanged: (isGlobalFrozen || isAllYearsFrozen)
                        ? null // Locked if globally frozen or all years frozen
                        : (val) {
                      setState(() {
                        _specYears[yr] = val;
                      });
                      widget.onToggleSpecificYear(yr, val);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageYearsDialog extends StatefulWidget {
  final List<String> availableYears;
  final Map<String, bool> frozenYearsMap;
  final Function(String year, bool freeze) onToggleFreeze;
  final Function(String newYear) onAddYear;

  const _ManageYearsDialog({
    required this.availableYears,
    required this.frozenYearsMap,
    required this.onToggleFreeze,
    required this.onAddYear,
  });

  @override
  State<_ManageYearsDialog> createState() => _ManageYearsDialogState();
}

class _ManageYearsDialogState extends State<_ManageYearsDialog> {
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 550 : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.ac_unit_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 12),
                Text(
                  'Global Data Freeze Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Global year freezes apply to ALL users for that financial year.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.availableYears.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  String yr = widget.availableYears[index];
                  bool isFrozen = widget.frozenYearsMap[yr] ?? false;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      'FY $yr',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    subtitle: Text(
                      isFrozen ? 'GLOBAL FROZEN (Read-only for all users)' : 'ACTIVE (Editable)',
                      style: TextStyle(
                        color: isFrozen ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Switch(
                      value: isFrozen,
                      activeThumbColor: const Color(0xFFDC2626),
                      onChanged: (bool val) {
                        widget.onToggleFreeze(yr, val);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      hintText: 'Add Year e.g. 2028-29',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    String newYr = _yearController.text.trim();
                    if (newYr.isNotEmpty) {
                      widget.onAddYear(newYr);
                      _yearController.clear();
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add FY'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  final UserModel user;
  final bool isFrozen;
  final String freezeReason;
  final VoidCallback onAccessDashboard;
  final VoidCallback onEdit;
  final VoidCallback onFreezeSettings;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.isFrozen,
    required this.freezeReason,
    required this.onAccessDashboard,
    required this.onEdit,
    required this.onFreezeSettings,
    required this.onDelete,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    Color statusColor = widget.isFrozen ? const Color(0xFFDC2626) : const Color(0xFF059669);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.isFrozen ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isFrozen ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.isFrozen ? Icons.lock_rounded : Icons.person_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.user.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            widget.freezeReason,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.user.centerName.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.business_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.user.centerName,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (widget.user.biometricId.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fingerprint_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${widget.user.biometricId}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Password: ${_showPassword ? widget.user.password : '••••••••'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onAccessDashboard,
                icon: const Icon(Icons.dashboard_rounded, size: 16),
                label: const Text('View Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onFreezeSettings,
                icon: const Icon(Icons.ac_unit_rounded, size: 16, color: Color(0xFF0284C7)),
                label: const Text('Freeze Control', style: TextStyle(color: Color(0xFF0284C7))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                label: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransferFyDataModal extends StatefulWidget {
  final List<UserModel> allUsers;
  final UserModel? selectedUser;
  final List<String> availableYears;
  final String currentSelectedYear;
  final DatabaseReference dbRef;
  final Function(String message, {bool isError}) showSnackBar;
  final VoidCallback onTransferSuccess;

  const _TransferFyDataModal({
    required this.allUsers,
    this.selectedUser,
    required this.availableYears,
    required this.currentSelectedYear,
    required this.dbRef,
    required this.showSnackBar,
    required this.onTransferSuccess,
  });

  @override
  State<_TransferFyDataModal> createState() => _TransferFyDataModalState();
}

class _TransferFyDataModalState extends State<_TransferFyDataModal> {
  UserModel? _selectedUser;
  late String _sourceYear;
  late String _destYear;

  bool _isLoadingPreview = false;
  bool _isExecutingTransfer = false;
  bool _allowOverwrite = false;

  String? _validationError;
  bool _destinationHasExistingData = false;

  // Preview Details
  int _mainDataCount = 0;
  bool _febSalaryExists = false;
  int _febSalaryCount = 0;
  double _febBpValue = 0;
  bool _shouldTransferMainData = true;
  DataSnapshot? _sourceSnapshot;

  String _getNextFy(String sourceFy) {
    try {
      List<String> parts = sourceFy.split('-');
      if (parts.length == 2) {
        int startYr = int.parse(parts[0]);
        int nextStartYr = startYr + 1;
        String nextYrStr = (nextStartYr + 1).toString();
        if (nextYrStr.length >= 4) {
          nextYrStr = nextYrStr.substring(nextYrStr.length - 2);
        }
        return '$nextStartYr-$nextYrStr';
      }
    } catch (e) {
      debugPrint('Error parsing FY for next year: $e');
    }
    return sourceFy;
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedUser != null && widget.allUsers.any((u) => u.username == widget.selectedUser!.username)) {
      _selectedUser = widget.allUsers.firstWhere((u) => u.username == widget.selectedUser!.username);
    } else if (widget.allUsers.isNotEmpty) {
      _selectedUser = widget.allUsers.first;
    }

    if (sharedData.ccurrentYear.isNotEmpty) {
      _sourceYear = sharedData.ccurrentYear;
    } else if (widget.currentSelectedYear.isNotEmpty) {
      _sourceYear = widget.currentSelectedYear;
    } else {
      DateTime now = DateTime.now();
      int startYr = now.month >= 3 ? now.year : now.year - 1;
      _sourceYear = '$startYr-${(startYr + 1).toString().substring(2)}';
    }

    _destYear = _getNextFy(_sourceYear);

    _fetchPreviewData();
  }

  Future<void> _fetchPreviewData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingPreview = true;
      _validationError = null;
      _allowOverwrite = false;
      _destinationHasExistingData = false;
      _mainDataCount = 0;
      _febSalaryExists = false;
      _febSalaryCount = 0;
      _febBpValue = 0;
      _shouldTransferMainData = true;
      _sourceSnapshot = null;
    });

    if (_selectedUser == null) {
      setState(() {
        _validationError = 'Please select a user to transfer data.';
        _isLoadingPreview = false;
      });
      return;
    }

    if (_sourceYear == _destYear) {
      setState(() {
        _validationError = 'Source FY and Destination FY cannot be the same.';
        _isLoadingPreview = false;
      });
      return;
    }

    try {
      final String username = _selectedUser!.username;
      final sourceSnap = await widget.dbRef.child('$_sourceYear/$username').get().timeout(const Duration(seconds: 10));
      final destSnap = await widget.dbRef.child('$_destYear/$username').get().timeout(const Duration(seconds: 10));

      if (!sourceSnap.exists || sourceSnap.value == null || sourceSnap.value is! Map) {
        setState(() {
          _validationError = 'No data found for user "$username" in Source FY $_sourceYear.';
          _isLoadingPreview = false;
        });
        return;
      }

      _sourceSnapshot = sourceSnap;
      Map srcMap = sourceSnap.value as Map;

      // 1. Check maindata count
      if (srcMap.containsKey('maindata') && srcMap['maindata'] is Map) {
        _mainDataCount = (srcMap['maindata'] as Map).length;
      }

      // 2. Check monthdata/feb & validate BP (Requirement 3 & 6)
      double maxFebBp = 0;
      if (srcMap.containsKey('monthdata') && srcMap['monthdata'] is Map) {
        Map mData = srcMap['monthdata'] as Map;
        if (mData.containsKey('feb') && mData['feb'] is Map) {
          _febSalaryExists = true;
          Map febMap = mData['feb'] as Map;
          _febSalaryCount = febMap.length;

          febMap.forEach((bioId, bioVal) {
            if (bioVal is Map && bioVal.containsKey('bp')) {
              double bpVal = double.tryParse(bioVal['bp']?.toString() ?? '0') ?? 0;
              if (bpVal > maxFebBp) {
                maxFebBp = bpVal;
              }
            }
          });
        }
      }

      _febBpValue = maxFebBp;
      // If February BP == 0, Main Data transfer must be SKIPPED
      _shouldTransferMainData = (_febBpValue > 0);

      // 3. Check destination FY existing data
      if (destSnap.exists && destSnap.value != null && destSnap.value is Map && (destSnap.value as Map).isNotEmpty) {
        _destinationHasExistingData = true;
      }

      setState(() {
        _isLoadingPreview = false;
      });
    } catch (e) {
      debugPrint('Error fetching transfer preview data: $e');
      if (mounted) {
        setState(() {
          _validationError = 'Failed to load preview data: $e';
          _isLoadingPreview = false;
        });
      }
    }
  }

  Map<String, dynamic> _createZeroValuedMonthEntry({
    required String bioId,
    required String name,
    required String designation,
  }) {
    return {
      'biometricid': bioId,
      'name': name,
      'designation': designation,
      'bp': '0',
      'da': '0',
      'hra': '0',
      'npa': '0',
      'splpay': '0',
      'conv': '0',
      'pg': '0',
      'annual': '0',
      'uniform': '0',
      'nursing': '0',
      'ta': '0',
      'daonta': '0',
      'medical': '0',
      'dirt': '0',
      'washing': '0',
      'tb': '0',
      'night': '0',
      'drive': '0',
      'cycle': '0',
      'pca': '0',
      'daext1': '0',
      'daext2': '0',
      'daext3': '0',
      'daext4': '0',
      'gross': '0',
      'incometax': '0',
      'gis': '0',
      'gpf': '0',
      'nps': '0',
      'epf': '0',
      'esi': '0',
      'slf': '0',
      'society': '0',
      'recovery': '0',
      'wf': '0',
      'other': '0',
      'ddext1': '0',
      'ddext2': '0',
      'ddext3': '0',
      'ddext4': '0',
      'totalded': '0',
      'netsalary': '0',
      'dap': '0',
      'hrap': '0',
      'tap': '0',
      'npap': '0',
      'gpfchk': false,
      'npschk': false,
      'epfchk': false,
      'esichk': false,
    };
  }

  Map<String, dynamic> _cleanAndProcessMonthEntry(Map<String, dynamic> rawEntry) {
    Map<String, dynamic> entry = Map<String, dynamic>.from(rawEntry);

    // Rule 4: Reset DA and Deductions to '0'
    entry['da'] = '0';
    entry['daonta'] = '0';
    entry['daext1'] = '0';
    entry['daext2'] = '0';
    entry['daext3'] = '0';
    entry['daext4'] = '0';

    entry['incometax'] = '0';
    entry['gis'] = '0';
    entry['gpf'] = '0';
    entry['nps'] = '0';
    entry['epf'] = '0';
    entry['esi'] = '0';
    entry['slf'] = '0';
    entry['society'] = '0';
    entry['recovery'] = '0';
    entry['wf'] = '0';
    entry['med'] = '0';
    entry['water'] = '0';
    entry['other'] = '0';
    entry['ddext1'] = '0';
    entry['ddext2'] = '0';
    entry['ddext3'] = '0';
    entry['ddext4'] = '0';
    entry['totalded'] = '0';

    // Recalculate Gross Salary (excluding DA)
    List<String> grossFields = [
      'bp', 'hra', 'npa', 'splpay', 'conv', 'pg', 'annual',
      'uniform', 'nursing', 'ta', 'medical', 'dirt',
      'washing', 'tb', 'night', 'drive', 'cycle', 'pca', 'ot'
    ];

    double grossTotal = 0;
    for (String f in grossFields) {
      if (entry.containsKey(f)) {
        double val = double.tryParse(entry[f]?.toString() ?? '0') ?? 0;
        grossTotal += val;
      }
    }

    int grossInt = grossTotal.round();
    entry['gross'] = grossInt.toString();
    entry['totalded'] = '0';
    entry['netsalary'] = grossInt.toString();

    return entry;
  }

  Map<String, dynamic> _resetArrearOrDeductionEntry(Map<String, dynamic> rawEntry) {
    Map<String, dynamic> res = {};
    rawEntry.forEach((k, v) {
      String keyStr = k.toString().toLowerCase();
      if (keyStr == 'biometricid' || keyStr == 'biometric_id' || keyStr == 'name' || keyStr == 'designation') {
        res[k.toString()] = v;
      } else {
        res[k.toString()] = '0';
      }
    });
    return res;
  }

  Future<void> _confirmAndTransferData() async {
    if (_validationError != null || _selectedUser == null || _sourceSnapshot == null) return;

    if (_destinationHasExistingData && !_allowOverwrite) {
      widget.showSnackBar(
        'Please acknowledge and check "Allow updating/overwriting existing data in Destination FY" to proceed.',
        isError: true,
      );
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Confirm FY Data Transfer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to transfer FY data for user "${_selectedUser!.username}"?\n',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
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
                  Text('• Selected User: ${_selectedUser!.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Source FY: $_sourceYear  ->  Dest FY: $_destYear'),
                  Text('• February BP: ${_febBpValue > 0 ? "$_febBpValue (> 0)" : "0 (Skipped Main Data)"}'),
                  Text('• Main Section Data: ${_shouldTransferMainData ? "Transferred as-is ($_mainDataCount records)" : "SKIPPED (February BP = 0)"}'),
                  Text('• 12 Months Structure: All 12 Months (Mar - Feb) created'),
                  Text('• February Salary -> March Salary: ${_febSalaryExists ? "$_febSalaryCount record(s)" : "Zero-valued entry"}'),
                  const SizedBox(height: 6),
                  const Text('• Arrears & Deductions: Name and Biometric copied, amounts set to 0', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Original data in Source FY ($_sourceYear) will remain 100% unchanged.',
              style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Transfer Data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isExecutingTransfer = true;
    });

    try {
      final String uname = _selectedUser!.username;
      final String destPath = '$_destYear/$uname';

      Map<String, dynamic> updates = {};
      Map srcMap = Map<String, dynamic>.from(_sourceSnapshot!.value as Map);

      // Extract maindata employee info (bioId -> { name, designation })
      Map<String, Map<String, String>> empInfoMap = {};
      if (srcMap.containsKey('maindata') && srcMap['maindata'] is Map) {
        Map mainDataMap = srcMap['maindata'] as Map;
        mainDataMap.forEach((bioId, bioVal) {
          if (bioVal is Map) {
            empInfoMap[bioId.toString()] = {
              'name': bioVal['name']?.toString() ?? '',
              'designation': bioVal['designation']?.toString() ?? '',
            };
          }
        });
      }

      // Map of months data in Source FY
      Map srcMonthData = (srcMap.containsKey('monthdata') && srcMap['monthdata'] is Map)
          ? (srcMap['monthdata'] as Map)
          : {};

      final List<String> all12Months = [
        'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec', 'jan', 'feb'
      ];

      // Build 12 Months structure for Destination FY
      for (String m in all12Months) {
        Map<String, dynamic> destMonthEmpMap = {};

        if (m == 'mar') {
          // March in Destination FY comes from February in Source FY (with DA=0, Deductions=0)
          if (srcMonthData.containsKey('feb') && srcMonthData['feb'] is Map) {
            Map febEmpMap = srcMonthData['feb'] as Map;
            febEmpMap.forEach((bioId, bioVal) {
              if (bioVal is Map) {
                destMonthEmpMap[bioId.toString()] = _cleanAndProcessMonthEntry(
                  Map<String, dynamic>.from(bioVal),
                );
              }
            });
          }

          // Ensure all employees from maindata are present in March
          empInfoMap.forEach((bioId, info) {
            if (!destMonthEmpMap.containsKey(bioId)) {
              destMonthEmpMap[bioId] = _createZeroValuedMonthEntry(
                bioId: bioId,
                name: info['name'] ?? '',
                designation: info['designation'] ?? '',
              );
            }
          });
        } else {
          // Remaining 11 months: Initialized with Zero Salary Data
          empInfoMap.forEach((bioId, info) {
            destMonthEmpMap[bioId] = _createZeroValuedMonthEntry(
              bioId: bioId,
              name: info['name'] ?? '',
              designation: info['designation'] ?? '',
            );
          });
        }

        updates['$destPath/monthdata/$m'] = destMonthEmpMap;
      }

      // 1. User Profile
      if (srcMap.containsKey(uname)) {
        updates['$destPath/$uname'] = srcMap[uname];
      } else {
        updates['$destPath/$uname'] = _selectedUser!.toMap();
      }

      // 2. Main Section Data (ONLY transferred if February BP > 0!)
      if (_shouldTransferMainData && srcMap.containsKey('maindata')) {
        updates['$destPath/maindata'] = srcMap['maindata'];
      }

      // 3. Preserve other permitted sections
      for (String sec in ['itfdata', 'itaxnew', 'itaxold', 'percentage']) {
        if (srcMap.containsKey(sec) && srcMap[sec] != null) {
          updates['$destPath/$sec'] = srcMap[sec];
        }
      }

      // 4. Arrear Data (arrdata): Copy Name, Biometric ID, Designation, set all other amounts to 0
      if (srcMap.containsKey('arrdata') && srcMap['arrdata'] is Map) {
        Map<String, dynamic> destArrMap = {};
        Map srcArr = srcMap['arrdata'] as Map;
        srcArr.forEach((bioId, val) {
          if (val is Map) {
            destArrMap[bioId.toString()] = _resetArrearOrDeductionEntry(
              Map<String, dynamic>.from(val),
            );
          }
        });
        updates['$destPath/arrdata'] = destArrMap;
      }

      // 5. Deduction Data (deddata): Copy Name, Biometric ID, Designation, set all other amounts to 0
      if (srcMap.containsKey('deddata') && srcMap['deddata'] is Map) {
        Map<String, dynamic> destDedMap = {};
        Map srcDed = srcMap['deddata'] as Map;
        srcDed.forEach((bioId, val) {
          if (val is Map) {
            destDedMap[bioId.toString()] = _resetArrearOrDeductionEntry(
              Map<String, dynamic>.from(val),
            );
          }
        });
        updates['$destPath/deddata'] = destDedMap;
      }

      // Atomic Update in Firebase Realtime Database
      await widget.dbRef.update(updates);

      widget.showSnackBar(
        'FY Data successfully transferred for "$uname" to FY $_destYear (12 Months created, DA/Arrears/Deductions = 0, Main Data ${_shouldTransferMainData ? "transferred" : "skipped (BP=0)"}).',
      );
      widget.onTransferSuccess();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error during FY data transfer execution: $e');
      widget.showSnackBar('Failed to transfer FY data: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isExecutingTransfer = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 560 : MediaQuery.of(context).size.width * 0.92,
        padding: const EdgeInsets.all(26),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer FY Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Copy user financial records between Financial Years',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. User Selection Dropdown
              const Text(
                '1. Select User:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUser?.username,
                    isExpanded: true,
                    icon: const Icon(Icons.person_pin_rounded, color: Color(0xFF2563EB)),
                    hint: const Text('Select a user'),
                    items: widget.allUsers.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.username,
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (u.biometricId.isNotEmpty)
                              Text('  (ID: ${u.biometricId})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (uname) {
                      if (uname != null) {
                        setState(() {
                          _selectedUser = widget.allUsers.firstWhere((u) => u.username == uname);
                        });
                        _fetchPreviewData();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Financial Year Selection Dropdowns
              const Text(
                '2. Financial Year Mapping:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  Set<String> yearSet = Set.from(widget.availableYears);
                  yearSet.add(_sourceYear);
                  yearSet.add(_destYear);
                  yearSet.add(_getNextFy(_sourceYear));
                  List<String> allDropdownYears = yearSet.toList()..sort();

                  return Row(
                    children: [
                      // Source FY
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Source FY (From)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sourceYear,
                                  isExpanded: true,
                                  items: allDropdownYears.map((yr) {
                                    return DropdownMenuItem<String>(
                                      value: yr,
                                      child: Text('FY $yr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (yr) {
                                    if (yr != null) {
                                      setState(() {
                                        _sourceYear = yr;
                                        _destYear = _getNextFy(yr);
                                      });
                                      _fetchPreviewData();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF2563EB), size: 22),
                      ),
                      // Destination FY
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destination FY (To)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _destYear,
                                  isExpanded: true,
                                  items: allDropdownYears.map((yr) {
                                    return DropdownMenuItem<String>(
                                      value: yr,
                                      child: Text('FY $yr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (yr) {
                                    if (yr != null) {
                                      setState(() {
                                        _destYear = yr;
                                      });
                                      _fetchPreviewData();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Preview Section
              const Text(
                '3. Data Transfer Preview:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
              ),
              const SizedBox(height: 8),

              if (_isLoadingPreview)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB))),
                      SizedBox(height: 12),
                      Text('Analyzing Source & Destination FY data...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                )
              else if (_validationError != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile & Main Data Preview
                      Row(
                        children: [
                          const Icon(Icons.badge_rounded, size: 18, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'User: ${_selectedUser!.username} ($_mainDataCount Employee Main Record(s))',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // BP Validation Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _shouldTransferMainData ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _shouldTransferMainData ? const Color(0xFFBBF7D0) : const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _shouldTransferMainData ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                              size: 16,
                              color: _shouldTransferMainData ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _shouldTransferMainData
                                    ? 'February BP = $_febBpValue (> 0) -> Main Data WILL be transferred as-is.'
                                    : 'February BP = 0 -> Main Data transfer WILL BE SKIPPED.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _shouldTransferMainData ? const Color(0xFF15803D) : const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),

                      // Month Salary Mapping Rule Card
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
                            const Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF2563EB)),
                                SizedBox(width: 8),
                                Text(
                                  'Structure & Field Rules:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Source FY ($_sourceYear) Feb Salary', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                                ),
                                const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Dest FY ($_destYear) Mar Salary', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '✓ All 12 Months (Mar - Feb) will be created in Destination FY ($_destYear).',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _febSalaryExists
                                  ? '✓ $_febSalaryCount February salary record(s) mapped to March in FY $_destYear.'
                                  : '• No February salary record in Source FY. March initialized with zero baseline.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _febSalaryExists ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Remaining 11 Months (Apr - Feb): Initialized with zero salary values.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '• Arrears, DA, and Deductions set to 0 across all destination months.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Destination FY Status / Warning
                      if (_destinationHasExistingData) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Existing data found in Destination FY ($_destYear)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'User records already exist in the target year. Check below to allow updating/overwriting.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _allowOverwrite = !_allowOverwrite;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: _allowOverwrite,
                                          activeColor: const Color(0xFFD97706),
                                          onChanged: (val) {
                                            setState(() {
                                              _allowOverwrite = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'Allow updating/overwriting existing data in Destination FY',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Destination FY ($_destYear) is clean for user "${_selectedUser!.username}".',
                                  style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isExecutingTransfer ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: (_validationError == null &&
                            !_isLoadingPreview &&
                            !_isExecutingTransfer &&
                            (!_destinationHasExistingData || _allowOverwrite))
                        ? _confirmAndTransferData
                        : null,
                    icon: _isExecutingTransfer
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: Text(_isExecutingTransfer ? 'Transferring...' : 'Transfer Data Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}


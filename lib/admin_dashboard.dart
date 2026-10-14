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
  }

  @override
  void dispose() {
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

  void _showUserFreezeDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _UserFreezeModal(
        username: user.username,
        availableYears: _availableYears,
        isAllYearsFrozen: _userAllYearsFrozenMap[user.username] ?? false,
        specificYearsMap: _userSpecificYearsFrozenMap[user.username] ?? {},
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
    return TextField(
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
  final Function(bool freeze) onToggleAllYears;
  final Function(String year, bool freeze) onToggleSpecificYear;

  const _UserFreezeModal({
    required this.username,
    required this.availableYears,
    required this.isAllYearsFrozen,
    required this.specificYearsMap,
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
              borderRadius: BorderRadius.circular(16),
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
                  bool isYrFrozen = _allYears || (_specYears[yr] == true);
                  return SwitchListTile(
                    title: Text('FY $yr', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      isYrFrozen ? 'FROZEN' : 'ACTIVE',
                      style: TextStyle(
                        color: isYrFrozen ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    value: isYrFrozen,
                    activeThumbColor: const Color(0xFFDC2626),
                    onChanged: _allYears
                        ? null // Locked if all years frozen
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

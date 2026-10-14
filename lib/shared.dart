import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SharedData {
  static final SharedData _instance = SharedData._internal();
  SharedData._internal();
  factory SharedData() => _instance;

  String userPlace = '';
  String ccurrentYear = '';
  String zone = '';
  bool isAdmin = false;
  bool isYearFrozen = false;
  String? adminUsername;
  String? viewingAsUsername;
}

final sharedData = SharedData();

Future<bool> checkDatabaseFreezeStatus({
  required String username,
  required String year,
}) async {
  try {
    final dbRef = FirebaseDatabase.instance.ref();

    // 1. Check Global Financial Year Freeze
    final yearSnap = await dbRef.child('_admin/frozen_years/$year').get();
    if (yearSnap.exists && yearSnap.value == true) {
      return true;
    }

    // 2. Check User Freeze across ALL Financial Years
    final userAllYearsSnap = await dbRef.child('_admin/frozen_users/$username/all_years').get();
    if (userAllYearsSnap.exists && userAllYearsSnap.value == true) {
      return true;
    }

    // 3. Check User Freeze for SPECIFIC Financial Year
    final userSpecificYearSnap = await dbRef.child('_admin/frozen_users/$username/years/$year').get();
    if (userSpecificYearSnap.exists && userSpecificYearSnap.value == true) {
      return true;
    }
  } catch (e) {
    debugPrint('Error checking database freeze status: $e');
  }
  return false;
}

bool checkYearFrozenAndShowDialog(BuildContext context) {
  if (sharedData.isYearFrozen && !sharedData.isAdmin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 12),
            Text('Data Frozen / Read-Only'),
          ],
        ),
        content: Text(
          'Data for user "${sharedData.viewingAsUsername ?? sharedData.userPlace.split('/').last}" in Financial Year ${sharedData.ccurrentYear} has been frozen by the Administrator.\n\nAll entries are strictly read-only. Contact your administrator to unfreeze.',
          style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF334155)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
    return true;
  }
  return false;
}

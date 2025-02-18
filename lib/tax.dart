// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:universal_html/html.dart';
// import 'package:incometax/shared.dart';
//
// final biometricIdController = TextEditingController();
// final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
// late DatabaseReference bioRef = _dbRef.child(sharedData.userPlace);
// Map<String, Map<String, dynamic>> biometricData = {};
// Map<String, Map<String, dynamic>> filteredData = {}; // For storing filtered results
// bool isLoading = true;
// bool shouldRefetch = true;
// String errorMessage = '';
// TextEditingController searchController = TextEditingController();
//
// bool toLoad = false;
//
// Map<String?, dynamic> itaxnewData = {};
//
// Map<String?, dynamic> novData = {};
// Map<String?, dynamic> decData = {};
// Map<String?, dynamic> janData = {};
//
// Future<String> fetchdedData(BuildContext context, String biometricId) async {
//   try {
//     DatabaseEvent event = await bioRef.child('itaxnew').child(biometricId).once();
//     DataSnapshot snapshot = event.snapshot;
//
//     if (snapshot.exists) {
//       Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
//       Map<String?, dynamic> data = rawData.cast<String, dynamic>();
//       itaxnewData = data;
//     } else {
//       _showErrorDialog(context, "No Data Available");
//     }
//   } catch (error) {
//     _showErrorDialog(context, "Error Fetching Deduction Data \n$error");
//   }
// }
//
// Future<Map<String, Map<String?, dynamic>>> fetchAllMonthData(String biometricId) async {
//   List<String> months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sept', 'oct', 'nov', 'dec'];
//   Map<String, Map<String?, dynamic>> allMonthData = {};
//
//   for (String month in months) {
//     Map<String?, dynamic> data = await fetchMonthData(month, biometricId);
//     allMonthData[month] = data;
//   }
//
//   return allMonthData;
// }
//
// Future<Map<String?, dynamic>> fetchMonthData(String month, String biometricId) async {
//   try {
//
//     DatabaseEvent event = await bioRef
//         .child('monthdata')
//         .child(month)
//         .child(biometricId)
//         .once();
//
//     DataSnapshot snapshot = event.snapshot;
//
//     if (snapshot.exists) {
//       Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
//       Map<String?, dynamic> data = rawData.cast<String, dynamic>();
//
//       return data;
//     } else {
//       if (mounted) {
//         Navigator.pop(context);
//         showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             title: const Text("Error"),
//             content: Text("No Data Available"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       }
//       return{};
//     }
//   } catch (error) {
//     if (mounted) {
//       Navigator.pop(context);
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text("Error"),
//           content: Text("Failed to add data: \n$error"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//     return {};
//   }
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Home Page'),
//       backgroundColor: Colors.blue,
//     ),
//     body: const Center(
//       child: Text(
//         'Welcome',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// }

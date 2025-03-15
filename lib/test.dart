// Map<String, Map<String, dynamic>> biometricData = {
//   '1': {'name': 'a', 'group': 5},
//   '2': {'name': 'b', 'group': 10},
//   '3': {'name': 'c', 'group': 15},
// };
//
// List<String> biometricIds = ['1', '2', '3']; // Example biometric IDs
//
//
// for (int i = 0; i < biometricIds.length; i++) {
//   String key = biometricIds[i];
//
//   if (biometricData.containsKey(key)) {
//     String name = biometricData[key]?['name'] ?? 'Unknown';
//     dynamic group = biometricData[key]?['group'] ?? 'Unknown';
//
//     print('ID: $key, Name: $name, Group: $group');
//   } else {
//     print('ID: $key not found in biometricData.');
//   }
// }
class SharedData {
  static final SharedData _instance = SharedData._internal();
  SharedData._internal();
  factory SharedData() => _instance;

  String userPlace = '';
  String ccurrentYear = '';
  String zone = '';
}

final sharedData = SharedData();

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:incometax/shared.dart';

class MonthDataPage extends StatefulWidget {
  final String biometricId;
  final String shortMonth;
  final String longMonth;

  const MonthDataPage({required this.biometricId, required this.shortMonth, required this.longMonth, super.key});

  @override
  State<MonthDataPage> createState() => _MonthDataPageState();
}

class _MonthDataPageState extends State<MonthDataPage> {

  final TextEditingController biometricidController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController daController = TextEditingController();
  final TextEditingController hraController = TextEditingController();
  final TextEditingController npaController = TextEditingController();
  final TextEditingController splpayController = TextEditingController();
  final TextEditingController convController = TextEditingController();
  final TextEditingController pgController = TextEditingController();
  final TextEditingController annualController = TextEditingController();
  final TextEditingController uniformController = TextEditingController();
  final TextEditingController nursingController = TextEditingController();
  final TextEditingController taController = TextEditingController();
  final TextEditingController daontaController = TextEditingController();
  final TextEditingController medicalController = TextEditingController();
  final TextEditingController dirtController = TextEditingController();
  final TextEditingController washingController = TextEditingController();
  final TextEditingController tbController = TextEditingController();
  final TextEditingController nightController = TextEditingController();
  final TextEditingController driveController = TextEditingController();
  final TextEditingController cycleController = TextEditingController();
  final TextEditingController pcaController = TextEditingController();
  final TextEditingController daext1Controller = TextEditingController();
  final TextEditingController daext2Controller = TextEditingController();
  final TextEditingController daext3Controller = TextEditingController();
  final TextEditingController daext4Controller = TextEditingController();
  final TextEditingController grossController = TextEditingController();
  final TextEditingController incometaxController = TextEditingController();
  final TextEditingController gisController = TextEditingController();
  final TextEditingController gpfController = TextEditingController();
  final TextEditingController npsController = TextEditingController();
  final TextEditingController epfController = TextEditingController();
  final TextEditingController esiController = TextEditingController();
  final TextEditingController slfController = TextEditingController();
  final TextEditingController societyController = TextEditingController();
  final TextEditingController recoveryController = TextEditingController();
  final TextEditingController wfController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController ddext1Controller = TextEditingController();
  final TextEditingController ddext2Controller = TextEditingController();
  final TextEditingController ddext3Controller = TextEditingController();
  final TextEditingController ddext4Controller = TextEditingController();
  final TextEditingController totaldedController = TextEditingController();
  final TextEditingController netsalaryController = TextEditingController();

  bool dachk = false;
  bool hrachk = false;
  bool tachk = false;
  bool npachk = false;
  bool gpfchk = false;
  bool npschk = false;
  bool epfchk = false;
  bool esichk = false;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> monthData = {};
  Map<dynamic, dynamic> percentageData = {};
  bool isLoading = true;
  String errorMessage = '';

  bool isGpfChecked = false;
  bool isNpsChecked = false;
  bool isEpfChecked = false;
  bool isEsiChecked = false;



  @override
  void initState() {
    super.initState();
    fetchMonthData();
  }

  void _setInitialValue(){
    biometricidController.text = monthData['biometricid'] ?? '';
    nameController.text = monthData['name'] ?? '';
    designationController.text = monthData['designation'] ?? '';
    bpController.text = monthData['bp'] ?? '';
    daController.text = monthData['da'] ?? '';
    hraController.text = monthData['hra'] ?? '';
    npaController.text = monthData['npa'] ?? '';
    splpayController.text = monthData['splpay'] ?? '';
    convController.text = monthData['conv'] ?? '';
    pgController.text = monthData['pg'] ?? '';
    annualController.text = monthData['annual'] ?? '';
    uniformController.text = monthData['uniform'] ?? '';
    nursingController.text = monthData['nursing'] ?? '';
    taController.text = monthData['ta'] ?? '';
    daontaController.text = monthData['daonta'] ?? '';
    medicalController.text = monthData['medical'] ?? '';
    dirtController.text = monthData['dirt'] ?? '';
    washingController.text = monthData['washing'] ?? '';
    tbController.text = monthData['tb'] ?? '';
    nightController.text = monthData['night'] ?? '';
    driveController.text = monthData['drive'] ?? '';
    cycleController.text = monthData['cycle'] ?? '';
    pcaController.text = monthData['pca'] ?? '';
    daext1Controller.text = monthData['daext1'] ?? '';
    daext2Controller.text = monthData['daext2'] ?? '';
    daext3Controller.text = monthData['daext3'] ?? '';
    daext4Controller.text = monthData['daext4'] ?? '';
    grossController.text = monthData['gross'] ?? '';
    incometaxController.text = monthData['incometax'] ?? '';
    gisController.text = monthData['gis'] ?? '';
    gpfController.text = monthData['gpf'] ?? '';
    npsController.text = monthData['nps'] ?? '';
    epfController.text = monthData['epf'] ?? '';
    esiController.text = monthData['esi'] ?? '';
    slfController.text = monthData['slf'] ?? '';
    societyController.text = monthData['society'] ?? '';
    recoveryController.text = monthData['recovery'] ?? '';
    wfController.text = monthData['wf'] ?? '';
    otherController.text = monthData['other'] ?? '';
    ddext1Controller.text = monthData['ddext1'] ?? '';
    ddext2Controller.text = monthData['ddext2'] ?? '';
    ddext3Controller.text = monthData['ddext3'] ?? '';
    ddext4Controller.text = monthData['ddext4'] ?? '';
    totaldedController.text = monthData['totalded'] ?? '';
    netsalaryController.text = monthData['netsalary'] ?? '';

    dachk = monthData['dap'] == '1'? true: false;
    hrachk = monthData['hrap'] == '1'? true: false;
    tachk = monthData['tap'] == '1'? true: false;
    npachk = monthData['npap'] == '1'? true: false;
    gpfchk = monthData['gpfchk'] == '1'? true: false;
    npschk = monthData['npschk'] == '1'? true: false;
    epfchk = monthData['epfchk'] == '1'? true: false;
    esichk = monthData['esichk'] == '1'? true: false;

    isGpfChecked = monthData['gpfchk'] == '1'? true: false;
    isNpsChecked = monthData['npschk'] == '1'? true: false;
    isEpfChecked = monthData['epfchk'] == '1'? true: false;
    isEsiChecked = monthData['esichk'] == '1'? true: false;


  }

  @override
  void dispose() {
    // Dispose of each controller
    biometricidController.dispose();
    nameController.dispose();
    designationController.dispose();
    bpController.dispose();
    daController.dispose();
    hraController.dispose();
    npaController.dispose();
    splpayController.dispose();
    convController.dispose();
    pgController.dispose();
    annualController.dispose();
    uniformController.dispose();
    nursingController.dispose();
    taController.dispose();
    daontaController.dispose();
    medicalController.dispose();
    dirtController.dispose();
    washingController.dispose();
    tbController.dispose();
    nightController.dispose();
    driveController.dispose();
    cycleController.dispose();
    pcaController.dispose();
    daext1Controller.dispose();
    daext2Controller.dispose();
    daext3Controller.dispose();
    daext4Controller.dispose();
    grossController.dispose();
    incometaxController.dispose();
    gisController.dispose();
    gpfController.dispose();
    npsController.dispose();
    epfController.dispose();
    esiController.dispose();
    slfController.dispose();
    societyController.dispose();
    recoveryController.dispose();
    wfController.dispose();
    otherController.dispose();
    ddext1Controller.dispose();
    ddext2Controller.dispose();
    ddext3Controller.dispose();
    ddext4Controller.dispose();
    totaldedController.dispose();
    netsalaryController.dispose();

    super.dispose();
  }

  Future<void> fetchMonthData() async {
    try {
      DatabaseReference monthRef = _dbRef
          .child(sharedData.userPlace)
          .child('monthdata')
          .child(widget.shortMonth)
          .child(widget.biometricId);
      DatabaseEvent event = await monthRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        setState(() {
          monthData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
          _setInitialValue();
        });
      } else {
        setState(() {
          errorMessage = 'No data available for ${widget.shortMonth}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.longMonth.toUpperCase()} DATA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2), // Box border
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INFO', // The label text
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildTextField('Biometric ID', 'biometricid', biometricidController),
                      _buildTextField('Name', 'name', nameController),
                      _buildTextField('Designation', 'designation', designationController),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Percentage Variables Section
                Container(

                  width: getFieldWidth() ,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2), // Box border
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'PERCENTAGE VARIABLES', // The label text
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,width: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isWideScreen? 200: 120, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              'DA',
                              'dap',
                              dachk,
                                  (bool newValue) {
                                setState(() {
                                  dachk = newValue;
                                });
                              },
                            ),
                          ),

                          SizedBox(
                            width: isWideScreen? 200: 120, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              'HRA',
                              'hrap',
                              hrachk,
                                  (bool newValue) {
                                setState(() {
                                  hrachk = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,width: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isWideScreen? 200: 120, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              'TA',
                              'tap',
                              tachk,
                                  (bool newValue) {
                                setState(() {
                                  tachk = newValue;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: isWideScreen? 200: 120, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              'NPA',
                              'npap',
                              npachk,
                                  (bool newValue) {
                                setState(() {
                                  npachk = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Details of Allowance Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2), // Box border
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DETAILS OF ALLOWANCE', // The label text
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildTextField('BP', 'bp', bpController),
                      _buildTextField('DA', 'da', daController),
                      _buildTextField('HRA', 'hra', hraController),
                      _buildTextField('NPA', 'npa', npaController),
                      _buildTextField('SPECIAL PAY', 'splpay', splpayController),
                      _buildTextField('CONVEYANCE', 'conv', convController),
                      _buildTextField('PG', 'pg', pgController),
                      _buildTextField('ANNUAL', 'annual', annualController),
                      _buildTextField('UNIFORM', 'uniform', uniformController),
                      _buildTextField('NURSING', 'nursing', nursingController),
                      _buildTextField('TA', 'ta', taController),
                      _buildTextField('DA ON TA', 'daonta', daontaController),
                      _buildTextField('MEDICAL', 'medical', medicalController),
                      _buildTextField('DIRT', 'dirt', dirtController),
                      _buildTextField('WASHING', 'washing', washingController),
                      _buildTextField('TB', 'tb', tbController),
                      _buildTextField('NIGHT', 'night', nightController),
                      _buildTextField('CONTIGENCY', 'drive', driveController),
                      _buildTextField('CYCLE', 'cycle', cycleController),
                      _buildTextField('PCA', 'pca', pcaController),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _buildTextField('GROSS SALARY', 'gross', grossController),
                SizedBox(height: 10),
                // Details of Deduction Section
                Container(
                  width: getFieldWidth(),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2), // Box border
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'DETAILS OF DEDUCTION', // The label text
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildTextField('INCOME TAX', 'incometax', incometaxController),
                      _buildTextField('GIS', 'gis', gisController),
                      _buildTextField('SLF', 'slf', slfController),
                      _buildTextField('SOCIETY', 'society', societyController),
                      _buildTextField('RECOVERY', 'recovery', recoveryController),
                      _buildTextField('WIDOW WELFARE FUND', 'wf', wfController),
                      _buildTextField('OTHER', 'other', otherController),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Small Checkbox for GPF
                          SizedBox(
                            width: 70, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              '',
                              'gpfchk',
                              gpfchk,
                                  (bool newValue) {
                                setState(() {
                                  gpfchk = newValue;
                                });
                              },
                            ),
                          ),

                          // Text Field for GPF, width set equal to checkbox width
                          SizedBox(
                            width: 200, // Set width equal to textfields, same as the checkbox container
                            child: _buildTextField('GPF', 'gpf', gpfController),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Small Checkbox for NPS
                          SizedBox(
                            width: 70, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              '',
                              'npschk',
                              npschk,
                                  (bool newValue) {
                                setState(() {
                                  npschk = newValue;
                                });
                              },
                            ),
                          ),
                          // Text Field for NPS, width set equal to checkbox width
                          SizedBox(
                            width: 200, // Set width equal to textfields, same as the checkbox container
                            child: _buildTextField('NPS', 'nps', npsController),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Small Checkbox for GPF
                          SizedBox(
                            width: 70, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              '',
                              'epfchk',
                              epfchk,
                                  (bool newValue) {
                                setState(() {
                                  epfchk = newValue;
                                });
                              },
                            ),
                          ),

                          // Text Field for GPF, width set equal to checkbox width
                          SizedBox(
                            width: 200, // Set width equal to textfields, same as the checkbox container
                            child: _buildTextField('EPF', 'epf', epfController),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Small Checkbox for GPF
                          SizedBox(
                            width: 70, // Ensure the width is equal to the textfield's width
                            child: _buildCheckbox(
                              '',
                              'esichk',
                              esichk,
                                  (bool newValue) {
                                setState(() {
                                  esichk = newValue;
                                });
                              },
                            ),
                          ),

                          // Text Field for GPF, width set equal to checkbox width
                          SizedBox(
                            width: 200, // Set width equal to textfields, same as the checkbox container
                            child: _buildTextField('ESI', 'esi', esiController),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _buildTextField('TOTAL DEDUCTIONS', 'totalded', totaldedController),
                SizedBox(height: 10),
                _buildTextField('NET SALARY', 'netsalary', netsalaryController),
                SizedBox(height: 10),
                SafeArea(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Outer padding for the entire row
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the row
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding for individual buttons
                            child: _buildButton(label: 'CALCULATE', onPressed: () async {
                              await _calculateData(widget.shortMonth);
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildButton(label: 'SAVE', onPressed: _saveData),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildButton(label: 'SAVE ALL', onPressed: _saveAll),
                          ),
                        ],
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
  double getFieldWidth() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    // Set the width to match text field width (smaller size)
    return isWideScreen ? 612.4 : screenWidth; // Adjusted to 50% of screen width
  }


  Widget _buildTextField(
      String label,
      String key,
      TextEditingController controller,
      ) {
    // Check if it's one of the fields that should stand out
    bool isSpecialField = key == 'gross' || key == 'totalded' || key == 'netsalary';

    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    // Define responsive padding, font size, and height
    double horizontalPadding = isWideScreen ? 32.0 : 16.0;
    double fontSize = isWideScreen ? 22.0 : 18.0; // Adjusted font size for label
    double contentPaddingVertical = isWideScreen ? 18.0 : 14.0; // Reduced vertical padding
    double contentPaddingHorizontal = 25.0; // Constant horizontal padding
    double fieldWidth = isWideScreen ? 500.0 : screenWidth - 32.0; // Set a fixed width for text field

    final Map<String, bool> enabledStatus = {
      'gpf': isGpfChecked,
      'nps': isNpsChecked,
      'epf': isEpfChecked,
      'esi': isEsiChecked,
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
      child: SizedBox(
        width: fieldWidth, // Set a controlled width for the text field
        child: TextField(
          controller: controller,
          enabled: !enabledStatus.containsKey(key) || enabledStatus[key] == true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: fontSize, // Responsive font size for the label
              fontWeight: FontWeight.bold,
              color: isSpecialField ? Colors.black : Colors.black87,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: contentPaddingVertical,
              horizontal: contentPaddingHorizontal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSpecialField ? Colors.orangeAccent.shade100 : Colors.blueGrey,
                width: 3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSpecialField ? Colors.purple : Colors.blueAccent,
                width: 4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSpecialField ? Colors.orangeAccent.shade100 : Colors.blueGrey,
                width: 3,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSpecialField ? Colors.purple[400]! : Colors.red,
                width: 3,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSpecialField ? Colors.orange[400]! : Colors.red[700]!,
                width: 4,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: fontSize,  // Adjusted font size for input text
            fontWeight: isSpecialField ? FontWeight.bold : FontWeight.w400,
            color: Colors.black87,
          ),
          onChanged: (value) {
            setState(() {
              monthData[key] = value;
            });
          },
        ),
      ),
    );
  }



  Widget _buildCheckbox(
      String label,
      String key,
      bool chkvalue,
      Function(bool) onCheckboxChanged,
      ) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600; // Check if the screen is wide (like tablets or desktops)

    // Adjusted responsive parameters
    double checkboxSize = isWideScreen ? 25.0 : 15.0; // Adjust size for wide or narrow screens
    double fontSize = isWideScreen ? 16.0 : 16.0; // Adjust font size
    double containerWidth = isWideScreen ? 200.0 : screenWidth / 2 - 24.0; // Dynamic container width

    final smallCheckboxKeys = {'gpfchk', 'npschk', 'epfchk', 'esichk'};
    bool isSmallCheckbox = smallCheckboxKeys.contains(key);

    return Padding(
      padding: EdgeInsets.all(4), // Reduced padding
      child: Container(
        width: containerWidth, // Dynamically calculated width
        padding: EdgeInsets.all(8), // Reduced padding inside the container
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Smaller radius for corners
          border: Border.all(color: Colors.blueAccent, width: 1.5), // Thinner border
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(30),
              spreadRadius: 0.5, // Subtle shadow
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: checkboxSize / 14.0, // Adjusted scale for the checkbox
              child: Checkbox(
                value: chkvalue,
                onChanged: (bool? value) {
                  if (value != null) {
                    onCheckboxChanged(value);
                    monthData[key] = value ? '1' : '0';
                    setState(() {
                      if (key == 'gpfchk') {
                        isGpfChecked = value;
                        gpfController.text = value ? monthData['gpf'] ?? '0' : '0';
                      } else if (key == 'npschk') {
                        isNpsChecked = value;
                        npsController.text = value ? monthData['nps'] ?? '0' : '0';
                      } else if (key == 'epfchk') {
                        isEpfChecked = value;
                        epfController.text = value ? monthData['epf'] ?? '0' : '0';
                      } else if (key == 'esichk') {
                        isEsiChecked = value;
                        esiController.text = value ? monthData['esi'] ?? '0' : '0';
                      }
                    });
                  }
                },
                activeColor: Colors.blue,
                checkColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  width: 1.5, // Reduced checkbox border width
                  color: Colors.blueAccent,
                ),
              ),
            ),
            if (!isSmallCheckbox)
              SizedBox(width: 8), // Reduced spacing between checkbox and label
            if (!isSmallCheckbox)
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize, // Adjusted font size
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }



  Widget _buildButton({required String label, required Function() onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Background color matching the blue theme
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40), // Larger padding for bigger buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for modern look
        ),
        elevation: 5, // Subtle shadow for depth
        shadowColor: Colors.blue.withValues(alpha: 0.5), // Slight blue shadow
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20, // Larger text size for emphasis
          fontWeight: FontWeight.bold, // Bold text for prominence
          color: Colors.white, // White text color for contrast
        ),
      ),
    );
  }

  Future<void> _calculateData(var month) async {
    try {
      DatabaseReference percentageRef = _dbRef.child(sharedData.userPlace).child('percentage');
      DatabaseEvent event = await percentageRef.once();
      DataSnapshot snapshot = event.snapshot;
      // await percentageRef.set(monthData);
      if (snapshot.exists) {
        // Cast the snapshot value safely
        Map<Object?, Object?> rawData = snapshot.value as Map<Object?, Object?>;
        // Initialize the data map
        Map<dynamic, dynamic> percentageData = {};
        // Ensure data exists and process the fetched rawData
        rawData.forEach((key, value) {
          // Ensure each value is a valid Map, and add to the percentageData
          percentageData[key] = value;
        });

        setState(() {
          // Store the percentage data in the state
          this.percentageData = percentageData; // Initially, no filter applied
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    }

    try {
      int dap = 0, hrap = 0, tap = 0, npap = 0;
      int? bp = int.tryParse(bpController.text);
      int? npa = int.tryParse(npaController.text);

      if (npachk) {
        npap = int.tryParse(percentageData['${month}n'])!;
        npa = (bp! * (npap / 100)).round();
        if (npa + bp > 237500) {
          npa = npa - (bp + npa - 237500);
        }
        monthData['npa'] = npaController.text = npa.toString();
      } else {
        monthData['npa'] = npaController.text = '0';
      }
      if (dachk) {
        dap = int.tryParse(percentageData['${month}d'])!;
        monthData['da'] =
            daController.text = ((bp! + npa!) * (dap / 100)).round().toString();
      } else {
        monthData['da'] = daController.text = '0';
      }
      if (hrachk) {
        hrap = int.tryParse(percentageData['${month}h'])!;
        monthData['hra'] =
            hraController.text = ((bp)! * (hrap / 100)).round().toString();
      } else {
        monthData['hra'] = hraController.text = '0';
      }
      if (tachk) {
        tap = int.tryParse(percentageData['${month}d'])!;
        monthData['daonta'] = daontaController.text =
            (int.tryParse(taController.text)! * (tap / 100)).round().toString();
      } else {
        monthData['daonta'] = daontaController.text = '0';
      }

      var controllers = [
        bpController,
        daController,
        hraController,
        npaController,
        splpayController,
        convController,
        pgController,
        annualController,
        uniformController,
        nursingController,
        taController,
        daontaController,
        medicalController,
        dirtController,
        washingController,
        tbController,
        nightController,
        driveController,
        cycleController,
        pcaController,
        daext1Controller,
        daext2Controller,
        daext3Controller,
        daext4Controller,
      ];

      // Sum all values, using 0 for empty or invalid inputs
      double grossTotal = controllers
          .map((controller) => double.tryParse(controller.text) ?? 0)
          .reduce((sum, value) => sum + value);

      monthData['gross'] = grossController.text = grossTotal.round().toString();

      if (npschk && gpfchk) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: const Text("Both NPS and GPF cannot coexist"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
        return;
      } else if (npschk && !gpfchk) {
        controllers = [
          bpController,
          npaController,
          daController,
        ];

        double npsTotal = controllers
            .map((controller) => double.tryParse(controller.text) ?? 0)
            .reduce((sum, value) => sum + value);

        monthData['nps'] =
            npsController.text = (npsTotal * 0.10).round().toString();
      }
      monthData['epf'] = monthData['esi'] = '0';

      if (esichk){
        if ((int.tryParse(monthData['gross']) ?? 0) <= 21000){
          monthData['esi'] = esiController.text = ((int.tryParse(monthData['gross']) ?? 0) *0.0075).ceil().toString();
        }
      }

      if(epfchk){
        if ((int.tryParse(monthData['gross']) ?? 0) >= 15000){
          monthData['epf'] = epfController.text = '1800'; // 15000*0.12
        } else {
          monthData['epf'] = epfController.text = ((int.tryParse(monthData['gross']) ?? 0) *0.12).round().toString();
        }
      }
      if (month == 'feb') incometaxController.text = '0';
      var dedControllers = [
        incometaxController,
        gisController,
        gpfController,
        npsController,
        slfController,
        societyController,
        recoveryController,
        wfController,
        otherController,
        ddext1Controller,
        ddext2Controller,
        ddext3Controller,
        ddext4Controller,
      ];

      double dedTotal = dedControllers
          .map((controller) => double.tryParse(controller.text) ?? 0)
          .reduce((sum, value) => sum + value);

      monthData['totalded'] =
          totaldedController.text = dedTotal.round().toString();
      monthData['netsalary'] = netsalaryController.text =
          ((int.tryParse(grossController.text))! -
                  (int.tryParse(totaldedController.text))!)
              .toString();
    } catch (error) {
      final String message = "Error: $error";
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }


  Future<void> _saveData() async {
    try {
      DatabaseReference monthRef = _dbRef
          .child(sharedData.userPlace)
          .child('monthdata')
          .child(widget.shortMonth)
          .child(widget.biometricId);
      await monthRef.set(monthData);
      if (mounted){
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Data Saved Successfully"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$e"),
            actions: [
              TextButton(
                onPressed: () => {
                  Navigator.pop(ctx),
                  Navigator.pop(context),
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveAll() async {
    final List<String> months = ['mar','apr','may','jun','jul','aug','sept','oct','nov','dec','jan','feb'];
    List<String> updatedmonths = [];
    try {
      DatabaseReference monthRef = _dbRef
          .child(sharedData.userPlace)
          .child('monthdata');
      final int targetIndex = months.indexOf(widget.shortMonth);

      if (targetIndex != -1) {
        for (int i = targetIndex; i < months.length; i++) {
          final String currentMonth = months[i];
          updatedmonths.add(currentMonth);
          await _calculateData(currentMonth);
          if (months[i] == 'feb'){
            monthData['incometax'] = '0';
          }
          await monthRef.child(currentMonth).child(widget.biometricId).set(monthData);
        }
      } else{
        final String message = "Invalid month : ${widget.shortMonth}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      if (mounted){
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: Text("Data Saved Successfully for months: \n$updatedmonths"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add data: \n$e"),
            actions: [
              TextButton(
                onPressed: () => {
                  Navigator.pop(ctx),
                  Navigator.pop(context),
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
}

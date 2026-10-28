  import 'dart:async';
  import 'dart:io';

  import 'package:flutter_background/flutter_background.dart';
  import 'package:image_picker/image_picker.dart';
 
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';

  import '../widgets/background_screen.dart';

  import '../algorithm/rf_assessment_input.dart';
  import '../database/database_helper.dart';
  import '../models/current_user.dart';
  import '../bluetooth/ble_manager.dart';
  import '../services/rf_prediction_service.dart';

  import 'health_log_screen1.dart';
  import 'home_screen1.dart';
  import 'live_graph_screen.dart';
  import 'settings_screen.dart';
  import '../services/notification_service.dart';
  import '../services/monitoring_controller.dart';


  class MonitorScreen extends StatefulWidget {
    const MonitorScreen({super.key});

    @override
    State<MonitorScreen> createState() => _MonitorScreenState();


  }



  class _MonitorScreenState extends State<MonitorScreen>
    with WidgetsBindingObserver {

    late final MonitoringController monitoringController;

    int _lastHandledTriggerEventId = 0;
    bool _isAppInForeground = true;

    Timer? timer;

    final RfPredictionService rfPredictionService =
        RfPredictionService();


    // ======================================================
    // RF MONITORING TRIGGER VARIABLES
    // ======================================================


    // Separate timer for monitoring observations
    Timer? monitoringTimer;
    // Controls whether monitoring is active.
    bool isMonitoring = false;

    

    bool temporaryTestMode = true;


    final ImagePicker picker = ImagePicker();

    File? selectedImage;

    final GlobalKey<ScaffoldState> _scaffoldKey =
        GlobalKey<ScaffoldState>();


    Future<void> pickImage(ImageSource source) async {
  final XFile? image = await picker.pickImage(
    source: source,
  );

  if (image != null) {
    await DatabaseHelper.instance.updatePatientPhoto(
      patientId: CurrentUser.patientId!,
      photoPath: image.path,
    );

    setState(() {
      selectedImage = File(image.path);
    });
  }
}

void showImagePicker() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      );
    },
  );
}

String getDefaultPetImage() {
  if (CurrentUser.species == 'Canine') {
    return 'assets/images/default_dog.jpg';
  } else if (CurrentUser.species == 'Feline') {
    return 'assets/images/default_cat.jpg';
  }

  return 'assets/images/default_dog.jpg';
}

Future<void> loadPatientPhoto() async {
  final photoPath =
      await DatabaseHelper.instance.getPatientPhoto(
    CurrentUser.patientId!,
  );

  if (photoPath != null && photoPath.isNotEmpty) {
    final imageFile = File(photoPath);

    if (await imageFile.exists()) {
      setState(() {
        selectedImage = imageFile;
      });
    }
  }
}




Future<bool> _initializeBackgroundMonitoring() async {
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'AniSafe Monitoring',
    notificationText: 'Monitoring is active',
    notificationImportance: AndroidNotificationImportance.normal,
    enableWifiLock: true,
  );

  final initialized = await FlutterBackground.initialize(
    androidConfig: androidConfig,
  );

  return initialized;
}




// ======================================================
// START MONITORING
// ======================================================


Future<void> _startMonitoring() async {
  if (monitoringController.isMonitoring ||
      monitoringController.isStarting) {
    return;
  }

  final started = await monitoringController.startMonitoring();

  if (!mounted) return;

  if (!started) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'AniSafe could not start monitoring. '
          'Check the ESP32 connection and background permissions.',
        ),
      ),
    );
    return;
  }

  setState(() {
    isMonitoring = monitoringController.isMonitoring;
  });
}



// ======================================================
// STOP MONITORING
// ======================================================


Future<void> _stopMonitoring() async {
  await monitoringController.stopMonitoring();

  if (!mounted) return;

  setState(() {
    isMonitoring = monitoringController.isMonitoring;
  });
}


@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addObserver(this);

  monitoringController = MonitoringController.instance;
  monitoringController.addListener(_onMonitoringControllerChanged);

  isMonitoring = monitoringController.isMonitoring;
  _lastHandledTriggerEventId = monitoringController.triggerEventId;
  

  loadPatientPhoto();
  _connectToSavedESP32();

  timer = Timer.periodic(
    const Duration(milliseconds: 500),
    (_) {
      if (mounted) {
        setState(() {});
      }
    },
  );
}




void _onMonitoringControllerChanged() {
  if (!mounted) return;

  final int currentEventId = monitoringController.triggerEventId;
  String? triggerToShow;

  if (currentEventId != _lastHandledTriggerEventId) {
    _lastHandledTriggerEventId = currentEventId;

    if (_isAppInForeground) {
      triggerToShow = monitoringController.latestTriggerFinding;
    }
  }

  setState(() {
    isMonitoring = monitoringController.isMonitoring;
  });

  if (triggerToShow != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isAppInForeground) return;
      _showMonitoringTriggerDialog(triggerToShow!);
    });
  }
}





@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  _isAppInForeground = state == AppLifecycleState.resumed;
}

void _showMonitoringTriggerDialog(String finding) {
  if (!mounted || !_isAppInForeground) return;

  final bool isWarning = finding == 'Warning';

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          isWarning
              ? '⚠️ Warning Detected'
              : '🚨 Abnormal Reading Detected',
        ),
        content: Text(
          isWarning
              ? 'Your pet has experienced 3 consecutive Warning minutes.'
              : 'Your pet has experienced 4 consecutive Abnormal minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Acknowledge'),
          ),
        ],
      );
    },
  );
}






String _classifyVital({
  required double value,
  required double normalMin,
  required double normalMax,
  required double warningLowMin,
  required double warningLowMax,
  required double warningHighMin,
  required double warningHighMax,
  required double abnormalLowMax,
  required double abnormalHighMin,
}) {
  // Abnormal range
  if (value <= abnormalLowMax || value >= abnormalHighMin) {
    return 'Abnormal';
  }

  // Warning range
  if ((value >= warningLowMin && value <= warningLowMax) ||
      (value >= warningHighMin && value <= warningHighMax)) {
    return 'Warning';
  }

  // Normal range
  if (value >= normalMin && value <= normalMax) {
    return 'Normal';
  }

  // Any value outside the defined ranges
  return 'Abnormal';
}





String _getOverallObservationFinding() {
  final species = CurrentUser.species.toLowerCase();


  final bpm = BleManager.instance.bpm.toDouble();
  final spo2 = BleManager.instance.spo2.toDouble();
  final temperature =
      BleManager.instance.temperature.toDouble();
  final respiratoryRate =
      BleManager.instance.respiratoryRate.toDouble();

  String bpmFinding;
  String rrFinding;
  String temperatureFinding;

  if (species == 'cat' || species == 'feline') {
    bpmFinding = _classifyVital(
      value: bpm,
      normalMin: 120,
      normalMax: 140,
      warningLowMin: 117,
      warningLowMax: 119,
      warningHighMin: 141,
      warningHighMax: 143,
      abnormalLowMax: 116,
      abnormalHighMin: 144,
    );

    rrFinding = _classifyVital(
      value: respiratoryRate,
      normalMin: 16,
      normalMax: 40,
      warningLowMin: 14,
      warningLowMax: 15,
      warningHighMin: 41,
      warningHighMax: 46,
      abnormalLowMax: 13,
      abnormalHighMin: 47,
    );

    temperatureFinding = _classifyVital(
      value: temperature,
      normalMin: 38,
      normalMax: 39,
      warningLowMin: 36,
      warningLowMax: 37,
      warningHighMin: 40,
      warningHighMax: 41,
      abnormalLowMax: 35,
      abnormalHighMin: 42,
    );
  } else {
    bpmFinding = _classifyVital(
      value: bpm,
      normalMin: 70,
      normalMax: 120,
      warningLowMin: 67,
      warningLowMax: 69,
      warningHighMin: 121,
      warningHighMax: 123,
      abnormalLowMax: 66,
      abnormalHighMin: 124,
    );

    rrFinding = _classifyVital(
      value: respiratoryRate,
      normalMin: 18,
      normalMax: 34,
      warningLowMin: 15,
      warningLowMax: 17,
      warningHighMin: 35,
      warningHighMax: 40,
      abnormalLowMax: 14,
      abnormalHighMin: 41,
    );

    temperatureFinding = _classifyVital(
      value: temperature,
      normalMin: 37,
      normalMax: 39,
      warningLowMin: 35,
      warningLowMax: 36,
      warningHighMin: 40,
      warningHighMax: 41,
      abnormalLowMax: 34,
      abnormalHighMin: 42,
    );
  }

  // SpO2 thresholds are the same for dogs and cats.
  final spo2Finding = spo2 <= 90
      ? 'Abnormal'
      : (spo2 >= 91 && spo2 <= 94)
          ? 'Warning'
          : (spo2 >= 95 && spo2 <= 100)
              ? 'Normal'
              : 'Abnormal';

  final findings = [
    bpmFinding,
    spo2Finding,
    temperatureFinding,
    rrFinding,
  ];

  // Highest severity takes priority.
  if (findings.contains('Abnormal')) {
    return 'Abnormal';
  }

  if (findings.contains('Warning')) {
    return 'Warning';
  }

  return 'Normal';
}




Future<void> _connectToSavedESP32() async {
  print("MonitorScreen: Checking saved ESP32...");

  await BleManager.instance.connectToSavedDevice();

  if (mounted) {
    setState(() {});
  }
}






    @override
    void dispose() {
      print('MonitorScreen disposed');

      timer?.cancel();
      monitoringTimer?.cancel();

      monitoringController.removeListener(
        _onMonitoringControllerChanged,
      );

      rfPredictionService.dispose();

      WidgetsBinding.instance.removeObserver(this);

      super.dispose();
    }









    @override
    Widget build(BuildContext context) {
      

      final petIcon =
          CurrentUser.species == 'Canine'
              ? '🐶'
              : CurrentUser.species == 'Feline'
                  ? '🐱'
                  : '🐾';




      return Scaffold(
        key: _scaffoldKey,

        drawer: Drawer(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Patient Profile",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: showImagePicker,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : AssetImage(getDefaultPetImage()),
                              child: selectedImage == null
                                  ? const Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 5),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Tap to Change Photo",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "User Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),


                   
                    Text(
                      "Full Name : ${CurrentUser.fullName}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Gender : ${CurrentUser.gender}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Age : ${CurrentUser.userAge} Years",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 30),
                    



                    const Text(
                      "Patient Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),

                    Text(
                      "Pet Name : ${CurrentUser.patientName}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Age : ${CurrentUser.age} Years",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Breed : ${CurrentUser.breed}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Sex : ${CurrentUser.sex}",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Species : ${CurrentUser.species}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        body: BackgroundScreen(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Row(
                    children: [
                      // Hamburger
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 36,
                          color: Color.fromARGB(255, 6, 0, 0),
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),

                      // Live Monitoring - Center
                      Expanded(
                        child: Center(
                          child: const Text(
                            '🩺Live Monitoring',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Settings
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          size: 36,
                          color: Color.fromARGB(255, 6, 0, 0),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Currently Monitoring',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '$petIcon ${CurrentUser.patientName.isEmpty ? "Unknown Patient" : CurrentUser.patientName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 12),



                  const SizedBox(height: 20),




                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.35,
                    children: [
                      // HEART RATE
                      _buildVitalBox(
                        isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.bpm > 0
                            ? '${BleManager.instance.bpm} BPM'
                            : '-- BPM',
                        '❤️Heart Rate',
                        valueColor: isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.bpm > 0
                            ? _getVitalValueColor(
                                vital: 'bpm',
                                value: BleManager.instance.bpm.toDouble(),
                              )
                            : Colors.grey,
                      ),

                      // TEMPERATURE
                      _buildVitalBox(
                        isMonitoring &&
                                BleManager.instance.temperature > 0
                            ? '${BleManager.instance.temperature.toStringAsFixed(1)} °C'
                            : '-- °C',
                        '🌡️Temperature',
                        valueColor: isMonitoring &&
                                BleManager.instance.temperature > 0
                            ? _getVitalValueColor(
                                vital: 'temperature',
                                value: BleManager.instance.temperature.toDouble(),
                              )
                            : Colors.grey,
                      ),

                      // RESPIRATORY RATE
                      _buildVitalBox(
                        isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.respiratoryRate > 0
                            ? '${BleManager.instance.respiratoryRate} BrPM'
                            : '-- BrPM',
                        '🫁Respiratory Rate',
                        valueColor: isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.respiratoryRate > 0
                            ? _getVitalValueColor(
                                vital: 'rr',
                                value: BleManager.instance.respiratoryRate.toDouble(),
                              )
                            : Colors.grey,
                      ),

                      // OXYGEN SATURATION
                      _buildVitalBox(
                        isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.spo2 > 0
                            ? '${BleManager.instance.spo2} %'
                            : '-- %',
                        '🩸Oxygen Saturation',
                        valueColor: isMonitoring &&
                                BleManager.instance.fingerDetected &&
                                BleManager.instance.spo2 > 0
                            ? _getVitalValueColor(
                                vital: 'spo2',
                                value: BleManager.instance.spo2.toDouble(),
                              )
                            : Colors.grey,
                      ),
                    ],
                  ),






                const SizedBox(height: 10),





                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        BleManager.instance.connectionStatus == "Connected"
                            ? "🟢"
                            : "🔴",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        BleManager.instance.connectionStatus,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),



                  const SizedBox(height: 10),

                  // ======================================================
                  // COMPACT MONITORING BUTTONS
                  // ======================================================

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3.4,

                    children: [
                      // START / STOP MONITORING
                      _buildCompactButton(
                        label: isMonitoring
                            ? 'Stop Monitoring'
                            : 'Start Monitoring',

                        
                        onPressed: () {
                          if (isMonitoring) {
                            _stopMonitoring();
                          } else {
                            _startMonitoring();
                          }
                        },

                        backgroundColor:
                            isMonitoring ? Colors.red : Colors.green,

                        foregroundColor: Colors.white,
                      ),
                      
                    

                      // TEST ABNORMAL TRIGGER
                      if (temporaryTestMode)
                        _buildCompactButton(
                          label: 'Test Abnormal Trigger',
                          onPressed: monitoringController.runAbnormalTriggerTest,
                        ),

                      // HEALTH LOGS
                      _buildCompactButton(
                        label: 'Health Logs',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HealthLogScreen(),
                            ),
                          );
                        },
                      ),

                      // SAVE DATA
                      _buildCompactButton(
                        label: 'Save Data',
                        onPressed: () async {
                          final now = DateTime.now();

                          final date = DateFormat('MMM d EEE').format(now);
                          final time = DateFormat('hh:mm a').format(now);

                          await DatabaseHelper.instance.insertRecord(
                            patientId: CurrentUser.patientId!,
                            bpm: BleManager.instance.bpm,
                            spo2: BleManager.instance.spo2,
                            temperature: BleManager.instance.temperature,
                            respiratoryRate: BleManager.instance.respiratoryRate,
                            date: date,
                            time: time,
                          );

                          print('Health data saved.');
                        },
                      ),

                      // BACK TO HOME
                      _buildCompactButton(
                        label: 'Back to Home',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),





                ],
              ),
            ),
          ),
        ),
      );
    }



    Color _getVitalValueColor({
      required String vital,
      required double value,
    }) {
      final finding =
          monitoringController.classifyVitalReading(
        vital: vital,
        value: value,
      );

      switch (finding) {
        case 'Normal':
          return Colors.green;
        case 'Warning':
          return Colors.yellow;
        case 'Abnormal':
        default:
          return Colors.red;
      }
    }



    
  Widget _buildCompactButton({
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,

          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          minimumSize: const Size(0, 42),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }






    Widget _buildVitalBox( String value, String label, { Color valueColor = Colors.black, }) 
    {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

          ],
        ),
      );
    }
}
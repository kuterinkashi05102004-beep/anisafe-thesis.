import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';

import '../database/database_helper.dart';

//import 'prediagnostic_screen1.dart';
import 'health_log_screen1.dart';
import 'monitor_screen2blue.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/current_user.dart';

import 'settings_screen.dart';

class ViewLogScreen extends StatefulWidget {

  final int recordId;

  const ViewLogScreen({
    super.key,
    required this.recordId,
  });

  @override
  State<ViewLogScreen> createState() => _ViewLogScreenState();
}

class _ViewLogScreenState extends State<ViewLogScreen> {

  late Future<Map<String, dynamic>?> _record;

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
        if (mounted) {
          setState(() {
            selectedImage = imageFile;
          });
        }
      }
    }
  }


  @override
  void initState() {
    super.initState();

    _record = DatabaseHelper.instance.getRecordById(
      widget.recordId,
    );

    loadPatientPhoto();
  }


  
  @override
  Widget build(BuildContext context) {
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
                          "Patient Information",
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
                                      padding: EdgeInsets.only(bottom: 5),
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
                    "Name : ${CurrentUser.fullName}",
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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

                    // View Log - Center
                    Expanded(
                      child: Center(
                        child: const Text(
                          '📋View Log',
                          style: TextStyle(
                            fontSize: 30,
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

                FutureBuilder<Map<String, dynamic>?>(
                  future: _record,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text(
                        'No Record Found',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    final record = snapshot.data!;





                    return Column(
                      children: [

                        Text(
                          '${record['date']} ${record['time']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),


                        
                        // ==============================
                        // PRE-DIAGNOSTIC REPORT
                        // ==============================


                        Builder(
                        builder: (context) {
                          final bpm = (record['bpm'] as num?)?.toDouble() ?? 0;
                          final rr =
                              (record['respiratory_rate'] as num?)?.toDouble() ?? 0;
                          final spo2 = (record['spo2'] as num?)?.toDouble() ?? 0;
                          final temperature =
                              (record['temperature'] as num?)?.toDouble() ?? 0;

                          final findings = [
                            _getVitalFinding(vital: 'BPM', value: bpm),
                            _getVitalFinding(vital: 'RR', value: rr),
                            _getVitalFinding(vital: 'SpO2', value: spo2),
                            _getVitalFinding(vital: 'Temperature', value: temperature),
                          ];

                          final hasAbnormal = findings.contains('Abnormal');
                          final hasWarning = findings.contains('Warning');

                          String reportText;

                          if (hasAbnormal && hasWarning) {
                            reportText =
                                'Based on collected vital signs,\n'
                                'the system detects critical warnings/abnormalities\n'
                                'requiring immediate attention.';
                          } else if (hasAbnormal) {
                            reportText =
                                'Based on collected vital signs,\n'
                                'the system detects critical abnormalities\n'
                                'requiring immediate attention.';
                          } else if (hasWarning) {
                            reportText =
                                'Based on collected vital signs,\n'
                                'the system detects warnings\n'
                                'requiring attention.';
                          } else {
                            reportText =
                                'Based on collected vital signs,\n'
                                'the system detects no warnings or abnormalities.';
                          }

                          return Text(
                            reportText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          );
                        },
                      ),



                        /*

                        const Text(
                          'Pre-diagnostic Report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Based on collected vital signs,\n'
                          'the system detects critical abnormalities\n'
                          'requiring immediate attention.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 25),

                        */


                        /*
                        const Text(
                          'Vital Signs',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 420,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,

                            children: [

                              _buildVitalBox(
                                '${record['bpm']} BPM',
                                'BPM',
                              ),

                              _buildVitalBox(
                                '${record['temperature']} °C',
                                'Temperature',
                              ),

                              _buildVitalBox(
                                '${record['respiratory_rate']} BrPM',
                                'Respiratory Rate',
                              ),

                              _buildVitalBox(
                                '${record['spo2']} %',
                                'SpO₂',
                              ),

                            ],
                          ),
                        ),  */

                        const SizedBox(height: 25),

                        // ==============================
                        // RF ASSESSMENT
                        // ==============================

                        if (record['rf_finding'] != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Vital Signs Assessment',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),
                                /*
                                const Text(
                                  'Vital Signs Assessed:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10), */

                                Text(
                                  'Heart Rate: ${record['bpm']} BPM',
                                  style: const TextStyle(fontSize: 18),
                                ),

                                Text(
                                  'Temperature: ${record['temperature']} °C',
                                  style: const TextStyle(fontSize: 18),
                                ),

                                Text(
                                  'Respiratory Rate: ${record['respiratory_rate']} BrPM',
                                  style: const TextStyle(fontSize: 18),
                                ),

                                Text(
                                  'O₂ Saturation: ${record['spo2']} %',
                                  style: const TextStyle(fontSize: 18),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  'Trigger Finding: ${record['trigger_finding']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Overall Finding: ${record['rf_finding']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: record['rf_finding'] == 'Abnormal'
                                        ? Colors.red
                                        : record['rf_finding'] == 'Warning'
                                            ? Colors.orange
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 25),


                        
                        // ==============================
                        // PRE-DIAGNOSTIC REPORT
                        // ==============================
                        /*
                        const Text(
                          'Pre-diagnostic Report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Based on collected vital signs,\n'
                          'the system detects critical abnormalities\n'
                          'requiring immediate attention.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 25),

                        */



                        Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (context) {
                              final double bpm =
                                  (record['bpm'] as num?)?.toDouble() ?? 0;

                              final double rr =
                                  (record['respiratory_rate'] as num?)?.toDouble() ?? 0;

                              final double spo2 =
                                  (record['spo2'] as num?)?.toDouble() ?? 0;

                              final double temperature =
                                  (record['temperature'] as num?)?.toDouble() ?? 0;

                              final String bpmFinding = _getVitalFinding(
                                vital: 'BPM',
                                value: bpm,
                              );

                              final String rrFinding = _getVitalFinding(
                                vital: 'RR',
                                value: rr,
                              );

                              final String spo2Finding = _getVitalFinding(
                                vital: 'SpO2',
                                value: spo2,
                              );

                              final String temperatureFinding = _getVitalFinding(
                                vital: 'Temperature',
                                value: temperature,
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vital Signs Status:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Pulse Rate/Heart Rate: ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        TextSpan(
                                          text: bpmFinding == 'Abnormal' ? 'Critical' : bpmFinding,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getFindingColor(bpmFinding),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Respiratory Rate: ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        TextSpan(
                                          text: rrFinding == 'Abnormal' ? 'Critical' : rrFinding,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getFindingColor(rrFinding),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'O₂ Saturation: ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        TextSpan(
                                          text: spo2Finding == 'Abnormal' ? 'Critical' : spo2Finding,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getFindingColor(spo2Finding),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Temperature: ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        TextSpan(
                                          text: temperatureFinding == 'Abnormal' ? 'Critical' : temperatureFinding,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getFindingColor(temperatureFinding),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),



                        const SizedBox(height: 25),



                              /*
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Possible Conditions:\n'
                            '1. Severe hyperthermia\n'
                            '2. Severe tachycardia\n'
                            '3. Sensor contact error',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                              */


                        

                        // ==============================
                        // POSSIBLE CONDITIONS
                        // ==============================

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (context) {
                              final conditions = _getPossibleConditions(record);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Possible Conditions:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  if (conditions.isEmpty)
                                    const Text(
                                      'No warning or abnormal conditions detected.',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  else
                                    ...conditions.asMap().entries.map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          '${entry.key + 1}. ${entry.value}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              );
                            },
                          ),
                        ),




                      ],
                    );


                  },
                  
                ),

         

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Health Logs',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Monitoring',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),



              ],
            ),
          ),
        ),
      ),
    ),



    );
  }






  String _getVitalFinding({
    required String vital,
    required double value,
  }) {
    final species =
        (CurrentUser.species ?? 'Canine').toLowerCase();

    // ==============================
    // CANINE
    // ==============================
    if (species == 'canine' || species == 'dog') {
      if (vital == 'BPM') {
        if (value <= 66 || value >= 124) {
          return 'Abnormal';
        } else if ((value >= 67 && value <= 69) ||
            (value >= 121 && value <= 123)) {
          return 'Warning';
        } else if (value >= 70 && value <= 120) {
          return 'Normal';
        }
      }

      if (vital == 'RR') {
        if (value <= 14 || value >= 41) {
          return 'Abnormal';
        } else if ((value >= 15 && value <= 17) ||
            (value >= 35 && value <= 40)) {
          return 'Warning';
        } else if (value >= 18 && value <= 34) {
          return 'Normal';
        }
      }

      if (vital == 'Temperature') {
        if (value <= 34 || value >= 42) {
          return 'Abnormal';
        } else if ((value >= 35 && value <= 36) ||
            (value >= 40 && value <= 41)) {
          return 'Warning';
        } else if (value >= 37 && value <= 39) {
          return 'Normal';
        }
      }
    }

    // ==============================
    // FELINE
    // ==============================
    if (species == 'feline' || species == 'cat') {
      if (vital == 'BPM') {
        if (value <= 116 || value >= 144) {
          return 'Abnormal';
        } else if ((value >= 117 && value <= 119) ||
            (value >= 141 && value <= 143)) {
          return 'Warning';
        } else if (value >= 120 && value <= 140) {
          return 'Normal';
        }
      }

      if (vital == 'RR') {
        if (value <= 13 || value >= 47) {
          return 'Abnormal';
        } else if ((value >= 14 && value <= 15) ||
            (value >= 41 && value <= 46)) {
          return 'Warning';
        } else if (value >= 16 && value <= 40) {
          return 'Normal';
        }
      }

      if (vital == 'Temperature') {
        if (value <= 35 || value >= 42) {
          return 'Abnormal';
        } else if ((value >= 36 && value <= 37) ||
            (value >= 40 && value <= 41)) {
          return 'Warning';
        } else if (value >= 38 && value <= 39) {
          return 'Normal';
        }
      }
    }

    // ==============================
    // SpO₂ — SAME FOR BOTH
    // ==============================
    if (vital == 'SpO2') {
      if (value <= 90) {
        return 'Abnormal';
      } else if (value >= 91 && value <= 94) {
        return 'Warning';
      } else if (value >= 95 && value <= 100) {
        return 'Normal';
      }
    }

    return 'Abnormal';
  }

  Color _getFindingColor(String finding) {
    if (finding == 'Normal') {
      return Colors.green;
    }

    if (finding == 'Warning') {
      return Colors.yellow;
    }

    return Colors.red;
  }



  // ======================================================
// PRESENTATION-ONLY BASELINE
// Possible Conditions for ViewLogScreen
// ======================================================

List<String> _getPossibleConditions(
  Map<String, dynamic> record,
) {
  final species = (CurrentUser.species ?? 'Canine').toLowerCase();

  final conditions = <String>[];

  // Read recorded vital values safely.
  double? getValue(String key) {
    final rawValue = record[key];

    if (rawValue == null) return null;

    final value = double.tryParse(rawValue.toString());

    // Ignore missing or invalid sensor readings.
    if (value == null || value <= 0) return null;

    return value;
  }

  final bpm = getValue('bpm');
  final spo2 = getValue('spo2');
  final temperature = getValue('temperature');
  final rr = getValue('respiratory_rate');

  final isDog = species == 'canine' || species == 'dog';
  final isCat = species == 'feline' || species == 'cat';

  // ======================================================
  // BPM
  // ======================================================

  if (bpm != null) {
    if (isDog) {
      if (bpm <= 66) {
        conditions.add('Severe bradycardia');
      } else if (bpm <= 69) {
        conditions.add('Bradycardia');
      } else if (bpm >= 124) {
        conditions.add('Severe tachycardia');
      } else if (bpm >= 121) {
        conditions.add('Tachycardia');
      }
    } else if (isCat) {
      if (bpm <= 116) {
        conditions.add('Severe bradycardia');
      } else if (bpm <= 119) {
        conditions.add('Bradycardia');
      } else if (bpm >= 144) {
        conditions.add('Severe tachycardia');
      } else if (bpm >= 141) {
        conditions.add('Tachycardia');
      }
    }
  }

  // ======================================================
  // RESPIRATORY RATE
  // ======================================================

  if (rr != null) {
    if (isDog) {
      if (rr <= 14) {
        conditions.add('Severe bradypnea');
      } else if (rr <= 17) {
        conditions.add('Bradypnea');
      } else if (rr >= 41) {
        conditions.add('Severe tachypnea');
      } else if (rr >= 35) {
        conditions.add('Tachypnea');
      }
    } else if (isCat) {
      if (rr <= 13) {
        conditions.add('Severe bradypnea');
      } else if (rr <= 15) {
        conditions.add('Bradypnea');
      } else if (rr >= 47) {
        conditions.add('Severe tachypnea');
      } else if (rr >= 41) {
        conditions.add('Tachypnea');
      }
    }
  }

  // ======================================================
  // TEMPERATURE
  // ======================================================

  if (temperature != null) {
    if (isDog) {
      if (temperature <= 34) {
        conditions.add('Severe hypothermia');
      } else if (temperature < 37) {
        conditions.add('Hypothermia');
      } else if (temperature >= 42) {
        conditions.add('Severe hyperthermia');
      } else if (temperature >= 40) {
        conditions.add('Fever');
      }
    } else if (isCat) {
      if (temperature <= 35) {
        conditions.add('Severe hypothermia');
      } else if (temperature < 38) {
        conditions.add('Hypothermia');
      } else if (temperature >= 42) {
        conditions.add('Severe hyperthermia');
      } else if (temperature >= 40) {
        conditions.add('Fever');
      }
    }
  }

  // ======================================================
  // SpO2 — SAME FOR DOGS AND CATS
  // ======================================================

  if (spo2 != null) {
    if (spo2 <= 90) {
      conditions.add('Hypoxemia');
    } else if (spo2 <= 94) {
      conditions.add('Low oxygen saturation');
    }
  }

  return conditions;
}






  Widget _buildVitalBox(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),

        ],
      ),
    );
  }




}
/*import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';

import 'monitor_screen2blue.dart';
import 'health_log_screen1.dart';
import 'login_screen1.dart';
import 'patient_list_screen1.dart';
import 'settings_screen.dart';

import '../models/current_user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Text(
                  'Hi, Welcome ${CurrentUser.patientName}!👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MonitorScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Start Monitoring',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthLogScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Health Logs',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),




                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),




                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {

                      // Clear current selected patient
                      CurrentUser.patientId = null;
                      CurrentUser.patientName = '';
                      CurrentUser.age = '';
                      CurrentUser.species = '';
                      CurrentUser.breed = '';
                      CurrentUser.sex = '';
                      CurrentUser.birthDate = '';
                      CurrentUser.color = '';
                      CurrentUser.ownerName = '';
                      CurrentUser.contact = '';
                      CurrentUser.address = '';

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

// add picture big above home 

import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';
import '../database/database_helper.dart';
import '../models/current_user.dart';

import 'monitor_screen2blue.dart';
import 'health_log_screen1.dart';
import 'login_screen1.dart';
import 'patient_list_screen1.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? patientPhotoPath;

  @override
  void initState() {
    super.initState();
    loadPatientPhoto();
  }

  Future<void> loadPatientPhoto() async {
    if (CurrentUser.patientId == null) return;

    final photoPath =
        await DatabaseHelper.instance.getPatientPhoto(
      CurrentUser.patientId!,
    );

    if (mounted) {
      setState(() {
        patientPhotoPath = photoPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ==========================================
                // SELECTED PET PHOTO
                // ==========================================

                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: patientPhotoPath != null &&
                              patientPhotoPath!.isNotEmpty &&
                              File(patientPhotoPath!).existsSync()
                          ? Image.file(
                              File(patientPhotoPath!),
                              width: 142,
                              height: 142,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              CurrentUser.species == 'Canine'
                                  ? 'assets/images/default_dog.jpg'
                                  : 'assets/images/default_cat.jpg',
                              width: 142,
                              height: 142,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // WELCOME MESSAGE
                // ==========================================

                Text(
                  'Hi, Welcome ${CurrentUser.patientName}!👋',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MonitorScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthLogScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Health Logs',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),




                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),




                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Log out?'),

                            content: const Text(
                              'Are you sure you want to log out?',
                            ),

                            actions: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    // YES BUTTON
                                    TextButton(
                                      onPressed: () {

                                        // Clear current selected patient
                                        CurrentUser.patientId = null;
                                        CurrentUser.patientName = '';
                                        CurrentUser.age = '';
                                        CurrentUser.species = '';
                                        CurrentUser.breed = '';
                                        CurrentUser.sex = '';
                                        CurrentUser.birthDate = '';
                                        CurrentUser.color = '';
                                        CurrentUser.ownerName = '';
                                        CurrentUser.contact = '';
                                        CurrentUser.address = '';

                                        Navigator.pop(context);

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },

                                      child: const Text(
                                        'YES',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 55),

                                    // NO BUTTON
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      child: const Text(
                                        'NO',
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';
import '../database/database_helper.dart';
import '../models/current_user.dart';

import 'home_screen1.dart';
import 'add_patient_screen1.dart';
import 'login_screen1.dart';
import 'patient_details_screen.dart';

class PatientListScreen extends StatefulWidget {
    const PatientListScreen({super.key});

    @override
    State<PatientListScreen> createState() => _PatientListScreenState();
  }
class _PatientListScreenState extends State<PatientListScreen> {


  late Future<List<Map<String, dynamic>>> patients;



  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allPatients = [];
  List<Map<String, dynamic>> filteredPatients = [];



  @override
  void initState() {
    super.initState();

    patients = DatabaseHelper.instance.getPatients(userId: CurrentUser.userId!).then((value) {
      allPatients = List<Map<String, dynamic>>.from(value);
      filteredPatients = List<Map<String, dynamic>>.from(value);
      return value;
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text(
                  '📑Patient List',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),




               Center(
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: searchController,
                      onChanged: searchPatient,
                      decoration: InputDecoration(
                        hintText: 'Search patient...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),





                



                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: patients,
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || filteredPatients.isEmpty) {
                        return const Center(
                          child: Text(
                            'No patients registered.',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }

                      /*if (allPatients.isEmpty) { 
                        allPatients = List<Map<String, dynamic>>.from(snapshot.data!);
                        filteredPatients = List<Map<String, dynamic>>.from(snapshot.data!);
                      }*/

                      final patientList = filteredPatients;

                      return ListView.builder(
                        itemCount: patientList.length,
                        itemBuilder: (context, index) {

                          final patient = patientList[index];

                          final bool isMale = patient['sex'] == 'Male';

                          final Color patientButtonColor =
                              isMale
                                  ? const Color(0xFF64B5F6)
                                  : const Color(0xFFF48FB1);

                          final String photoPath =
                              patient['photo_path']?.toString() ?? '';

                          final bool hasPhoto =
                              photoPath.isNotEmpty && File(photoPath).existsSync();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  


                                  Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        width: 420,
                                        height: 80,
                                        child: ElevatedButton(
                                               style: ElevatedButton.styleFrom(
                                                  backgroundColor: patientButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(40),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),

                                        onPressed: () {

                                          CurrentUser.patientId = patient['id'];
                                          CurrentUser.patientName = patient['patient_name'];
                                          CurrentUser.age = patient['age'];
                                          CurrentUser.species = patient['species'];
                                          CurrentUser.breed = patient['breed'];
                                          CurrentUser.sex = patient['sex'];
                                          CurrentUser.birthDate = patient['birth_date'];
                                          CurrentUser.color = patient['color'];
                                          CurrentUser.ownerName = patient['owner_name'];
                                          CurrentUser.contact = patient['contact'];
                                          CurrentUser.address = patient['address'];

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const HomeScreen(),
                                            ),
                                          );

                                        },

                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),

                                        child: Row(
                                          children: [

                                            // ==========================================
                                            // PET PHOTO
                                            // ==========================================

                                            ClipOval(
                                              child: hasPhoto
                                                  ? Image.file(
                                                      File(photoPath),
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      patient['species'] == 'Canine'
                                                          ? 'assets/images/default_dog.jpg'
                                                          : 'assets/images/default_cat.jpg',
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),

                                            const SizedBox(width: 15),

                                            // ==========================================
                                            // PATIENT INFORMATION
                                            // ==========================================

                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Text(
                                                    '${patient['patient_name']}',
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 3),

                                                  Text(
                                                    '${patient['species']} • ${patient['breed']}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),


                                            PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.more_vert,
                                                size: 28,
                                              ),
                                              onSelected: (value) {
                                                if (value == 'view') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PatientDetailsScreen(
                                                        patient: patient,
                                                      ),
                                                    ),
                                                  );
                                                } else if (value == 'edit') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => AddPatientScreen(
                                                          patient: patient,
                                                        ),
                                                      ),
                                                    );
                                                  } else if (value == 'delete') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text('Delete Patient'),
                                                        content: const Text(
                                                          'Are you sure you want to delete this patient?',
                                                        ),
                                                        actions: [
                                                          Center(
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                // YES BUTTON
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    await DatabaseHelper.instance
                                                                        .deletePatient(patient['id']);

                                                                    setState(() {
                                                                      allPatients.removeWhere(
                                                                        (p) => p['id'] == patient['id'],
                                                                      );

                                                                      filteredPatients.removeWhere(
                                                                        (p) => p['id'] == patient['id'],
                                                                      );
                                                                    });

                                                                    Navigator.pop(context);
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
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem<String>(
                                                  value: 'view',
                                                  child: Row(
                                                    children: [
                                                      Icon( Icons.visibility, color: Colors.black, ),
                                                      SizedBox(width: 10),
                                                      Text('View Patient'),
                                                    ],
                                                  ),
                                                ),

                                                const PopupMenuItem<String>(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon( Icons.edit, color: Colors.black, ),
                                                      SizedBox(width: 10),
                                                      Text('Edit Patient'),
                                                    ],
                                                  ),
                                                ),

                                                const PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon( Icons.delete, color: Colors.black, ),
                                                      SizedBox(width: 10),
                                                      Text('Delete Patient'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),



                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ),



                                  /*Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {

                                        CurrentUser.patientId = patient['id'];
                                        CurrentUser.patientName = patient['patient_name'];
                                        CurrentUser.age = patient['age'];
                                        CurrentUser.species = patient['species'];
                                        CurrentUser.breed = patient['breed'];
                                        CurrentUser.sex = patient['sex'];
                                        CurrentUser.birthDate = patient['birth_date'];
                                        CurrentUser.color = patient['color'];
                                        CurrentUser.ownerName = patient['owner_name'];
                                        CurrentUser.contact = patient['contact'];
                                        CurrentUser.address = patient['address'];

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const HomeScreen(),
                                          ),
                                        );

                                      },

                                      child: Text(
                                        '${patient['patient_name']}, ${patient['sex']}',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),   */



/*
                                  const SizedBox(width: 8),

                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Delete Patient'),
                                              content: const Text(
                                                'Are you sure you want to delete this patient?',
                                              ),
                                              actions: [
                                                Center(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [

                                                      // YES BUTTON
                                                      TextButton(
                                                        onPressed: () async {
                                                          await DatabaseHelper.instance.deletePatient(patient['id']);

                                                          setState(() {
                                                            allPatients.removeWhere(
                                                              (p) => p['id'] == patient['id'],
                                                            );

                                                            filteredPatients.removeWhere(
                                                              (p) => p['id'] == patient['id'],
                                                            );
                                                          });

                                                          Navigator.pop(context);
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
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 28,
                                      ),
                                    ),
                                  ),

*/


                                ],
                              ),
                            ),
                          );

                          }, // closes itemBuilder

                          ); // closes ListView.builder

                          }, // closes builder

                          ), // closes FutureBuilder

                          ), // closes Expanded// closes FutureBuilder// closes FutureBuilder







                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {

                      // Check the current number of patients
                      final currentPatients = await patients;

                      if (currentPatients.length >= 50) {

                        // Maximum reached
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Maximum Patients Reached',
                              ),
                              content: const Text(
                                'You have reached the maximum limit of 50 patients. '
                                'Please delete an existing patient before adding a new one.',
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                      } else {

                        // Less than 50 patients
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPatientScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add Patient',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),


                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
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

              ],
            ),
          ),
        ),
      ),
    );
  }



  void searchPatient(String query) {

      setState(() {

        if (query.isEmpty) {

          filteredPatients = allPatients;

        } else {

          filteredPatients = allPatients.where((patient) {

            final name =
                patient['patient_name'].toString().toLowerCase();

            return name.contains(query.toLowerCase());

          }).toList();

        }

      });

    


  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }




}
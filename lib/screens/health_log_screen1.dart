import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../database/database_helper.dart';
import '../models/current_user.dart';

import 'view_log_screen1.dart';
import 'monitor_screen2blue.dart';
import 'settings_screen.dart';



class HealthLogScreen extends StatefulWidget {
  const HealthLogScreen({super.key});

  @override
  State<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends State<HealthLogScreen> {


  final ImagePicker picker = ImagePicker();

  File? selectedImage;



  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  late Future<List<Map<String, dynamic>>> _healthLogs;




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





  
  @override
  void initState() {
    super.initState();

    _healthLogs = DatabaseHelper.instance.getHealthRecords(
      patientId: CurrentUser.patientId!,
    );

    loadPatientPhoto();
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
    final photoPath = await DatabaseHelper.instance.getPatientPhoto(
      CurrentUser.patientId!,
    );

    if (photoPath != null && photoPath.isNotEmpty) {
      final imageFile = File(photoPath);

      if (await imageFile.exists()) {
        setState(() {
          selectedImage = imageFile;
        });
      } else {
        // Photo was deleted from the phone.
        // Revert to the default picture.
        await DatabaseHelper.instance.updatePatientPhoto(
          patientId: CurrentUser.patientId!,
          photoPath: '',
        );

        setState(() {
          selectedImage = null;
        });
      }
    }
  }






  Future<void> verifySelectedImage() async {

    if (selectedImage == null) return;

    final exists = await selectedImage!.exists();

    if (!exists) {

      await DatabaseHelper.instance.updatePatientPhoto(
        patientId: CurrentUser.patientId!,
        photoPath: '',
      );

      if (mounted) {
        setState(() {
          selectedImage = null;
        });
      }
    }

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

                  const Text(
                    "Weight : 18 kg",
                    style: TextStyle(fontSize: 18),
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
                      onPressed: () async {
                        await verifySelectedImage();
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),

                    // Health Logs - Center
                    Expanded(
                      child: Center(
                        child: const Text(
                          '📋Health Logs',
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




                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 36,
                        color: Color.fromARGB(255, 6, 0, 0),
                      ),
                      onPressed: () async {

                        await verifySelectedImage();

                        _scaffoldKey.currentState?.openDrawer();

                      },
                    ),



                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        size: 36,
                        color: Color.fromARGB(255, 5, 2, 2),
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

                const SizedBox(height: 10),
                

                const Text(
                  '📋Health Logs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20), */




                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _healthLogs,
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(fontSize: 22),
                          ),
                        );
                      }

                      final logs = snapshot.data!;

                      return ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {

                          final record = logs[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildLogTile(
                              context,
                              record,
                            ),
                          );

                        },
                      );

                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Monitoring',style: TextStyle(fontSize: 24),
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

  Widget _buildLogTile( BuildContext context,Map<String, dynamic> record,) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLogScreen(
              recordId: record['id'],
            ),
          ),
        );
      },

      borderRadius: BorderRadius.circular(10),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Row(
          
        children: [

          Expanded(
            child: Text(
              '${record['date']} ${record['time']}\n'
              'BPM: ${record['bpm']}, '
              'SpO₂: ${record['spo2']}%',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),

          PopupMenuButton<String>(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            onSelected: (value) async {

              if (value == 'view') {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewLogScreen(
                      recordId: record['id'],
                    ),
                  ),
                );

              } else if (value == 'delete') {

                // DELETE CONFIRMATION
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Health Log'),
                      content: const Text(
                        'Are you sure you want to delete this health log?',
                      ),
                      actions: [
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // YES
                              TextButton(
                                onPressed: () async {

                                  await DatabaseHelper.instance
                                      .deleteHealthRecord(record['id']);

                                  if (mounted) {
                                    setState(() {
                                      _healthLogs =
                                          DatabaseHelper.instance.getHealthRecords(
                                        patientId: CurrentUser.patientId!,
                                      );
                                    });
                                  }

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

                              // NO
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

              // VIEW
              const PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text('View'),
                  ],
                ),
              ),

              // DELETE
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),

            ],
          ),

        ],
      ),
    ),
    );
  }
}
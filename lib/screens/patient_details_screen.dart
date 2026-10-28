import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/background_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final String photoPath =
        patient['photo_path']?.toString() ?? '';

    final bool hasPhoto =
        photoPath.isNotEmpty && File(photoPath).existsSync();

    return Scaffold(
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [

                // ==========================================
                // TITLE
                // ==========================================

                const Text(
                  '🐾 Patient Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================
                // PATIENT PHOTO
                // ==========================================

                ClipOval(
                  child: hasPhoto
                      ? Image.file(
                          File(photoPath),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          patient['species'] == 'Canine'
                              ? 'assets/images/default_dog.jpg'
                              : 'assets/images/default_cat.jpg',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // PATIENT NAME
                // ==========================================

                Text(
                  patient['patient_name']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // PATIENT INFORMATION
                // ==========================================

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        _infoRow(
                          'Species',
                          patient['species'],
                        ),

                        _infoRow(
                          'Breed',
                          patient['breed'],
                        ),

                        _infoRow(
                          'Sex',
                          patient['sex'],
                        ),

                        _infoRow(
                          'Birth Date',
                          patient['birth_date'],
                        ),

                        _infoRow(
                          'Age',
                          patient['age'],
                        ),

                        _infoRow(
                          'Color',
                          patient['color'],
                        ),

                        const SizedBox(height: 15),

                        const Divider(),

                        const SizedBox(height: 15),

                        _infoRow(
                          'Owner Name',
                          patient['owner_name'],
                        ),

                        _infoRow(
                          'Contact',
                          patient['contact'],
                        ),

                        _infoRow(
                          'Address',
                          patient['address'],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==========================================
                // BACK BUTTON
                // ==========================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 24,
                      ),
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

  // ==========================================
  // INFORMATION ROW
  // ==========================================

  static Widget _infoRow(
    String label,
    dynamic value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../widgets/background_screen.dart';
import '../database/database_helper.dart';
import '../models/current_user.dart';

import 'patient_list_screen1.dart';


class AddPatientScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const AddPatientScreen({
    super.key,
    this.patient,
  });

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {



  final patientNameController = TextEditingController();
  //final ageController = TextEditingController();
  //final breedController = TextEditingController();
  final colorController = TextEditingController();
  final ownerNameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;


  int? calculatedAge;

  bool contactFieldFocused = false;
  bool patientNameFieldFocused = false;
  bool ownerNameFieldFocused = false;
  bool addressFieldFocused = false;

  String? selectedSpecies;
  String? selectedBreed;
  String? selectedSex;
  String? selectedSize;
  String? selectedColor;

  DateTime? selectedDate;


  final List<String> colorOptions = [
    'Black',
    'White',
    'Brown',
    'Gray',
    'Cream',
    'Orange',
    'Black & White',
    'Brown & White',
    'Mixed',
  ];

  final List<String> breedOptions = [
    'Shih Tzu',
    'Aspin',
  ];



  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }



  @override
  void initState() {
    super.initState();

    final patient = widget.patient;

    // Always use Canine for new and existing patients.
    selectedSpecies = 'Canine';

    // ==========================================
    // EDIT MODE
    // ==========================================

    if (patient != null) {
      patientNameController.text =
          patient['patient_name']?.toString() ?? '';

      ownerNameController.text =
          patient['owner_name']?.toString() ?? '';

      contactController.text =
          patient['contact']?.toString() ?? '';

      addressController.text =
          patient['address']?.toString() ?? '';


      /*
      selectedSpecies =
          patient['species']?.toString(); */



      selectedBreed =
          patient['breed']?.toString();

      selectedSize =
          patient['size']?.toString();

      selectedSex =
          patient['sex']?.toString();

      selectedColor =
          patient['color']?.toString();

      // Convert saved birth date:
      // "day/month/year" → DateTime
      final birthDate = patient['birth_date']?.toString();

      if (birthDate != null && birthDate.isNotEmpty) {
        final parts = birthDate.split('/');

        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (day != null && month != null && year != null) {
            selectedDate = DateTime(
              year,
              month,
              day,
            );

            calculatedAge = calculateAge(selectedDate!);
          }
        }
      }
    }
  }




  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
    );

    if (image != null) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [

                Text(
                  widget.patient == null
                      ? '📝 Add Patient'
                      : '✏️ Edit Patient',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        TextField(
                          controller: patientNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s'-]"),
                            ),
                          ],
                          onTap: () {
                            setState(() {
                              patientNameFieldFocused = true;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: patientNameFieldFocused ? 'Patient Name' : null,
                            hintText: patientNameFieldFocused ? null : 'Patient Name',
                      
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 1),

                        

                        SizedBox(height: 15),

                        TextFormField(
                          initialValue: 'Canine',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Species',
                            border: OutlineInputBorder(),
                          ),
                        ),


                        /*
                        DropdownButtonFormField<String>(
                          value: selectedSpecies,
                          decoration: const InputDecoration(
                            hintText: 'Select Species',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Canine',
                              child: Text('Canine'),
                            ),
                            /*
                            DropdownMenuItem(
                              value: 'Feline',
                              child: Text('Feline'),
                            ),  */
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSpecies = value;

                              // Reset breed whenever species changes
                              selectedBreed = null;
                            });
                          },
                        ),  */

                        SizedBox(height: 15),

                        /*TextField(
                          controller: breedController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s'-]"),
                            ),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Breed',
                            border: OutlineInputBorder(),
                          ),
                        ),*/

                        
                          const SizedBox(height: 1),



                          Autocomplete<String>(
                            initialValue: TextEditingValue(
                              text: selectedBreed ?? '',
                            ),

                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return breedOptions;
                              }

                              return breedOptions.where(
                                (breed) => breed.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                ),
                              );
                            },

                            onSelected: (String selection) {
                              setState(() {
                                selectedBreed = selection;
                              });
                            },

                            fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController controller,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,

                                onChanged: (value) {
                                  setState(() {
                                    selectedBreed = value.trim().isEmpty
                                        ? null
                                        : value.trim();
                                  });
                                },

                                decoration: const InputDecoration(
                                  labelText: 'Breed',
                                  hintText: 'Please specify if answered "other"',
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),



                          /*

                          if (selectedSpecies != null) ...[
  

                            DropdownButtonFormField<String>(
                              value: selectedBreed,
                              decoration: const InputDecoration(
                                hintText: 'Select Breed',
                                border: OutlineInputBorder(),
                              ),
                              
                             items: const [
                                DropdownMenuItem(
                                  value: 'Shih Tzu',
                                  child: Text('Shih Tzu'),
                                ),
                                DropdownMenuItem(
                                  value: 'Bulldog',
                                  child: Text('Bulldog'),
                                ),
                                DropdownMenuItem(
                                  value: 'Pomeranian',
                                  child: Text('Pomeranian'),
                                ), 
                              ],
   
                              onChanged: (value) {
                                setState(() {
                                  selectedBreed = value;
                                });
                              },
                            ),
                          ],   */



                        SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          value: selectedSize,
                          decoration: const InputDecoration(
                            hintText: 'Select Size',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'Large',
                              child: Text('Large'),
                            ),
                           
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSize = value;
                            });
                          },
                        ),




                        SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          value: selectedSex,
                          decoration: const InputDecoration(
                            hintText: 'Select Sex',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSex = value;
                            });
                          },
                        ),

                        SizedBox(height: 15),

                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: selectedDate == null
                                ? 'Select Date of Birth'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                                calculatedAge = calculateAge(pickedDate);
                              });
                            }
                          },
                        ),

                        SizedBox(height: 15),



                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: selectedColor ?? '',
                          ),

                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return colorOptions;
                            }

                            return colorOptions.where(
                              (color) => color.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },

                          onSelected: (String selection) {
                            setState(() {
                              selectedColor = selection;
                            });
                          },

                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController controller,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,

                              onChanged: (value) {
                                setState(() {
                                  selectedColor = value.trim().isEmpty
                                      ? null
                                      : value.trim();
                                });
                              },

                              decoration: const InputDecoration(
                                labelText: 'Color / Markings',
                                hintText: 'Select or type color / markings',
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),



                      /*

                        DropdownButtonFormField<String>(
                          value: selectedColor,
                          decoration: const InputDecoration(
                            hintText: 'Select Color / Markings',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Black',
                              child: Text('Black'),
                            ),
                            DropdownMenuItem(
                              value: 'White',
                              child: Text('White'),
                            ),
                            DropdownMenuItem(
                              value: 'Brown',
                              child: Text('Brown'),
                            ),
                            DropdownMenuItem(
                              value: 'Gray',
                              child: Text('Gray'),
                            ),
                            DropdownMenuItem(
                              value: 'Cream',
                              child: Text('Cream'),
                            ),
                            DropdownMenuItem(
                              value: 'Orange',
                              child: Text('Orange'),
                            ),
                            DropdownMenuItem(
                              value: 'Black & White',
                              child: Text('Black & White'),
                            ),
                            DropdownMenuItem(
                              value: 'Brown & White',
                              child: Text('Brown & White'),
                            ),
                            DropdownMenuItem(
                              value: 'Mixed',
                              child: Text('Mixed'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedColor = value;
                            });
                          },
                        ),     */

                        SizedBox(height: 15),



                        SizedBox(
                          width: 181,
                          height: 39,
                          child: ElevatedButton.icon(
                            onPressed: showImagePicker,
                            icon: const Icon(Icons.add_a_photo),
                            label: Text(
                              selectedImage == null
                                  ? 'Add Photo'
                                  : 'Change Photo',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),


                        if (selectedImage != null) ...[
                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              selectedImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],

                        const SizedBox(height: 15),




                        TextField(
                          controller: ownerNameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s'-]"),
                            ),
                          ],
                          onTap: () {
                            setState(() {
                              ownerNameFieldFocused = true;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: ownerNameFieldFocused ? 'Owner Name' : null,
                            hintText: ownerNameFieldFocused ? null : 'Owner Name',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        SizedBox(height: 15),


                        /*
                        
                        TextField(
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Contact No. of Owner',
                            border: OutlineInputBorder(),
                          ),
                        ),  */



                        TextField(
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          onTap: () {
                            setState(() {
                              contactFieldFocused = true;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: contactFieldFocused
                                ? 'Contact No. of Owner'
                                : null,
                            hintText: contactFieldFocused
                                ? '09#########'
                                : 'Contact No. of Owner',
                            border: const OutlineInputBorder(),
                          ),
                        ),




                        SizedBox(height: 15),

                        TextField(
                          controller: addressController,
                          maxLines: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z0-9\s,./#()-]"),
                            ),
                          ],
                          onTap: () {
                            setState(() {
                              addressFieldFocused = true;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: addressFieldFocused ? 'Home Address' : null,
                            hintText: addressFieldFocused ? null : 'Home Address',
                            border: const OutlineInputBorder(),
                          ),
                        ),



                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {

                      if (patientNameController.text.trim().isEmpty ||
                          //ageController.text.trim().isEmpty ||
                          selectedSpecies == null ||
                          selectedBreed == null ||
                          selectedSize == null ||
                          selectedSex == null ||
                          selectedDate == null ||
                          selectedColor == null ||
                          ownerNameController.text.trim().isEmpty ||
                          contactController.text.trim().isEmpty ||
                          addressController.text.trim().isEmpty) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete all patient information.',
                            ),
                          ),
                        );

                        return;
                      }

                      if (widget.patient == null) {
                        // ==========================================
                        // ADD MODE
                        // ==========================================

                        await DatabaseHelper.instance.insertPatient(
                          userId: CurrentUser.userId!,
                          patientName: patientNameController.text.trim(),
                          age: calculatedAge.toString(),
                          species: selectedSpecies!,
                          breed: selectedBreed!,
                          size: selectedSize!,
                          sex: selectedSex!,
                          birthDate:
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          color: selectedColor!,
                          ownerName: ownerNameController.text.trim(),
                          contact: contactController.text.trim(),
                          address: addressController.text.trim(),
                          photoPath: selectedImage?.path ?? '',
                        );
                      } else {
                        // ==========================================
                        // EDIT MODE
                        // ==========================================

                        final existingPhotoPath =
                            widget.patient!['photo_path']?.toString() ?? '';

                        await DatabaseHelper.instance.updatePatient(
                          patientId: widget.patient!['id'],
                          patientName: patientNameController.text.trim(),
                          age: calculatedAge.toString(),
                          species: selectedSpecies!,
                          breed: selectedBreed!,
                          size: selectedSize!,
                          sex: selectedSex!,
                          birthDate:
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          color: selectedColor!,
                          ownerName: ownerNameController.text.trim(),
                          contact: contactController.text.trim(),
                          address: addressController.text.trim(),
                          photoPath: selectedImage?.path ?? existingPhotoPath,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.patient == null
                                ? "Patient successfully registered!"
                                : "Patient successfully updated!",
                          ),
                        ),
                      );

                      // 👇 Change ONLY this line
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      widget.patient == null
                          ? 'Add Patient'
                          : 'Save Changes',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientListScreen(),
                        ),
                      );
                    },
                    child: const Text('Back',style: TextStyle(fontSize: 24),),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    patientNameController.dispose();
    //ageController.dispose();
    //breedController.dispose();
    //colorController.dispose();
    ownerNameController.dispose();
    contactController.dispose();
    addressController.dispose();

    super.dispose();
  }


}
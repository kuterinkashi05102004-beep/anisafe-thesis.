import 'package:flutter/material.dart';
import '../widgets/background_screen.dart';
import '../database/database_helper.dart';
import 'login_screen1.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {


  final TextEditingController fullNameController =
    TextEditingController();

  final TextEditingController ageController =
    TextEditingController();

  final TextEditingController usernameController =
    TextEditingController();

  final TextEditingController passwordController =
    TextEditingController();

  final TextEditingController confirmPasswordController =
    TextEditingController();

  String? selectedGender;


  bool hidePassword = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundScreen(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [

                const SizedBox(height: 150),

               

                Column(
                  
                  children: [
                     const Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        hintText: 'Gender',
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
                          selectedGender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: hidePassword,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),


                const SizedBox(height: 10),

                Row(
                  children: [

                    Checkbox(
                      value: !hidePassword,
                      onChanged: (value) {
                        setState(() {
                          hidePassword = !(value ?? false);
                        });
                      },
                    ),

                    const Text("Show Password"),

                  ],
                ),


                const SizedBox(height: 30),

                SizedBox(
                  width: 200, //  size button
                  height: 50,
                  child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                    onPressed: () async {

                      
                      String fullName = fullNameController.text.trim();
                      String gender = selectedGender ?? '';
                      String ageText = ageController.text.trim();
                      String username = usernameController.text.trim();
                      String password = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      int? age = int.tryParse(ageText);

                      if (
                        fullName.isEmpty ||
                        gender.isEmpty ||
                        ageText.isEmpty ||
                        username.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty
                      ) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill in all fields.',
                            ),
                          ),
                        );

                        return;
                      }


                      if (age == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a number for age.',
                            ),
                          ),
                        );

                        return;
                      }



                      if (password != confirmPassword) {   // ito daw yung error 

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Passwords do not match.',
                            ),
                          ),
                        );

                        return;
                      }

                      
                      print(username);
                      print(password);

                      try {

                        await DatabaseHelper.instance.insertUser(
                          fullName: fullName,
                          gender: gender,
                          age: age!,
                          username: username,
                          password: password,
                        );

                        print('User successfully saved.');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Account created successfully.',
                            ),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );

                      } catch (e) {

                          print("SIGNUP ERROR: $e");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString(),
                              ),
                            ),
                          );

                        }

                    },

                    child: const Text('Create Account'),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel Create'),
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
   
  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
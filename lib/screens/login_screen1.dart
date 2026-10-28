  import 'package:flutter/material.dart';
  import '../widgets/background_screen.dart';
  import '../database/database_helper.dart';
  import '../models/current_user.dart';
  import 'signup_screen1.dart';
  import 'patient_list_screen1.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {

    final TextEditingController usernameController =
        TextEditingController();

    final TextEditingController passwordController =
        TextEditingController();

    final FocusNode passwordFocusNode = FocusNode();

    bool hidePassword = true;

    bool usernameFieldFocused = false;
    bool passwordFieldFocused = false;



    Future<void> login() async {

      String username = usernameController.text;
      String password = passwordController.text;

      if (username.isEmpty || password.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter both username and password.',
            ),
          ),
        );

        return;
      }

      final user = await DatabaseHelper.instance.loginUser(
        username: username,
        password: password,
      );


      if (user != null) {

        // ==========================
        // Save Logged-in User
        // ==========================

        CurrentUser.userId = user['id'];
        CurrentUser.username = user['username'];
        CurrentUser.fullName = user['full_name'];
        CurrentUser.gender = user['gender'];
        CurrentUser.userAge = user['age'];

        print('Login successful');
        print('User ID: ${CurrentUser.userId}');
        print('Username: ${CurrentUser.username}');
        print('Full Name: ${CurrentUser.fullName}');
        print('Gender: ${CurrentUser.gender}');
        print('Age: ${CurrentUser.userAge}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PatientListScreen(),
          ),
        );

      } else {

        print('Invalid username or password');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Incorrect username or password.',
            ),
          ),
        );
      }
    }






    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: BackgroundScreen(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [

                    // ==========================================
                    // AniSafe Logo
                    // ==========================================
                    Image.asset(
                      'assets/icon/Anisafe_logo_nBg.png',
                      width: 400,
                      height: 200,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 10),

                    // ==========================================
                    // Login Title
                    // ==========================================
                    const Text(
                      "Let's keep your pet safe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==========================================
                    // Username
                    // ==========================================
                    TextField(
                      controller: usernameController,

                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(passwordFocusNode);
                      },

                      onTap: () {
                        setState(() {
                          usernameFieldFocused = true;
                        });
                      },

                      decoration: InputDecoration(
                        labelText:
                            usernameFieldFocused ? 'Username' : null,
                        hintText:
                            usernameFieldFocused ? null : 'Username',
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,

                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        login();
                      },

                      onTap: () {
                        setState(() {
                          passwordFieldFocused = true;
                        });
                      },

                      decoration: InputDecoration(
                        labelText:
                            passwordFieldFocused ? 'Password' : null,
                        hintText:
                            passwordFieldFocused ? null : 'Password',
                        border: const OutlineInputBorder(),
                      ),
                    ),

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
                      width: double.infinity,
                      height: 70,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 8,
                            top: 8,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 0,
                            top: 0,
                            right: 8,
                            bottom: 8,
                            child: ElevatedButton(
                              onPressed: () {
                                login();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(
                                  255,
                                  58,
                                  162,
                                  13,
                                ),
                                foregroundColor:
                                    const Color.fromARGB(
                                  255,
                                  218,
                                  214,
                                  214,
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
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








    /*
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: BackgroundScreen(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                        children: [

                              // ==========================================
                              // AniSafe Logo
                              // ==========================================
                              Image.asset(
                                'assets/icon/Anisafe_logo_nBg.png',
                                width: 400,
                                height: 200,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 10),

                              // ==========================================
                              // Login Title
                              // ==========================================
                              const Text(
                              "Let's keep your pet safe",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ==========================================
                            // Username
                            // ==========================================
                            TextField(
                              controller: usernameController,

                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                FocusScope.of(context).requestFocus(passwordFocusNode);
                              },

                              onTap: () {
                                setState(() {
                                  usernameFieldFocused = true;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: usernameFieldFocused ? 'Username' : null,
                                hintText: usernameFieldFocused ? null : 'Username',
                                border: const OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextField(
                              controller: passwordController,
                              obscureText: hidePassword,

                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                login();
                              },

                              onTap: () {
                                setState(() {
                                  passwordFieldFocused = true;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: passwordFieldFocused ? 'Password' : null,
                                hintText: passwordFieldFocused ? null : 'Password',
                                border: const OutlineInputBorder(),
                              ),
                            ),

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
                              width: double.infinity,
                              height: 70,
                              child: Stack(
                                children: [
                                  // ==========================================
                                  // Black Back Layer / Shadow
                                  // ==========================================
                                  Positioned(
                                    left: 8,
                                    top: 8,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),

                                  // ==========================================
                                  // Purple Login Button
                                  // ==========================================
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 8,
                                    bottom: 8,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        login();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 58, 162, 13),
                                        foregroundColor: const Color.fromARGB(255, 218, 214, 214),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          side: const BorderSide(
                                            color: Colors.black,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /*
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {

                                  String username = usernameController.text;
                                  String password = passwordController.text;

                                  if (username.isEmpty || password.isEmpty) {

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter both username and password.'),
                                      ),
                                    );

                                    return;
                                  }

                                  final user = await DatabaseHelper.instance.loginUser(
                                    username: username,
                                    password: password,
                                  );

                                  if (user != null) { 

                                    // ==========================
                                    // Save Logged-in Doctor
                                    // ==========================

                                    CurrentUser.userId = user['id'];
                                    CurrentUser.username = user['username'];
                                    

                                    print('Login successful');
                                    print('Doctor ID: ${CurrentUser.userId}');
                                    print('Username: ${CurrentUser.username}');


                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PatientListScreen(),
                                      ),
                                    );

                                  } else {

                                      print('Invalid username or password');

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Incorrect username or password.',
                                          ),
                                        ),
                                      );

                                    }
                                    

                                },
                                child: const Text('Login'),
                              ),
                            ),

                            */

                            const SizedBox(height: 15),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                          ],
                      ),
            ),
          ),
        ),
      );
    }  */


    @override
    void dispose() {
      usernameController.dispose();
      passwordController.dispose();
      passwordFocusNode.dispose();
      super.dispose();
    }
  }
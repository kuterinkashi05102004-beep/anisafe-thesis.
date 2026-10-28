import 'dart:async';

import 'package:flutter/material.dart';

import '../bluetooth/ble_manager.dart';

import '../widgets/background_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Timer? timer;


  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }


  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
                  "Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Status: ${BleManager.instance.connectionStatus}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: ()async {

                      await BleManager.instance.scan();


                    },
                    child: const Text(
                      "Scan for Devices",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back",
                      style: TextStyle(fontSize: 22),
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
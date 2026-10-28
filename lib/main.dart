import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme/app_theme.dart';
import 'rf_model_test.dart';
import 'services/rf_prediction_service.dart';
import 'services/notification_service.dart';
//import 'bluetooth/ble_manager.dart';

//import 'screens/settings_screen.dart';
import 'screens/login_screen1.dart';
//import 'screens/signup_screen1.dart'
//import 'screens/patient_list_screen1.dart';
//import 'screens/add_patient_screen1.dart';
//import 'screens/home_screen1.dart';
//import 'screens/monitor_screen1.dart';
//import 'screens/health_log_screen1.dart';
//import 'screens/view_log_screen1.dart';





Future<void> testRfPredictionService() async {
  print('================================');
  print('TESTING RF PREDICTION SERVICE');
  print('================================');

  final rfService = RfPredictionService();

  final result = await rfService.predict(
    species: 'Canine',
    ageGroup: 'Adult',
    bpm: 90.0,
    spo2: 98.0,
    temperature: 38.5,
    respiratoryRate: 25.0,
  );

  print('================================');
  print('SERVICE TEST RESULT');
  print('================================');

  print('Finding: ${result.finding}');
  print(
    'Abnormal: '
    '${(result.abnormalProbability * 100).toStringAsFixed(2)}%',
  );
  print(
    'Normal: '
    '${(result.normalProbability * 100).toStringAsFixed(2)}%',
  );
  print(
    'Warning: '
    '${(result.warningProbability * 100).toStringAsFixed(2)}%',
  );

  await rfService.dispose();

  print('================================');
  print('RF SERVICE TEST COMPLETE');
  print('================================');
}




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await testAniSafeRandomForest();
  await testRfPredictionService();

   // STEP 15
  //await BleManager.instance.autoReconnect();

  await NotificationService.instance.initialize();

  runApp(const PetMonitorApp());
}

class PetMonitorApp extends StatelessWidget {
  const PetMonitorApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Monitoring System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      //home: const SettingsScreen(),
      home: const LoginScreen(),
      //home: const SignUpScreen (),
      //home: const PatientListScreen(),
      //home: const AddPatientScreen(),
      //home: const HomeScreen(),
      //home: const MonitorScreen(),
      //home: const HealthLogScreen(),
      //home: const ViewLogScreen(),
      

    );
  }
}

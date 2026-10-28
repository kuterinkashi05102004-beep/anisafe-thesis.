import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

Future<void> testAniSafeRandomForest() async {
  print('================================');
  print('ANISAFE ONNX RF TEST');
  print('================================');

  final ort = OnnxRuntime();

  print('Loading ONNX model...');

  final session = await ort.createSessionFromAsset(
    'assets/Models/anisafe_random_forest_mobile_nozipmap.onnx',
  );

  print('ONNX model loaded successfully.');

  print('Input names: ${session.inputNames}');
  print('Output names: ${session.outputNames}');

  // Test patient:
  // Canine / Adult
  // BPM 90
  // SpO2 98
  // Temperature 38.5
  // Respiratory Rate 25
  //
  // This is the same test input we already tested
  // successfully against the protected Python .joblib model.

  final inputs = {
    'Species': await OrtValue.fromList(
      ['Canine'],
      [1, 1],
    ),

    'Age_Group': await OrtValue.fromList(
      ['Adult'],
      [1, 1],
    ),

    'BPM': await OrtValue.fromList(
      [90.0],
      [1, 1],
    ),

    'SpO2': await OrtValue.fromList(
      [98.0],
      [1, 1],
    ),

    'Temperature': await OrtValue.fromList(
      [38.5],
      [1, 1],
    ),

    'Respiratory_Rate': await OrtValue.fromList(
      [25.0],
      [1, 1],
    ),
  };

  print('Running RF inference...');

  final outputs = await session.run(inputs);

  print('Inference completed.');

  print('Raw outputs:');

  for (final entry in outputs.entries) {
    print('${entry.key}: ${await entry.value.asList()}');
  }

  // Clean up input tensors.
  for (final tensor in inputs.values) {
    tensor.dispose();
  }

  // Clean up output tensors.
  for (final tensor in outputs.values) {
    tensor.dispose();
  }

  await session.close();

  print('================================');
  print('ANISAFE ONNX RF TEST COMPLETE');
  print('================================');
}
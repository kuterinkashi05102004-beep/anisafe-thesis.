import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

class RfPredictionResult {
  final String finding;
  final double abnormalProbability;
  final double normalProbability;
  final double warningProbability;

  RfPredictionResult({
    required this.finding,
    required this.abnormalProbability,
    required this.normalProbability,
    required this.warningProbability,
  });
}

class RfPredictionService {
  static const String modelPath =
      'assets/Models/anisafe_random_forest_mobile_nozipmap.onnx';

  final OnnxRuntime _ort = OnnxRuntime();

  OrtSession? _session;

  Future<void> initialize() async {
    if (_session != null) {
      return;
    }

    print('================================');
    print('ANISAFE RF SERVICE');
    print('Loading ONNX RF model...');
    print('================================');

    _session = await _ort.createSessionFromAsset(modelPath);

    print('ONNX RF model loaded successfully.');
    print('Input names: ${_session!.inputNames}');
    print('Output names: ${_session!.outputNames}');
  }

  Future<RfPredictionResult> predict({
    required String species,
    required String ageGroup,
    required double bpm,
    required double spo2,
    required double temperature,
    required double respiratoryRate,
  }) async {
    await initialize();

    final inputs = {
      'Species': await OrtValue.fromList(
        [species],
        [1, 1],
      ),

      'Age_Group': await OrtValue.fromList(
        [ageGroup],
        [1, 1],
      ),

      'BPM': await OrtValue.fromList(
        [bpm],
        [1, 1],
      ),

      'SpO2': await OrtValue.fromList(
        [spo2],
        [1, 1],
      ),

      'Temperature': await OrtValue.fromList(
        [temperature],
        [1, 1],
      ),

      'Respiratory_Rate': await OrtValue.fromList(
        [respiratoryRate],
        [1, 1],
      ),
    };

    print('================================');
    print('ANISAFE RF INFERENCE');
    print('================================');

    print('Species: $species');
    print('Age Group: $ageGroup');
    print('BPM: $bpm');
    print('SpO2: $spo2');
    print('Temperature: $temperature');
    print('Respiratory Rate: $respiratoryRate');

    print('Running RF inference...');

    final outputs = await _session!.run(inputs);

    print('RF inference completed.');

    final labelOutput = await outputs['label']!.asList();
    final probabilityOutput =
        await outputs['probabilities']!.asList();

    print('RF label output: $labelOutput');
    print('RF probability output: $probabilityOutput');

    final finding = labelOutput.first.toString();

    final probabilities =
        (probabilityOutput.first as List).cast<num>();

    /*
      IMPORTANT:
      The protected Random Forest classes are ordered:

      0 = Abnormal
      1 = Normal
      2 = Warning
    */

    final abnormalProbability =
        probabilities[0].toDouble();

    final normalProbability =
        probabilities[1].toDouble();

    final warningProbability =
        probabilities[2].toDouble();

    for (final tensor in inputs.values) {
      tensor.dispose();
    }

    for (final tensor in outputs.values) {
      tensor.dispose();
    }

    print('RF Finding: $finding');
    print(
      'Abnormal: ${(abnormalProbability * 100).toStringAsFixed(2)}%',
    );
    print(
      'Normal: ${(normalProbability * 100).toStringAsFixed(2)}%',
    );
    print(
      'Warning: ${(warningProbability * 100).toStringAsFixed(2)}%',
    );

    print('================================');

    return RfPredictionResult(
      finding: finding,
      abnormalProbability: abnormalProbability,
      normalProbability: normalProbability,
      warningProbability: warningProbability,
    );
  }

  Future<void> dispose() async {
    if (_session != null) {
      await _session!.close();
      _session = null;
    }
  }
}
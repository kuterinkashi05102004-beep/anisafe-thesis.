import 'package:flutter_test/flutter_test.dart';

import '../lib/algorithm/baseline.dart';
import '../lib/algorithm/vital_classifier.dart';

void main() {
  group('AniSafe Vital Classifier Tests', () {
    final canineBaseline = BaselineSelector.getBaseline(
      species: 'Canine',
      age: 5,
    );

    final felineBaseline = BaselineSelector.getBaseline(
      species: 'Feline',
      age: 5,
    );

    // ==================================================
    // BPM TESTS
    // ==================================================

    test('Canine BPM below normal should be Bradycardia', () {
      final result = VitalClassifier.classifyBpm(
        60,
        canineBaseline,
      );

      expect(result, 'Bradycardia');
    });

    test('Canine normal BPM should be Normal', () {
      final result = VitalClassifier.classifyBpm(
        100,
        canineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Canine BPM above normal should be Tachycardia', () {
      final result = VitalClassifier.classifyBpm(
        130,
        canineBaseline,
      );

      expect(result, 'Tachycardia');
    });

    test('Feline BPM below normal should be Bradycardia', () {
      final result = VitalClassifier.classifyBpm(
        100,
        felineBaseline,
      );

      expect(result, 'Bradycardia');
    });

    test('Feline normal BPM should be Normal', () {
      final result = VitalClassifier.classifyBpm(
        130,
        felineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Feline BPM above normal should be Tachycardia', () {
      final result = VitalClassifier.classifyBpm(
        150,
        felineBaseline,
      );

      expect(result, 'Tachycardia');
    });

    // ==================================================
    // RESPIRATORY RATE TESTS
    // ==================================================

    test('Canine RR below normal should be Bradypnea', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        15,
        canineBaseline,
      );

      expect(result, 'Bradypnea');
    });

    test('Canine normal RR should be Normal', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        25,
        canineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Canine RR above normal should be Tachypnea', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        40,
        canineBaseline,
      );

      expect(result, 'Tachypnea');
    });

    test('Feline RR below normal should be Bradypnea', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        10,
        felineBaseline,
      );

      expect(result, 'Bradypnea');
    });

    test('Feline normal RR should be Normal', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        25,
        felineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Feline RR above normal should be Tachypnea', () {
      final result = VitalClassifier.classifyRespiratoryRate(
        45,
        felineBaseline,
      );

      expect(result, 'Tachypnea');
    });

    // ==================================================
    // TEMPERATURE TESTS
    // ==================================================

    test('Canine low temperature should be Hypothermia', () {
      final result = VitalClassifier.classifyTemperature(
        37.0,
        canineBaseline,
      );

      expect(result, 'Hypothermia');
    });

    test('Canine normal temperature should be Normal', () {
      final result = VitalClassifier.classifyTemperature(
        38.5,
        canineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Canine high temperature should be Fever/Hyperthermia', () {
      final result = VitalClassifier.classifyTemperature(
        39.5,
        canineBaseline,
      );

      expect(result, 'Fever/Hyperthermia');
    });

    test('Feline low temperature should be Hypothermia', () {
      final result = VitalClassifier.classifyTemperature(
        37.5,
        felineBaseline,
      );

      expect(result, 'Hypothermia');
    });

    test('Feline normal temperature should be Normal', () {
      final result = VitalClassifier.classifyTemperature(
        38.5,
        felineBaseline,
      );

      expect(result, 'Normal');
    });

    test('Feline high temperature should be Fever/Hyperthermia', () {
      final result = VitalClassifier.classifyTemperature(
        39.5,
        felineBaseline,
      );

      expect(result, 'Fever/Hyperthermia');
    });

    // ==================================================
    // SpO₂ TESTS
    // ==================================================

    test('Low SpO₂ should be Hypoxemia', () {
      final result = VitalClassifier.classifySpo2(
        90,
        felineBaseline,
      );

      expect(result, 'Hypoxemia');
    });

    test('Normal SpO₂ should be Normal', () {
      final result = VitalClassifier.classifySpo2(
        98,
        felineBaseline,
      );

      expect(result, 'Normal');
    });

    test('SpO₂ above 100 should be Invalid/Review', () {
      final result = VitalClassifier.classifySpo2(
        101,
        felineBaseline,
      );

      expect(result, 'Invalid/Review');
    });
  });
}
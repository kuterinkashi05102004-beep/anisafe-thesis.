import 'package:flutter_test/flutter_test.dart';

import 'package:anisafe/algorithm/live_vital_data.dart';
import 'package:anisafe/models/current_user.dart';

void main() {
  group('Live Vital Data Tests', () {
    setUp(() {
      CurrentUser.patientId = 1;
      CurrentUser.patientName = 'Test Cat';
      CurrentUser.species = 'Feline';
      CurrentUser.age = '5';
    });

    test('Selected patient baseline should be Feline Adult', () {
      final baseline = LiveVitalData.getPatientBaseline();

      expect(baseline.species, 'Feline');
      expect(baseline.ageGroup.name, 'adult');
    });

    test('Feline Adult BPM baseline should be 120-140', () {
      final baseline = LiveVitalData.getPatientBaseline();

      expect(baseline.bpmMin, 120);
      expect(baseline.bpmMax, 140);
    });

    test('Feline Adult RR baseline should be 16-40', () {
      final baseline = LiveVitalData.getPatientBaseline();

      expect(baseline.respiratoryRateMin, 16);
      expect(baseline.respiratoryRateMax, 40);
    });

    test('Feline Adult temperature baseline should be 38.1-39.2', () {
      final baseline = LiveVitalData.getPatientBaseline();

      expect(baseline.temperatureMin, 38.1);
      expect(baseline.temperatureMax, 39.2);
    });

    test('Feline Adult SpO2 baseline should be 95-100', () {
      final baseline = LiveVitalData.getPatientBaseline();

      expect(baseline.spo2Min, 95);
      expect(baseline.spo2Max, 100);
    });
  });
}
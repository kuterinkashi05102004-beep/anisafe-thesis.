import 'package:flutter_test/flutter_test.dart';

import '../lib/algorithm/baseline.dart';
import '../lib/models/current_user.dart';

void main() {
  group('AniSafe Selected Patient Baseline Tests', () {
    
    test('Selected Feline age 5 should use Adult Feline baseline', () {
      // Simulate the patient selected from PatientListScreen
      CurrentUser.patientId = 1;
      CurrentUser.patientName = 'Mimi';
      CurrentUser.age = '5';
      CurrentUser.species = 'Feline';

      // Convert CurrentUser age to integer
      final age = int.parse(CurrentUser.age);

      // Get baseline for the currently selected patient
      final baseline = BaselineSelector.getBaseline(
        species: CurrentUser.species,
        age: age,
      );

      // Verify selected patient information
      expect(CurrentUser.patientId, 1);
      expect(CurrentUser.patientName, 'Mimi');
      expect(CurrentUser.species, 'Feline');
      expect(CurrentUser.age, '5');

      // Verify correct baseline
      expect(baseline.species, 'Feline');
      expect(baseline.ageGroup, AgeGroup.adult);

      expect(baseline.bpmMin, 120);
      expect(baseline.bpmMax, 140);

      expect(baseline.respiratoryRateMin, 16);
      expect(baseline.respiratoryRateMax, 40);

      expect(baseline.temperatureMin, 38.1);
      expect(baseline.temperatureMax, 39.2);

      expect(baseline.spo2Min, 95);
      expect(baseline.spo2Max, 100);
    });

    test('Selected Canine age 5 should use Adult Canine baseline', () {
      CurrentUser.patientId = 2;
      CurrentUser.patientName = 'Max';
      CurrentUser.age = '5';
      CurrentUser.species = 'Canine';

      final age = int.parse(CurrentUser.age);

      final baseline = BaselineSelector.getBaseline(
        species: CurrentUser.species,
        age: age,
      );

      expect(CurrentUser.species, 'Canine');
      expect(CurrentUser.age, '5');

      expect(baseline.species, 'Canine');
      expect(baseline.ageGroup, AgeGroup.adult);

      expect(baseline.bpmMin, 70);
      expect(baseline.bpmMax, 120);

      expect(baseline.respiratoryRateMin, 18);
      expect(baseline.respiratoryRateMax, 34);

      expect(baseline.temperatureMin, 37.5);
      expect(baseline.temperatureMax, 39.2);

      expect(baseline.spo2Min, 95);
      expect(baseline.spo2Max, 100);
    });

    test('Selected Canine age 9 should use Senior Canine baseline', () {
      CurrentUser.patientId = 3;
      CurrentUser.patientName = 'Buddy';
      CurrentUser.age = '9';
      CurrentUser.species = 'Canine';

      final age = int.parse(CurrentUser.age);

      final baseline = BaselineSelector.getBaseline(
        species: CurrentUser.species,
        age: age,
      );

      expect(baseline.species, 'Canine');
      expect(baseline.ageGroup, AgeGroup.senior);
    });

    test('Selected Feline age 2 should use Young Feline baseline', () {
      CurrentUser.patientId = 4;
      CurrentUser.patientName = 'Luna';
      CurrentUser.age = '2';
      CurrentUser.species = 'Feline';

      final age = int.parse(CurrentUser.age);

      final baseline = BaselineSelector.getBaseline(
        species: CurrentUser.species,
        age: age,
      );

      expect(baseline.species, 'Feline');
      expect(baseline.ageGroup, AgeGroup.young);
    });

    test('Selected Feline age 11 should use Senior Feline baseline', () {
      CurrentUser.patientId = 5;
      CurrentUser.patientName = 'Milo';
      CurrentUser.age = '11';
      CurrentUser.species = 'Feline';

      final age = int.parse(CurrentUser.age);

      final baseline = BaselineSelector.getBaseline(
        species: CurrentUser.species,
        age: age,
      );

      expect(baseline.species, 'Feline');
      expect(baseline.ageGroup, AgeGroup.senior);
    });
  });
}
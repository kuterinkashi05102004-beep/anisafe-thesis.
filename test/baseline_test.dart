import 'package:flutter_test/flutter_test.dart';

import '../lib/algorithm/baseline.dart';

void main() {
  group('AniSafe Baseline Tests', () {
    test('Canine age 2 should be Young', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Canine',
        age: 2,
      );

      expect(ageGroup, AgeGroup.young);
    });

    test('Canine age 5 should be Adult', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Canine',
        age: 5,
      );

      expect(ageGroup, AgeGroup.adult);
    });

    test('Canine age 8 should be Senior', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Canine',
        age: 8,
      );

      expect(ageGroup, AgeGroup.senior);
    });

    test('Feline age 2 should be Young', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Feline',
        age: 2,
      );

      expect(ageGroup, AgeGroup.young);
    });

    test('Feline age 5 should be Adult', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Feline',
        age: 5,
      );

      expect(ageGroup, AgeGroup.adult);
    });

    test('Feline age 11 should be Senior', () {
      final ageGroup = BaselineSelector.getAgeGroup(
        species: 'Feline',
        age: 11,
      );

      expect(ageGroup, AgeGroup.senior);
    });

    test('Feline age 5 should return correct baseline', () {
      final baseline = BaselineSelector.getBaseline(
        species: 'Feline',
        age: 5,
      );

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

    test('Canine age 9 should return Senior baseline', () {
      final baseline = BaselineSelector.getBaseline(
        species: 'Canine',
        age: 9,
      );

      expect(baseline.species, 'Canine');
      expect(baseline.ageGroup, AgeGroup.senior);

      expect(baseline.bpmMin, 70);
      expect(baseline.bpmMax, 120);

      expect(baseline.respiratoryRateMin, 18);
      expect(baseline.respiratoryRateMax, 34);

      expect(baseline.temperatureMin, 37.5);
      expect(baseline.temperatureMax, 39.2);

      expect(baseline.spo2Min, 95);
      expect(baseline.spo2Max, 100);
    });
  });
}
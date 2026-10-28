// ======================================================
// AniSafe - Baseline System
// ======================================================
// Purpose:
// Species + Age
//      ↓
// Age Group
//      ↓
// Correct physiological baseline
//
// This file does NOT:
// - connect to BLE
// - access the database
// - run Random Forest
// - modify patient data
// ======================================================

/// Represents the three age groups used by AniSafe.
enum AgeGroup {
  young,
  adult,
  senior,
}

/// Stores the normal physiological range for a patient profile.
class VitalBaseline {
  final String species;
  final AgeGroup ageGroup;

  final double bpmMin;
  final double bpmMax;

  final double respiratoryRateMin;
  final double respiratoryRateMax;

  final double temperatureMin;
  final double temperatureMax;

  final double spo2Min;
  final double spo2Max;

  const VitalBaseline({
    required this.species,
    required this.ageGroup,
    required this.bpmMin,
    required this.bpmMax,
    required this.respiratoryRateMin,
    required this.respiratoryRateMax,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.spo2Min,
    required this.spo2Max,
  });
}

/// AniSafe baseline selector.
///
/// Takes:
/// - species: Canine or Feline
/// - age: patient's age in years
///
/// Returns:
/// - the correct AgeGroup
/// - the corresponding physiological baseline
class BaselineSelector {
  /// Determines the AniSafe age group based on species and age.
  static AgeGroup getAgeGroup({
    required String species,
    required int age,
  }) {
    if (age < 0) {
      throw ArgumentError('Age cannot be negative.');
    }

    if (age == 0) {
      throw ArgumentError(
        'Age 0 is considered a baby and is not included in the AniSafe age groups.',
      );
    }

    if (species == 'Canine') {
      if (age <= 2) {
        return AgeGroup.young;
      } else if (age <= 7) {
        return AgeGroup.adult;
      } else {
        return AgeGroup.senior;
      }
    }

    if (species == 'Feline') {
      if (age <= 2) {
        return AgeGroup.young;
      } else if (age <= 10) {
        return AgeGroup.adult;
      } else {
        return AgeGroup.senior;
      }
    }

    throw ArgumentError(
      'Unsupported species: $species. '
      'Expected Canine or Feline.',
    );
  }

  /// Returns the correct baseline for the selected patient.
  static VitalBaseline getBaseline({
    required String species,
    required int age,
  }) {
    final ageGroup = getAgeGroup(
      species: species,
      age: age,
    );

    // ==================================================
    // CANINE BASELINES
    // ==================================================

    if (species == 'Canine') {
      switch (ageGroup) {
        case AgeGroup.young:
          return const VitalBaseline(
            species: 'Canine',
            ageGroup: AgeGroup.young,
            bpmMin: 70,
            bpmMax: 120,
            respiratoryRateMin: 18,
            respiratoryRateMax: 34,
            temperatureMin: 37.5,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );

        case AgeGroup.adult:
          return const VitalBaseline(
            species: 'Canine',
            ageGroup: AgeGroup.adult,
            bpmMin: 70,
            bpmMax: 120,
            respiratoryRateMin: 18,
            respiratoryRateMax: 34,
            temperatureMin: 37.5,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );

        case AgeGroup.senior:
          return const VitalBaseline(
            species: 'Canine',
            ageGroup: AgeGroup.senior,
            bpmMin: 70,
            bpmMax: 120,
            respiratoryRateMin: 18,
            respiratoryRateMax: 34,
            temperatureMin: 37.5,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );
      }
    }

    // ==================================================
    // FELINE BASELINES
    // ==================================================

    if (species == 'Feline') {
      switch (ageGroup) {
        case AgeGroup.young:
          return const VitalBaseline(
            species: 'Feline',
            ageGroup: AgeGroup.young,
            bpmMin: 120,
            bpmMax: 140,
            respiratoryRateMin: 16,
            respiratoryRateMax: 40,
            temperatureMin: 38.1,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );

        case AgeGroup.adult:
          return const VitalBaseline(
            species: 'Feline',
            ageGroup: AgeGroup.adult,
            bpmMin: 120,
            bpmMax: 140,
            respiratoryRateMin: 16,
            respiratoryRateMax: 40,
            temperatureMin: 38.1,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );

        case AgeGroup.senior:
          return const VitalBaseline(
            species: 'Feline',
            ageGroup: AgeGroup.senior,
            bpmMin: 120,
            bpmMax: 140,
            respiratoryRateMin: 16,
            respiratoryRateMax: 40,
            temperatureMin: 38.1,
            temperatureMax: 39.2,
            spo2Min: 95,
            spo2Max: 100,
          );
      }
    }

    // This should never be reached because unsupported
    // species are rejected by getAgeGroup().
    throw ArgumentError('Unable to determine baseline.');
  }
}
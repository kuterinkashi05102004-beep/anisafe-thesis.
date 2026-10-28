// ======================================================
// AniSafe - Vital Classifier
// ======================================================
// Purpose:
// Use the patient's selected baseline to classify
// live vital measurements.
//
// baseline.dart
//      ↓
// Patient baseline
//      ↓
// Vital Classifier
//      ↓
// BPM / RR / Temperature / SpO₂ classification
//
// This file does NOT:
// - connect to BLE
// - access the database
// - run Random Forest
// - modify patient data
// ======================================================

import 'baseline.dart';

class VitalClassifier {
  // ====================================================
  // BPM CLASSIFICATION
  // ====================================================

  static String classifyBpm(
    double bpm,
    VitalBaseline baseline,
  ) {
    if (bpm < baseline.bpmMin) {
      return 'Bradycardia';
    }

    if (bpm > baseline.bpmMax) {
      return 'Tachycardia';
    }

    return 'Normal';
  }

  // ====================================================
  // RESPIRATORY RATE CLASSIFICATION
  // ====================================================

  static String classifyRespiratoryRate(
    double respiratoryRate,
    VitalBaseline baseline,
  ) {
    if (respiratoryRate < baseline.respiratoryRateMin) {
      return 'Bradypnea';
    }

    if (respiratoryRate > baseline.respiratoryRateMax) {
      return 'Tachypnea';
    }

    return 'Normal';
  }

  // ====================================================
  // TEMPERATURE CLASSIFICATION
  // ====================================================

  static String classifyTemperature(
    double temperature,
    VitalBaseline baseline,
  ) {
    if (temperature < baseline.temperatureMin) {
      return 'Hypothermia';
    }

    if (temperature > baseline.temperatureMax) {
      return 'fever/pyrexia';
    }

    return 'Normal';
  }

  // ====================================================
  // SpO₂ CLASSIFICATION
  // ====================================================

  static String classifySpo2(
    double spo2,
    VitalBaseline baseline,
  ) {
    if (spo2 < baseline.spo2Min) {
      return 'Hypoxemia';
    }

    if (spo2 > baseline.spo2Max) {
      return 'Invalid/Review';
    }

    return 'Normal';
  }
}
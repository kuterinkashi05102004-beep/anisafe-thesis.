import '../bluetooth/ble_manager.dart';
import '../models/current_user.dart';
import 'baseline.dart';
import 'vital_classifier.dart';

class LiveVitalData {
  // ============================================================
  // GET THE SELECTED PATIENT'S BASELINE
  // ============================================================

  static VitalBaseline getPatientBaseline() {
    if (CurrentUser.species.isEmpty) {
      throw StateError('No patient species selected.');
    }

    if (CurrentUser.age.isEmpty) {
      throw StateError('No patient age selected.');
    }

    final int age = int.parse(CurrentUser.age);

    return BaselineSelector.getBaseline(
      species: CurrentUser.species,
      age: age,
    );
  }

  // ============================================================
  // LIVE BPM
  // ============================================================

  static double get bpm {
    return BleManager.instance.bpm.toDouble();
  }

  static String get bpmClassification {
    final baseline = getPatientBaseline();

    return VitalClassifier.classifyBpm(
      bpm,
      baseline,
    );
  }

  // ============================================================
  // LIVE SpO₂
  // ============================================================

  static double get spo2 {
    return BleManager.instance.spo2.toDouble();
  }

  static String get spo2Classification {
    final baseline = getPatientBaseline();

    return VitalClassifier.classifySpo2(
      spo2,
      baseline,
    );
  }

  // ============================================================
  // LIVE TEMPERATURE
  // ============================================================

  static double get temperature {
    return BleManager.instance.temperature;
  }

  static String get temperatureClassification {
    final baseline = getPatientBaseline();

    return VitalClassifier.classifyTemperature(
      temperature,
      baseline,
    );
  }

  // ============================================================
  // LIVE RESPIRATORY RATE
  // ============================================================

  static double get respiratoryRate {
    return BleManager.instance.respiratoryRate.toDouble();
  }

  static String get respiratoryRateClassification {
    final baseline = getPatientBaseline();

    return VitalClassifier.classifyRespiratoryRate(
      respiratoryRate,
      baseline,
    );
  }

  // ============================================================
  // FINGER DETECTION
  // ============================================================

  static bool get fingerDetected {
    return BleManager.instance.fingerDetected;
  }

  // ============================================================
  // BLE CONNECTION STATUS
  // ============================================================

  static String get connectionStatus {
    return BleManager.instance.connectionStatus;
  }
}
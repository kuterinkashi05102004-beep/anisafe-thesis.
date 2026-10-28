// ======================================================
// AniSafe - 10-Minute Assessment Buffer
// ======================================================
// Purpose:
// Temporarily collect vital readings during a
// 10-minute assessment window.
//
// This file does NOT:
// - connect to BLE
// - access the database
// - run Random Forest
// - calculate RF features
// - modify patient data
//
// It only:
// - stores vital readings
// - records their timestamps
// - tracks the assessment window
// - tells us when 10 minutes are complete
// ======================================================

/// Represents one vital-sign reading collected during
/// the assessment window.
class VitalReading {
  final DateTime timestamp;

  final double bpm;
  final double spo2;
  final double temperature;
  final double respiratoryRate;

  const VitalReading({
    required this.timestamp,
    required this.bpm,
    required this.spo2,
    required this.temperature,
    required this.respiratoryRate,
  });
}

/// Temporarily stores vital readings for one
/// 10-minute assessment window.
class AssessmentBuffer {
  /// Duration of one assessment window.
  static const Duration assessmentDuration = Duration(minutes: 10);

  /// All readings collected during this assessment.
  final List<VitalReading> _readings = [];

  /// Time when the current assessment started.
  DateTime? _startTime;

  /// Starts a new assessment window.
  void start(DateTime startTime) {
    _readings.clear();
    _startTime = startTime;
  }

  /// Adds one vital reading to the current assessment.
  void addReading({
    required DateTime timestamp,
    required double bpm,
    required double spo2,
    required double temperature,
    required double respiratoryRate,
  }) {
    if (_startTime == null) {
      throw StateError(
        'Assessment has not been started.',
      );
    }

    _readings.add(
      VitalReading(
        timestamp: timestamp,
        bpm: bpm,
        spo2: spo2,
        temperature: temperature,
        respiratoryRate: respiratoryRate,
      ),
    );
  }

  /// Returns all readings collected so far.
  List<VitalReading> get readings =>
      List.unmodifiable(_readings);

  /// Returns the time when the assessment started.
  DateTime? get startTime => _startTime;

  /// Returns true when 10 minutes have elapsed.
  bool isComplete(DateTime currentTime) {
    if (_startTime == null) {
      return false;
    }

    return currentTime.difference(_startTime!) >=
        assessmentDuration;
  }

  /// Returns the number of readings collected.
  int get readingCount => _readings.length;

  /// Returns true when at least one reading exists.
  bool get hasReadings => _readings.isNotEmpty;

  /// Clears the current assessment.
  void clear() {
    _readings.clear();
    _startTime = null;
  }
}
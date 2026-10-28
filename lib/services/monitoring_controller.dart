
import 'dart:async';

import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';

import '../bluetooth/ble_manager.dart';

import '../database/database_helper.dart';
import '../models/current_user.dart';
import '../algorithm/rf_assessment_input.dart';
import 'rf_prediction_service.dart';
import 'notification_service.dart';

class MonitoringController extends ChangeNotifier {
  MonitoringController._() {
    _disconnectSubscription =
        BleManager.instance.disconnectEvents.listen((_) {
      _handleBleDisconnect();
    });
  }

  static final MonitoringController instance =
      MonitoringController._();

  Timer? _monitoringTimer;

  StreamSubscription<void>? _disconnectSubscription;

  bool _backgroundExecutionEnabled = false;
  bool _disconnectHandling = false;

  // Minute-level vital finding counts.
  int _normalCount = 0;
  int _warningCount = 0;
  int _abnormalCount = 0;

  // Consecutive minute findings.
  int _consecutiveWarningMinutes = 0;
  int _consecutiveAbnormalMinutes = 0;

  // Existing assessment buffers.
  final List<Map<String, double>> _rfObservationBuffer = [];
  final List<String> _tenMinuteFindings = [];
  final List<String> _hourlyFindings = [];

  // Session timing and hourly log protection.
  DateTime? _hourlyStartTime;

  bool _hourlyLogSavedForSession = false;

  // RF assessment queue protection.
  bool _rfAssessmentInProgress = false;
  final List<String> _pendingRfAssessments = [];

  final RfPredictionService _rfPredictionService =
      RfPredictionService();

  bool _isMonitoring = false;
  bool _isStarting = false;

  int _triggerEventId = 0;
  String? _latestTriggerFinding;

  int _elapsedSecondsInMinute = 0;
  int _validObservationCount = 0;

  bool get isMonitoring => _isMonitoring;
  bool get isStarting => _isStarting;

  int get triggerEventId => _triggerEventId;
  String? get latestTriggerFinding => _latestTriggerFinding;

  int get elapsedSecondsInMinute =>
      _elapsedSecondsInMinute;

  int get validObservationCount =>
      _validObservationCount;

  static const int secondsPerMinute = 60;

  Future<bool> startMonitoring() async {
    if (_isMonitoring || _isStarting) {
      return _isMonitoring;
    }

    // Require an active ESP32 connection.
    if (BleManager.instance.connectionStatus != 'Connected') {
      return false;
    }

    _isStarting = true;
    notifyListeners();

    try {
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: 'AniSafe Monitoring',
        notificationText: 'Monitoring is active',
        notificationImportance:
            AndroidNotificationImportance.normal,
        enableWifiLock: true,
      );

      final initialized =
          await FlutterBackground.initialize(
        androidConfig: androidConfig,
      );

      if (!initialized) {
        return false;
      }

      // Check the connection again before starting.
      if (BleManager.instance.connectionStatus != 'Connected') {
        return false;
      }

      
      final backgroundStarted =
          await FlutterBackground.enableBackgroundExecution();

      if (!backgroundStarted) {
        return false;
      }

      _backgroundExecutionEnabled = true;

      // Check again after enabling background execution.
      if (BleManager.instance.connectionStatus != 'Connected') {
        await stopMonitoring();
        return false;
      }


      
  
  _resetMinuteCounters();

  final now = DateTime.now();
  _hourlyStartTime = now;

  _hourlyLogSavedForSession = false;

  _tenMinuteFindings.clear();
  _hourlyFindings.clear();
  _rfObservationBuffer.clear();

  _consecutiveWarningMinutes = 0;
  _consecutiveAbnormalMinutes = 0;
  
  _pendingRfAssessments.clear();

  _isMonitoring = true;


      _monitoringTimer?.cancel();
      _monitoringTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _processOneSecond(),
      );

      print('Monitoring controller started.');
      return true;
    } catch (error, stackTrace) {
      print('Unable to start monitoring: $error');
      print(stackTrace);
      return false;
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }



  
  void _processOneSecond() {
    if (!_isMonitoring) return;

    _elapsedSecondsInMinute++;

    final ble = BleManager.instance;

    final validReading =
        ble.fingerDetected &&
        ble.bpm > 0 &&
        ble.spo2 > 0 &&
        ble.temperature > 0 &&
        ble.respiratoryRate > 0;

    if (validReading) {
      _validObservationCount++;

      _rfObservationBuffer.add({
        'bpm': ble.bpm.toDouble(),
        'spo2': ble.spo2.toDouble(),
        'temperature': ble.temperature.toDouble(),
        'respiratoryRate': ble.respiratoryRate.toDouble(),
      });

      final finding = _getOverallObservationFinding();

      switch (finding) {
        case 'Normal':
          _normalCount++;
          break;
        case 'Warning':
          _warningCount++;
          break;
        case 'Abnormal':
          _abnormalCount++;
          break;
      }
    }

    if (_elapsedSecondsInMinute >= secondsPerMinute) {
      if (_validObservationCount > 0) {
        _finishOneMinuteBuffer();
      } else {
        print('No valid observations this minute. Skipping finding.');
        _resetMinuteCounters();
      }
    }

    notifyListeners();
    _checkHourlySessionTimeout();
  }





  
  void _finishOneMinuteBuffer() {
    late final String minuteFinding;

    // Abnormal takes priority during a tie.
    if (_abnormalCount >= _warningCount &&
        _abnormalCount >= _normalCount) {
      minuteFinding = 'Abnormal';
    } else if (_warningCount >= _normalCount) {
      minuteFinding = 'Warning';
    } else {
      minuteFinding = 'Normal';
    }

    print(
      'Minute completed: Normal=$_normalCount, '
      'Warning=$_warningCount, Abnormal=$_abnormalCount',
    );
    print('Minute majority finding: $minuteFinding');

    _recordMinuteFinding(minuteFinding);

    
    // Accumulate Warning and Abnormal minute findings independently.
    // Normal minutes do not reset either trigger counter.
    if (minuteFinding == 'Warning') {
      _consecutiveWarningMinutes++;
    } else if (minuteFinding == 'Abnormal') {
      _consecutiveAbnormalMinutes++;
    }

    // WARNING: temporary test threshold = 3 minute.
    if (_consecutiveWarningMinutes >= 3) {                            // WARNING: temporary test threshold = 3 minute.
      print(
        'WARNING TRIGGER: '
        '$_consecutiveWarningMinutes Warning minute(s)',
      );

      // Reset BOTH trigger counters immediately.
      _consecutiveWarningMinutes = 0;
      _consecutiveAbnormalMinutes = 0;

      // Preserve the ten-minute and hourly logging buffers.
      _handleMonitoringTrigger(
        'Warning',
        resetSession: false,
      );
    }
    // ABNORMAL: temporary test threshold = 4 minutes.
    else if (_consecutiveAbnormalMinutes >= 4) {                      // WARNING: temporary test threshold = 4 minute.
      print(
        'ABNORMAL TRIGGER: '
        '$_consecutiveAbnormalMinutes Abnormal minute(s)',
      );

      // Reset BOTH trigger counters immediately.
      _consecutiveWarningMinutes = 0;
      _consecutiveAbnormalMinutes = 0;

      // Preserve the ten-minute and hourly logging buffers.
      _handleMonitoringTrigger(
        'Abnormal',
        resetSession: false,
      );
    }


    _resetMinuteCounters();
  }






  
  void _resetMinuteCounters() {
    _elapsedSecondsInMinute = 0;
    _validObservationCount = 0;
    _normalCount = 0;
    _warningCount = 0;
    _abnormalCount = 0;
  }




  // TEMPORARY TEST — controller-owned abnormal trigger
  
  Future<void> runAbnormalTriggerTest() async {
    // Do not test when monitoring is inactive.
    if (!_isMonitoring) {
      print('Test stopped: start monitoring first.');
      return;
    }

    print('==========================================');
    print('CONTROLLER: ABNORMAL TRIGGER TEST STARTED');
    print('==========================================');

    // Ensure a valid vital observation exists for RF assessment.
    if (_getLatestRfObservation() == null) {
      print(
        'Test stopped: no valid vital observation is available. '
        'Wait for a valid reading first.',
      );
      return;
    }

    // Reset the consecutive-trigger state for this test.
    _consecutiveWarningMinutes = 0;
    _consecutiveAbnormalMinutes = 0;

    // Simulate four completed Abnormal minutes.
    for (int i = 1; i <= 4; i++) {
      // Stop if monitoring ends during the test.
      if (!_isMonitoring) {
        print('Test stopped: monitoring is no longer active.');
        return;
      }

      _normalCount = 0;
      _warningCount = 0;
      _abnormalCount = 60;
      _validObservationCount = 60;

      print('Controller test: simulating Abnormal minute $i of 4');

      _finishOneMinuteBuffer();

      // Allow the trigger's asynchronous processing to progress.
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('CONTROLLER: ABNORMAL TRIGGER TEST FINISHED');
  }



  
  String _classifyVital({
    required double value,
    required double normalMin,
    required double normalMax,
    required double warningLowMin,
    required double warningLowMax,
    required double warningHighMin,
    required double warningHighMax,
    required double abnormalLowMax,
    required double abnormalHighMin,
  }) {
    if (value <= abnormalLowMax || value >= abnormalHighMin) {
      return 'Abnormal';
    }

    if ((value >= warningLowMin && value <= warningLowMax) ||
        (value >= warningHighMin && value <= warningHighMax)) {
      return 'Warning';
    }

    if (value >= normalMin && value <= normalMax) {
      return 'Normal';
    }

    return 'Abnormal';
  }




  
  // Classify one live vital sign using the same species-specific
  // thresholds as background monitoring.
  String classifyVitalReading({
    required String vital,
    required double value,
  }) {
    final species = CurrentUser.species.toLowerCase();
    final isCat = species == 'cat' || species == 'feline';
    final vitalName = vital.toLowerCase();

    // SpO2 uses the same baseline for dogs and cats.
    if (vitalName == 'spo2') {
      if (value <= 90 || value > 100) {
        return 'Abnormal';
      }
      if (value >= 91 && value <= 94) {
        return 'Warning';
      }
      if (value >= 95 && value <= 100) {
        return 'Normal';
      }
      return 'Abnormal';
    }

    if (isCat) {
      switch (vitalName) {
        case 'bpm':
          return _classifyVital(
            value: value,
            normalMin: 120,
            normalMax: 140,
            warningLowMin: 117,
            warningLowMax: 119,
            warningHighMin: 141,
            warningHighMax: 143,
            abnormalLowMax: 116,
            abnormalHighMin: 144,
          );

        case 'temperature':
          return _classifyVital(
            value: value,
            normalMin: 38,
            normalMax: 39,
            warningLowMin: 36,
            warningLowMax: 37,
            warningHighMin: 40,
            warningHighMax: 41,
            abnormalLowMax: 35,
            abnormalHighMin: 42,
          );

        case 'rr':
          return _classifyVital(
            value: value,
            normalMin: 16,
            normalMax: 40,
            warningLowMin: 14,
            warningLowMax: 15,
            warningHighMin: 41,
            warningHighMax: 46,
            abnormalLowMax: 13,
            abnormalHighMin: 47,
          );
      }
    } else {
      switch (vitalName) {
        case 'bpm':
          return _classifyVital(
            value: value,
            normalMin: 70,
            normalMax: 120,
            warningLowMin: 67,
            warningLowMax: 69,
            warningHighMin: 121,
            warningHighMax: 123,
            abnormalLowMax: 66,
            abnormalHighMin: 124,
          );

        case 'temperature':
          return _classifyVital(
            value: value,
            normalMin: 37,
            normalMax: 39,
            warningLowMin: 35,
            warningLowMax: 36,
            warningHighMin: 40,
            warningHighMax: 41,
            abnormalLowMax: 34,
            abnormalHighMin: 42,
          );

        case 'rr':
          return _classifyVital(
            value: value,
            normalMin: 18,
            normalMax: 34,
            warningLowMin: 15,
            warningLowMax: 17,
            warningHighMin: 35,
            warningHighMax: 40,
            abnormalLowMax: 14,
            abnormalHighMin: 41,
          );
      }
    }

    return 'Abnormal';
  }





  
  String _getOverallObservationFinding() {
    final species = (CurrentUser.species).toLowerCase();

    final ble = BleManager.instance;
    final bpm = ble.bpm.toDouble();
    final spo2 = ble.spo2.toDouble();
    final temperature = ble.temperature.toDouble();
    final respiratoryRate = ble.respiratoryRate.toDouble();

    late String bpmFinding;
    late String rrFinding;
    late String temperatureFinding;

    if (species == 'cat' || species == 'feline') {
      bpmFinding = _classifyVital(
        value: bpm,
        normalMin: 120,
        normalMax: 140,
        warningLowMin: 117,
        warningLowMax: 119,
        warningHighMin: 141,
        warningHighMax: 143,
        abnormalLowMax: 116,
        abnormalHighMin: 144,
      );

      rrFinding = _classifyVital(
        value: respiratoryRate,
        normalMin: 16,
        normalMax: 40,
        warningLowMin: 14,
        warningLowMax: 15,
        warningHighMin: 41,
        warningHighMax: 46,
        abnormalLowMax: 13,
        abnormalHighMin: 47,
      );

      temperatureFinding = _classifyVital(
        value: temperature,
        normalMin: 38,
        normalMax: 39,
        warningLowMin: 36,
        warningLowMax: 37,
        warningHighMin: 40,
        warningHighMax: 41,
        abnormalLowMax: 35,
        abnormalHighMin: 42,
      );
    } else {
      bpmFinding = _classifyVital(
        value: bpm,
        normalMin: 70,
        normalMax: 120,
        warningLowMin: 67,
        warningLowMax: 69,
        warningHighMin: 121,
        warningHighMax: 123,
        abnormalLowMax: 66,
        abnormalHighMin: 124,
      );

      rrFinding = _classifyVital(
        value: respiratoryRate,
        normalMin: 18,
        normalMax: 34,
        warningLowMin: 15,
        warningLowMax: 17,
        warningHighMin: 35,
        warningHighMax: 40,
        abnormalLowMax: 14,
        abnormalHighMin: 41,
      );

      temperatureFinding = _classifyVital(
        value: temperature,
        normalMin: 37,
        normalMax: 39,
        warningLowMin: 35,
        warningLowMax: 36,
        warningHighMin: 40,
        warningHighMax: 41,
        abnormalLowMax: 34,
        abnormalHighMin: 42,
      );
    }

    final spo2Finding = spo2 <= 90
        ? 'Abnormal'
        : (spo2 >= 91 && spo2 <= 94)
            ? 'Warning'
            : (spo2 >= 95 && spo2 <= 100)
                ? 'Normal'
                : 'Abnormal';

    final findings = [
      bpmFinding,
      spo2Finding,
      temperatureFinding,
      rrFinding,
    ];

    if (findings.contains('Abnormal')) {
      return 'Abnormal';
    }

    if (findings.contains('Warning')) {
      return 'Warning';
    }

    return 'Normal';
  }




  
  void _recordMinuteFinding(String minuteFinding) {
    _tenMinuteFindings.add(minuteFinding);

    print(
      'Ten-minute buffer: ${_tenMinuteFindings.length} / 10 '
      '| Finding: $minuteFinding',
    );

    if (_tenMinuteFindings.length < 10) return;

    int normalMinutes = 0;
    int warningMinutes = 0;
    int abnormalMinutes = 0;

    for (final finding in _tenMinuteFindings) {
      if (finding == 'Normal') {
        normalMinutes++;
      } else if (finding == 'Warning') {
        warningMinutes++;
      } else if (finding == 'Abnormal') {
        abnormalMinutes++;
      }
    }

    late final String tenMinuteFinding;

    if (abnormalMinutes >= warningMinutes &&
        abnormalMinutes >= normalMinutes) {
      tenMinuteFinding = 'Abnormal';
    } else if (warningMinutes >= normalMinutes) {
      tenMinuteFinding = 'Warning';
    } else {
      tenMinuteFinding = 'Normal';
    }

    print('Ten-minute result: $tenMinuteFinding');

    
    _recordHourlyFinding(tenMinuteFinding);

    _tenMinuteFindings.clear();

  }




  
  void _recordHourlyFinding(String tenMinuteFinding) {
    _hourlyFindings.add(tenMinuteFinding);

    print(
      'Hourly buffer: ${_hourlyFindings.length} / 6 '
      '| Finding: $tenMinuteFinding',
    );

    if (_hourlyFindings.length < 6) return;

    print('Six ten-minute assessments completed.');

    // The automatic 60-minute timeout handles hourly log saving.
    _hourlyFindings.clear();
  }




  
  Map<String, double>? _getLatestRfObservation() {
    for (int i = _rfObservationBuffer.length - 1; i >= 0; i--) {
      final observation = _rfObservationBuffer[i];

      final bpm = observation['bpm'] ?? 0;
      final spo2 = observation['spo2'] ?? 0;
      final temperature = observation['temperature'] ?? 0;
      final respiratoryRate = observation['respiratoryRate'] ?? 0;

      if (bpm > 0 &&
          spo2 > 0 &&
          temperature > 0 &&
          respiratoryRate > 0) {
        return observation;
      }
    }

    return null;
  }





  
  Future<RfPredictionResult?> _prepareRfAssessmentInput(
    String finding, {
    bool saveAssessmentLog = true,
  }) async {
    final latestObservation = _getLatestRfObservation();

    if (latestObservation == null) {
      print('RF assessment skipped: no valid observation.');
      return null;
    }

    final speciesRaw = CurrentUser.species.toLowerCase();

    final species =
        (speciesRaw == 'cat' || speciesRaw == 'feline')
            ? 'Feline'
            : 'Canine';

    
    final age = int.tryParse(CurrentUser.age.toString()) ?? 0;


    final String ageGroup;

    if (species == 'Feline') {
      ageGroup = age <= 2
          ? 'Young'
          : age <= 10
              ? 'Adult'
              : 'Senior';
    } else {
      ageGroup = age <= 2
          ? 'Young'
          : age <= 7
              ? 'Adult'
              : 'Senior';
    }

    final bpm = latestObservation['bpm']!;
    final spo2 = latestObservation['spo2']!;
    final temperature = latestObservation['temperature']!;
    final respiratoryRate = latestObservation['respiratoryRate']!;

    final rfInput = RfAssessmentInput(
      species: species,
      age: age,
      ageGroup: ageGroup,
      bpm: bpm,
      spo2: spo2,
      temperature: temperature,
      respiratoryRate: respiratoryRate.toInt(),
      triggerFinding: finding,
    );

    print('RF assessment input: $rfInput');

    final result = await _rfPredictionService.predict(
      species: species,
      ageGroup: ageGroup,
      bpm: bpm,
      spo2: spo2,
      temperature: temperature,
      respiratoryRate: respiratoryRate,
    );

    print('Trigger finding: $finding');
    print('RF finding: ${result.finding}');

    
    if (saveAssessmentLog) {
      final now = DateTime.now();

      await DatabaseHelper.instance.insertRecord(
        patientId: CurrentUser.patientId!,
        bpm: bpm.toInt(),
        spo2: spo2.toInt(),
        temperature: temperature,
        respiratoryRate: respiratoryRate.toInt(),
        date: DateFormat('MMM d EEE').format(now),
        time: DateFormat('hh:mm a').format(now),
        logType: 'RF Assessment',
        finding: result.finding,
        triggerFinding: finding,
        rfFinding: result.finding,
      );

      print('RF Assessment saved to Health Logs.');
    }


    return result;
  }




  
  Future<void> _handleMonitoringTrigger(
    String finding, {
    bool resetSession = true,
  }) async {
    if (_rfAssessmentInProgress) {
      _pendingRfAssessments.add(finding);
      print('Queued RF assessment: $finding');
      return;
    }

    // Notify MonitorScreen that a trigger needs a foreground dialog.
    _latestTriggerFinding = finding;
    _triggerEventId++;
    notifyListeners();

    _rfAssessmentInProgress = true;

    try {
      print('Monitoring trigger activated: $finding');

      
      if (resetSession) {
        _tenMinuteFindings.clear();
        _hourlyFindings.clear();
        _hourlyStartTime = DateTime.now();
        _hourlyLogSavedForSession = false;
      }


      if (finding == 'Warning') {
        await NotificationService.instance.showWarningNotification();
      } else if (finding == 'Abnormal') {
        await NotificationService.instance.showAbnormalNotification();
      }

      await _prepareRfAssessmentInput(finding);
    } catch (error, stackTrace) {
      print('Monitoring trigger failed: $error');
      print(stackTrace);
    } finally {
      _rfAssessmentInProgress = false;
    }

    if (_pendingRfAssessments.isNotEmpty && _isMonitoring) {
      final nextFinding = _pendingRfAssessments.removeAt(0);

      await _handleMonitoringTrigger(
        nextFinding,
        resetSession: false,
      );
    }
  }



  



  
  Future<void> _checkHourlySessionTimeout() async {
    if (!_isMonitoring) return;

    if (_hourlyStartTime == null) return;

    // Prevent duplicate saves during the same session.
    if (_hourlyLogSavedForSession) return;

    final now = DateTime.now();
    final elapsed = now.difference(_hourlyStartTime!);

    // Wait until the session reaches 60 minutes.
    if (elapsed.inMinutes < 60) return;

    // TEMPORARY TEST: Wait until the session reaches 3 minutes
    // (elapsed.inMinutes < 1) return;

    final bpm = BleManager.instance.bpm;
    final spo2 = BleManager.instance.spo2;
    final temperature = BleManager.instance.temperature;
    final respiratoryRate = BleManager.instance.respiratoryRate;

    // Do not save incomplete readings.
    if (bpm <= 0 ||
        spo2 <= 0 ||
        temperature <= 0 ||
        respiratoryRate <= 0) {
      print(
        'Hourly session reached 60 minutes, '
        'but current vital readings are incomplete.',
      );
      return;
    }

    final automaticFinding = _getOverallObservationFinding();


    
    final nowDate = DateTime.now();

    final date = DateFormat('MMM d EEE').format(nowDate);
    final time = DateFormat('hh:mm a').format(nowDate);



    // Prevent duplicate saves during the database operation.
    _hourlyLogSavedForSession = true;





    
    try {
      // Run RF assessment before saving the Hourly record.
      RfPredictionResult? rfResult;

      try {
        rfResult = await _prepareRfAssessmentInput(
          automaticFinding,
          saveAssessmentLog: false,
        );

        if (rfResult != null) {
          print('Hourly RF Assessment completed: ${rfResult.finding}');
        } else {
          print(
            'Hourly RF Assessment skipped: '
            'no valid observation available.',
          );
        }
      } catch (error, stackTrace) {
        print('Hourly RF Assessment failed: $error');
        print(stackTrace);
      }

      // Save ONE combined Hourly record.
      await DatabaseHelper.instance.insertRecord(
        patientId: CurrentUser.patientId!,
        bpm: bpm,
        spo2: spo2,
        temperature: temperature,
        respiratoryRate: respiratoryRate,
        date: date,
        time: time,
        logType: 'Hourly',
        finding: automaticFinding,
        triggerFinding: automaticFinding,
        rfFinding: rfResult?.finding,
      );

      print(
        '$automaticFinding Hourly Health Log saved '
        'with RF finding: ${rfResult?.finding ?? 'Unavailable'}.',
      );

      // Start the next hourly session after the save.
      _hourlyStartTime = DateTime.now();
      _hourlyFindings.clear();
      _tenMinuteFindings.clear();
      _hourlyLogSavedForSession = false;

      print('New hourly monitoring session started.');
    } catch (error, stackTrace) {
      // Permit another attempt if saving failed.
      _hourlyLogSavedForSession = false;

      print('Hourly Health Log save failed: $error');
      print(stackTrace);
    }

  }









  
  
  Future<void> _handleBleDisconnect() async {
    // Ignore disconnects when no monitoring session is active
    // or starting, and prevent duplicate handling.
    if ((!_isMonitoring && !_isStarting) ||
        _disconnectHandling) {
      return;
    }

    _disconnectHandling = true;

    try {
      print('Monitoring stopped because ESP32 disconnected.');

      await stopMonitoring();

      await NotificationService.instance
          .showDisconnectedNotification();
    } catch (error, stackTrace) {
      print('Disconnect handling failed: $error');
      print(stackTrace);
    } finally {
      _disconnectHandling = false;
    }
  }





  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    
    _isMonitoring = false;

    if (_backgroundExecutionEnabled) {
      _backgroundExecutionEnabled = false;

      try {
        await FlutterBackground.disableBackgroundExecution();
      } catch (error) {
        print('Unable to disable background execution: $error');
      }
    }


    // Any unfinished minute is discarded.
    _resetMinuteCounters();

    print('Monitoring controller stopped.');
    notifyListeners();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _disconnectSubscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter_test/flutter_test.dart';

import '../lib/algorithm/assessment_buffer.dart';

void main() {
  group('AssessmentBuffer', () {
    test('starts with an empty buffer', () {
      final buffer = AssessmentBuffer();

      expect(buffer.readingCount, 0);
      expect(buffer.hasReadings, false);
      expect(buffer.startTime, isNull);
    });

    test('starts a 10-minute assessment', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      expect(buffer.startTime, startTime);
      expect(buffer.readingCount, 0);
    });

    test('stores one vital reading correctly', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      buffer.addReading(
        timestamp: startTime,
        bpm: 105,
        spo2: 98,
        temperature: 38.5,
        respiratoryRate: 25,
      );

      expect(buffer.readingCount, 1);
      expect(buffer.hasReadings, true);

      final reading = buffer.readings.first;

      expect(reading.timestamp, startTime);
      expect(reading.bpm, 105);
      expect(reading.spo2, 98);
      expect(reading.temperature, 38.5);
      expect(reading.respiratoryRate, 25);
    });

    test('stores multiple vital readings', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      buffer.addReading(
        timestamp: startTime,
        bpm: 105,
        spo2: 98,
        temperature: 38.5,
        respiratoryRate: 25,
      );

      buffer.addReading(
        timestamp: startTime.add(
          const Duration(seconds: 1),
        ),
        bpm: 107,
        spo2: 97,
        temperature: 38.6,
        respiratoryRate: 26,
      );

      buffer.addReading(
        timestamp: startTime.add(
          const Duration(seconds: 2),
        ),
        bpm: 106,
        spo2: 98,
        temperature: 38.5,
        respiratoryRate: 25,
      );

      expect(buffer.readingCount, 3);
    });

    test('assessment is not complete before 10 minutes', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      final currentTime = startTime.add(
        const Duration(minutes: 9, seconds: 59),
      );

      expect(buffer.isComplete(currentTime), false);
    });

    test('assessment is complete after 10 minutes', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      final currentTime = startTime.add(
        const Duration(minutes: 10),
      );

      expect(buffer.isComplete(currentTime), true);
    });

    test('assessment is complete after more than 10 minutes', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      final currentTime = startTime.add(
        const Duration(minutes: 12),
      );

      expect(buffer.isComplete(currentTime), true);
    });

    test('clear removes all readings and resets assessment', () {
      final buffer = AssessmentBuffer();

      final startTime = DateTime(2026, 9, 4, 10, 0, 0);

      buffer.start(startTime);

      buffer.addReading(
        timestamp: startTime,
        bpm: 105,
        spo2: 98,
        temperature: 38.5,
        respiratoryRate: 25,
      );

      expect(buffer.readingCount, 1);
      expect(buffer.startTime, startTime);

      buffer.clear();

      expect(buffer.readingCount, 0);
      expect(buffer.hasReadings, false);
      expect(buffer.startTime, isNull);
    });

    test('cannot add a reading before assessment starts', () {
      final buffer = AssessmentBuffer();

      expect(
        () => buffer.addReading(
          timestamp: DateTime(2026, 9, 4, 10, 0, 0),
          bpm: 105,
          spo2: 98,
          temperature: 38.5,
          respiratoryRate: 25,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
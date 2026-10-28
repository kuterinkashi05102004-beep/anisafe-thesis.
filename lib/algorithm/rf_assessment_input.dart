
class RfAssessmentInput {
  final String species;
  final int age;
  final String ageGroup;

  final double bpm;
  final double spo2;
  final double temperature;
  final int respiratoryRate;

  final String triggerFinding;

  const RfAssessmentInput({
    required this.species,
    required this.age,
    required this.ageGroup,
    required this.bpm,
    required this.spo2,
    required this.temperature,
    required this.respiratoryRate,
    required this.triggerFinding,
  });

  Map<String, dynamic> toMap() {
    return {
      'Species': species,
      'Age': age,
      'Age Group': ageGroup,
      'BPM': bpm,
      'SpO2': spo2,
      'Temperature': temperature,
      'Respiratory Rate': respiratoryRate,
      'Trigger Finding': triggerFinding,
    };
  }

  @override
  String toString() {
    return '''
RF ASSESSMENT INPUT
Species: $species
Age: $age
Age Group: $ageGroup
BPM: $bpm
SpO2: $spo2
Temperature: $temperature
Respiratory Rate: $respiratoryRate
Trigger Finding: $triggerFinding
''';
  }
}
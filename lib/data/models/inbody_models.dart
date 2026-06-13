class InBodyMeasurement {
  final String id;
  final double weightKg;
  final double muscleMassKg;
  final double bodyFatPercentage;
  final double? bodyWaterPercentage;
  final int? visceralFatLevel;
  final int? bmr;
  final double bodyScore;
  final String? coachNotes;
  final List<String> scanPhotoUrls;
  final String recordedAt;
  final String? trend;

  InBodyMeasurement({
    required this.id,
    required this.weightKg,
    required this.muscleMassKg,
    required this.bodyFatPercentage,
    this.bodyWaterPercentage,
    this.visceralFatLevel,
    this.bmr,
    required this.bodyScore,
    this.coachNotes,
    this.scanPhotoUrls = const [],
    required this.recordedAt,
    this.trend,
  });

  factory InBodyMeasurement.fromJson(Map<String, dynamic> j) => InBodyMeasurement(
        id: j['id'],
        weightKg: (j['weightKg'] as num).toDouble(),
        muscleMassKg: (j['muscleMassKg'] as num).toDouble(),
        bodyFatPercentage: (j['bodyFatPercentage'] as num).toDouble(),
        bodyWaterPercentage: j['bodyWaterPercentage'] != null
            ? (j['bodyWaterPercentage'] as num).toDouble()
            : null,
        visceralFatLevel: j['visceralFatLevel'],
        bmr: j['bmr'],
        bodyScore: (j['bodyScore'] as num).toDouble(),
        coachNotes: j['coachNotes'],
        scanPhotoUrls: j['scanPhotoUrls'] != null
            ? List<String>.from(j['scanPhotoUrls'] as List)
            : const [],
        recordedAt: j['recordedAt'],
        trend: j['trend'],
      );
}

class AddInBodyRequest {
  final String traineeId;
  final double weightKg;
  final double muscleMassKg;
  final double bodyFatPercentage;
  final double? bodyWaterPercentage;
  final int? visceralFatLevel;
  final int? bmr;
  final String? coachNotes;
  final List<String> scanPhotoUrls;

  AddInBodyRequest({
    required this.traineeId,
    required this.weightKg,
    required this.muscleMassKg,
    required this.bodyFatPercentage,
    this.bodyWaterPercentage,
    this.visceralFatLevel,
    this.bmr,
    this.coachNotes,
    this.scanPhotoUrls = const [],
  });

  Map<String, dynamic> toJson() => {
        'traineeId': traineeId,
        'weightKg': weightKg,
        'muscleMassKg': muscleMassKg,
        'bodyFatPercentage': bodyFatPercentage,
        if (bodyWaterPercentage != null) 'bodyWaterPercentage': bodyWaterPercentage,
        if (visceralFatLevel != null) 'visceralFatLevel': visceralFatLevel,
        if (bmr != null) 'bmr': bmr,
        if (coachNotes != null) 'coachNotes': coachNotes,
        'scanPhotoUrls': scanPhotoUrls,
      };
}

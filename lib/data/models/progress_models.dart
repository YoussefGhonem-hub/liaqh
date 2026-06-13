class ProgressEntry {
  final String id;
  final String recordedAt;
  final String? createdAt;
  final String? title;
  final String? notes;
  final List<String> photoUrls;
  final String uploaderName;
  final bool uploadedByCoach;

  ProgressEntry({
    required this.id,
    required this.recordedAt,
    this.createdAt,
    this.title,
    this.notes,
    this.photoUrls = const [],
    this.uploaderName = 'Trainee',
    this.uploadedByCoach = false,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> j) => ProgressEntry(
        id: j['id'],
        recordedAt: j['recordedAt'],
        createdAt: j['createdAt'],
        title: j['title'],
        notes: j['notes'],
        photoUrls: j['photoUrls'] != null
            ? List<String>.from(j['photoUrls'] as List)
            : const [],
        uploaderName: j['uploaderName'] ?? 'Trainee',
        uploadedByCoach: j['uploadedByCoach'] ?? false,
      );
}

class AddProgressRequest {
  final String traineeId;
  final String? title;
  final String? notes;
  final List<String> photoUrls;
  final String? coachUserId;
  final String? coachName;

  AddProgressRequest({
    required this.traineeId,
    this.title,
    this.notes,
    this.photoUrls = const [],
    this.coachUserId,
    this.coachName,
  });

  Map<String, dynamic> toJson() => {
        'traineeId': traineeId,
        if (title != null) 'title': title,
        if (notes != null) 'notes': notes,
        'photoUrls': photoUrls,
      };
}

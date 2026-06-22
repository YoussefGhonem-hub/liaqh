class CoachCertification {
  final String id;
  final String title;
  final String? issuer;
  final int? year;
  final String? imageUrl;

  CoachCertification({
    required this.id,
    required this.title,
    this.issuer,
    this.year,
    this.imageUrl,
  });

  factory CoachCertification.fromJson(Map<String, dynamic> j) =>
      CoachCertification(
        id: j['id'],
        title: j['title'] ?? '',
        issuer: j['issuer'],
        year: j['year'],
        imageUrl: j['imageUrl'],
      );
}

class CoachTransformation {
  final String id;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final String? caption;
  final String? durationText;

  CoachTransformation({
    required this.id,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.caption,
    this.durationText,
  });

  factory CoachTransformation.fromJson(Map<String, dynamic> j) =>
      CoachTransformation(
        id: j['id'],
        beforeImageUrl: j['beforeImageUrl'],
        afterImageUrl: j['afterImageUrl'],
        caption: j['caption'],
        durationText: j['durationText'],
      );
}

class CoachFile {
  final String id;
  final String fileName;
  final String url;

  CoachFile({required this.id, required this.fileName, required this.url});

  factory CoachFile.fromJson(Map<String, dynamic> j) => CoachFile(
        id: j['id'],
        fileName: j['fileName'] ?? '',
        url: j['url'] ?? '',
      );
}

class CoachReview {
  final String id;
  final String traineeId;
  final String traineeName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  CoachReview({
    required this.id,
    required this.traineeId,
    required this.traineeName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory CoachReview.fromJson(Map<String, dynamic> j) => CoachReview(
        id: j['id'],
        traineeId: j['traineeId'],
        traineeName: j['traineeName'] ?? '',
        rating: j['rating'] ?? 0,
        comment: j['comment'],
        createdAt:
            DateTime.tryParse(j['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
      );
}

class CoachProfile {
  final String coachId;
  final String userId;
  final String fullName;
  final String? profileImageUrl;
  final String? headline;
  final String? bio;
  final int? yearsOfExperience;
  final String? specialties;
  final String? instagramUrl;
  final String? whatsappNumber;
  final int traineesCoached;
  final int transformationsCount;
  final double averageRating;
  final int reviewCount;
  final List<CoachCertification> certifications;
  final List<CoachTransformation> transformations;
  final List<CoachFile> files;
  final List<CoachReview> reviews;
  final int? myRating;
  final String? myReview;

  CoachProfile({
    required this.coachId,
    required this.userId,
    required this.fullName,
    this.profileImageUrl,
    this.headline,
    this.bio,
    this.yearsOfExperience,
    this.specialties,
    this.instagramUrl,
    this.whatsappNumber,
    this.traineesCoached = 0,
    this.transformationsCount = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.certifications = const [],
    this.transformations = const [],
    this.files = const [],
    this.reviews = const [],
    this.myRating,
    this.myReview,
  });

  /// Specialty tags split from the comma-separated string.
  List<String> get specialtyTags => (specialties ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  factory CoachProfile.fromJson(Map<String, dynamic> j) => CoachProfile(
        coachId: j['coachId'],
        userId: j['userId'],
        fullName: j['fullName'] ?? '',
        profileImageUrl: j['profileImageUrl'],
        headline: j['headline'],
        bio: j['bio'],
        yearsOfExperience: j['yearsOfExperience'],
        specialties: j['specialties'],
        instagramUrl: j['instagramUrl'],
        whatsappNumber: j['whatsappNumber'],
        traineesCoached: j['traineesCoached'] ?? 0,
        transformationsCount: j['transformationsCount'] ?? 0,
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0,
        reviewCount: j['reviewCount'] ?? 0,
        certifications: (j['certifications'] as List? ?? [])
            .map((e) => CoachCertification.fromJson(e))
            .toList(),
        transformations: (j['transformations'] as List? ?? [])
            .map((e) => CoachTransformation.fromJson(e))
            .toList(),
        files: (j['files'] as List? ?? [])
            .map((e) => CoachFile.fromJson(e))
            .toList(),
        reviews: (j['reviews'] as List? ?? [])
            .map((e) => CoachReview.fromJson(e))
            .toList(),
        myRating: j['myRating'],
        myReview: j['myReview'],
      );
}

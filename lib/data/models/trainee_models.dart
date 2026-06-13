class TraineeSummary {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String goal;
  final double heightCm;
  final double currentWeightKg;
  final double? latestBodyScore;
  final String? membershipStatus;

  TraineeSummary({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    required this.goal,
    required this.heightCm,
    required this.currentWeightKg,
    this.latestBodyScore,
    this.membershipStatus,
  });

  factory TraineeSummary.fromJson(Map<String, dynamic> j) => TraineeSummary(
        id: j['id'],
        userId: j['userId'] ?? '',
        fullName: j['fullName'],
        email: j['email'],
        profileImageUrl: j['profileImageUrl'],
        goal: j['goal'],
        heightCm: (j['heightCm'] as num).toDouble(),
        currentWeightKg: (j['currentWeightKg'] as num).toDouble(),
        latestBodyScore: j['latestBodyScore'] != null
            ? (j['latestBodyScore'] as num).toDouble()
            : null,
        membershipStatus: j['membershipStatus'],
      );
}

class TraineeDetail {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String goal;
  final double heightCm;
  final double currentWeightKg;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final String? profileImageUrl;
  final int? age;
  final double? latestBodyScore;
  // Coach details
  final String? coachUserId;
  final String? coachName;
  final String? coachEmail;
  final String? coachPhoneNumber;
  final String? coachBio;
  final String? coachSpecialization;
  final String? coachImageUrl;

  TraineeDetail({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.goal,
    required this.heightCm,
    required this.currentWeightKg,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.profileImageUrl,
    this.age,
    this.latestBodyScore,
    this.coachUserId,
    this.coachName,
    this.coachEmail,
    this.coachPhoneNumber,
    this.coachBio,
    this.coachSpecialization,
    this.coachImageUrl,
  });

  factory TraineeDetail.fromJson(Map<String, dynamic> j) => TraineeDetail(
        id: j['id'],
        userId: j['userId'],
        fullName: j['fullName'],
        email: j['email'],
        phoneNumber: j['phoneNumber'],
        goal: j['goal'],
        heightCm: (j['heightCm'] as num).toDouble(),
        currentWeightKg: (j['currentWeightKg'] as num).toDouble(),
        dietaryRestrictions: j['dietaryRestrictions'],
        medicalNotes: j['medicalNotes'],
        profileImageUrl: j['profileImageUrl'],
        age: j['age'] != null ? (j['age'] as num).toInt() : null,
        latestBodyScore: j['latestBodyScore'] != null
            ? (j['latestBodyScore'] as num).toDouble()
            : null,
        coachUserId: j['coachUserId'],
        coachName: j['coachName'],
        coachEmail: j['coachEmail'],
        coachPhoneNumber: j['coachPhoneNumber'],
        coachBio: j['coachBio'],
        coachSpecialization: j['coachSpecialization'],
        coachImageUrl: j['coachImageUrl'],
      );
}

class CreateTraineeRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String goal;
  final double heightCm;
  final double currentWeightKg;
  final String? dateOfBirth;
  final String? dietaryRestrictions;
  final String? medicalNotes;
  final String? phoneNumber;

  CreateTraineeRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.goal,
    required this.heightCm,
    required this.currentWeightKg,
    this.dateOfBirth,
    this.dietaryRestrictions,
    this.medicalNotes,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'goal': goal,
        'heightCm': heightCm,
        'currentWeightKg': currentWeightKg,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (dietaryRestrictions != null) 'dietaryRestrictions': dietaryRestrictions,
        if (medicalNotes != null) 'medicalNotes': medicalNotes,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

class AuthResult {
  final String token;
  final String? refreshToken;
  final String userId;
  final String role;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String gymId;
  final String? tenantId;
  final bool isPersonalGym; // true → individual coach (may self-create trainees)
  final String? gymLogoUrl;
  final String? profileImageUrl;

  AuthResult({
    required this.token,
    this.refreshToken,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gymId,
    this.tenantId,
    this.isPersonalGym = false,
    this.gymLogoUrl,
    this.profileImageUrl,
  });

  factory AuthResult.fromJson(Map<String, dynamic> j) {
    final first = j['firstName'] ?? '';
    final last  = j['lastName']  ?? '';
    return AuthResult(
      token: j['token'] ?? '',
      refreshToken: j['refreshToken'],
      userId: j['userId']?.toString() ?? '',
      role: j['role'] ?? '',
      fullName: (j['fullName'] as String?)?.isNotEmpty == true
          ? j['fullName']
          : '$first $last'.trim(),
      firstName: first,
      lastName: last,
      email: j['email'] ?? '',
      gymId: j['gymId']?.toString() ?? '',
      tenantId: j['tenantId']?.toString(),
      isPersonalGym: j['isPersonalGym'] as bool? ?? false,
      gymLogoUrl: j['gymLogoUrl']?.toString(),
      profileImageUrl: j['profileImageUrl']?.toString(),
    );
  }

  bool get isGymAdmin => role == 'GymAdmin';
  bool get isCoach => role == 'Coach';
  bool get isTrainee => role == 'Trainee';
  bool get isPlatformOwner => role == 'PlatformOwner';

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'userId': userId,
    'role': role,
    'fullName': fullName,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'gymId': gymId,
    'tenantId': tenantId,
    'isPersonalGym': isPersonalGym,
    'gymLogoUrl': gymLogoUrl,
    'profileImageUrl': profileImageUrl,
  };
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterIndividualCoachRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? bio;

  RegisterIndividualCoachRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (bio != null) 'bio': bio,
      };
}

class RegisterCoachRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String gymId;
  final String? phoneNumber;
  final String? bio;

  RegisterCoachRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.gymId,
    this.phoneNumber,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'gymId': gymId,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (bio != null) 'bio': bio,
      };
}

// Result from POST /auth/register/gym (includes gym info + admin token)
class RegisterGymResult {
  final String gymId;
  final String gymName;
  final String? gymLogoUrl;
  final AuthResult admin;

  RegisterGymResult({
    required this.gymId,
    required this.gymName,
    this.gymLogoUrl,
    required this.admin,
  });

  factory RegisterGymResult.fromJson(Map<String, dynamic> j) => RegisterGymResult(
        gymId: j['gymId']?.toString() ?? '',
        gymName: j['gymName'] ?? '',
        gymLogoUrl: j['gymLogoUrl'],
        admin: AuthResult.fromJson(j['admin']),
      );
}

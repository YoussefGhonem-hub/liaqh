import 'package:fitnessapp/data/models/trainee_models.dart';
import 'package:fitnessapp/data/repositories/trainee_repository.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/trainees/trainee_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Loads the logged-in trainee's own profile, then renders the rich tabbed
/// detail view (Profile · Membership · InBody · Workout · Nutrition · Progress).
class MyDetailsScreen extends StatefulWidget {
  static const routeName = '/MyDetailsScreen';

  /// Which tab to open first (0 profile, 3 workout, 4 nutrition, etc.)
  final int initialTab;
  const MyDetailsScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  late Future<TraineeDetail> _future;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    _future = TraineeRepository(api).getMyProfile();
  }

  void _retry() {
    setState(() {
      final api = context.read<ApiService>();
      _future = TraineeRepository(api).getMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FutureBuilder<TraineeDetail>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: colors.bg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: colors.bg,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 56, color: colors.mutedFg),
                  const SizedBox(height: 12),
                  Text('Could not load your profile',
                      style: TextStyle(color: colors.fg, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor1,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final t = snapshot.data!;
        return TraineeDetailScreen(
          traineeId: t.id,
          traineeName: t.fullName,
          goal: t.goal,
          heightCm: t.heightCm,
          currentWeightKg: t.currentWeightKg,
          latestBodyScore: t.latestBodyScore,
          dietaryRestrictions: t.dietaryRestrictions,
          medicalNotes: t.medicalNotes,
          initialTab: widget.initialTab,
          readOnly: true,
          traineeUserId: t.userId,
          profileImageUrl: t.profileImageUrl,
          coachUserId: t.coachUserId,
          coachName: t.coachName,
          coachEmail: t.coachEmail,
          coachPhoneNumber: t.coachPhoneNumber,
          coachBio: t.coachBio,
          coachSpecialization: t.coachSpecialization,
          coachImageUrl: t.coachImageUrl,
        );
      },
    );
  }
}

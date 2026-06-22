import 'package:fitnessapp/l10n/app_localizations.dart';

/// Localized label for a subscription / membership status value.
/// Accepts the raw backend value (e.g. "Active", "Frozen") in any case.
String subStatusLabel(AppLocalizations l10n, String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'active':
      return l10n.subStatusActive;
    case 'frozen':
      return l10n.subStatusFrozen;
    case 'expired':
      return l10n.subStatusExpired;
    case 'cancelled':
    case 'canceled':
      return l10n.subStatusCancelled;
    case 'pending':
      return l10n.subStatusPending;
    case 'none':
    case '':
      return l10n.subStatusNone;
    default:
      return status ?? '';
  }
}

/// Localized label for a payment-period status value (Paid / Unpaid / Free).
String payStatusLabel(AppLocalizations l10n, String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'paid':
      return l10n.payStatusPaid;
    case 'unpaid':
      return l10n.payStatusUnpaid;
    case 'free':
      return l10n.payStatusFree;
    default:
      return status ?? '';
  }
}

/// Localized label for a manual payment-request status (Pending/Accepted/Rejected).
String payRequestStatusLabel(AppLocalizations l10n, String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'pending':
      return l10n.subStatusPending;
    case 'accepted':
      return l10n.statusAccepted;
    case 'rejected':
      return l10n.statusRejected;
    default:
      return status ?? '';
  }
}

/// Localized label for a user role (PlatformOwner/GymAdmin/Coach/Trainee).
String roleLabel(AppLocalizations l10n, String? role) {
  switch ((role ?? '').toLowerCase()) {
    case 'platformowner':
      return l10n.rolePlatformOwner;
    case 'gymadmin':
      return l10n.roleGymAdmin;
    case 'coach':
      return l10n.roleCoach;
    case 'trainee':
      return l10n.roleTrainee;
    default:
      return role ?? '';
  }
}

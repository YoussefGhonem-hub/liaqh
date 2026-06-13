import 'package:fitnessapp/utils/app_alerts.dart';
import 'package:flutter/material.dart';

/// Mix into any State class to get [runWithAlert] — wraps an async action,
/// shows a success or error sweet-alert automatically.
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  Future<bool> runWithAlert(
    Future<void> Function() action, {
    String? successMessage,
    String? successTitle,
  }) async {
    try {
      await action();
      if (successMessage != null && mounted) {
        AppAlerts.success(context, successMessage, title: successTitle);
      }
      return true;
    } catch (e) {
      if (mounted) AppAlerts.handleError(context, e);
      return false;
    }
  }
}

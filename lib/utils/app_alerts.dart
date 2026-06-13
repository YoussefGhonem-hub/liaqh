import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppAlerts {
  // ── Success ───────────────────────────────────────────────────────────────
  static void success(BuildContext context, String message, {String? title}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: title ?? 'Success',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: const Color(0xFF4CAF50),
    ).show();
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  static void error(BuildContext context, String message, {String? title}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title ?? 'Error',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: const Color(0xFFE53935),
    ).show();
  }

  // ── Warning ───────────────────────────────────────────────────────────────
  static void warning(BuildContext context, String message, {String? title}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title ?? 'Warning',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: const Color(0xFFF57C00),
    ).show();
  }

  // ── Handle any DioException / API error automatically ─────────────────────
  static void handleError(BuildContext context, Object error) {
    if (!context.mounted) return;

    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;

      // Extract message from backend response
      String message = _extractMessage(data);

      if (status == 401) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.scale,
          title: 'Unauthorized',
          desc: 'Your session has expired. Please log in again.',
          btnOkOnPress: () {},
          btnOkColor: const Color(0xFFF57C00),
        ).show();
      } else if (status == 403) {
        AppAlerts.error(context, 'You do not have permission to perform this action.', title: 'Forbidden');
      } else if (status == 400) {
        AppAlerts.error(context, message.isNotEmpty ? message : 'Invalid request. Please check your input.', title: 'Bad Request');
      } else if (status == 404) {
        AppAlerts.error(context, message.isNotEmpty ? message : 'The requested resource was not found.', title: 'Not Found');
      } else if (status == 409) {
        AppAlerts.warning(context, message.isNotEmpty ? message : 'A conflict occurred.', title: 'Conflict');
      } else if (status != null && status >= 500) {
        AppAlerts.error(context, 'Server error. Please try again later.', title: 'Server Error');
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        AppAlerts.error(context, 'Connection timed out. Check your internet connection.', title: 'Timeout');
      } else if (error.type == DioExceptionType.connectionError) {
        AppAlerts.error(context, 'Cannot reach the server. Make sure the backend is running.', title: 'No Connection');
      } else {
        AppAlerts.error(context, message.isNotEmpty ? message : 'An unexpected error occurred.', title: 'Error');
      }
    } else {
      AppAlerts.error(context, error.toString(), title: 'Error');
    }
  }

  // ── Extract readable message from backend response body ───────────────────
  static String _extractMessage(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map) {
      // FluentValidation: { errors: { field: [msg] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = errors.values
            .expand((v) => v is List ? v : [v])
            .map((e) => e.toString())
            .toList();
        return messages.join('\n');
      }
      // Standard: { message: "..." } or { title: "..." }
      return (data['message'] ?? data['title'] ?? '').toString();
    }
    return '';
  }
}

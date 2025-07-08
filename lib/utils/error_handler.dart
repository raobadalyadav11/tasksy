import 'package:flutter/material.dart';
import '../services/popup_service.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? _getErrorMessage(error);
    PopupService.showErrorFlushbar(context, message);
  }

  static void handleNetworkError(BuildContext context) {
    PopupService.showNetworkError(context);
  }

  static void handleStorageError(BuildContext context) {
    PopupService.showErrorFlushbar(
      context, 
      'Failed to save data. Please try again.',
      title: 'Storage Error'
    );
  }

  static void handleNotificationError(BuildContext context) {
    PopupService.showErrorFlushbar(
      context,
      'Failed to schedule notification. Please check notification permissions.',
      title: 'Notification Error'
    );
  }

  static String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  static void showSuccess(BuildContext context, String message) {
    PopupService.showSuccessFlushbar(context, message);
  }

  static void showInfo(BuildContext context, String message) {
    PopupService.showInfoFlushbar(context, message);
  }

  static void showWarning(BuildContext context, String message) {
    PopupService.showWarningFlushbar(context, message);
  }
}
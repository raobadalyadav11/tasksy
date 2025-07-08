import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';

class PopupService {
  // Fancy top/bottom popups using another_flushbar
  static void showSuccessFlushbar(BuildContext context, String message, {String? title}) {
    Flushbar(
      title: title ?? 'Success',
      message: message,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  static void showErrorFlushbar(BuildContext context, String message, {String? title}) {
    Flushbar(
      title: title ?? 'Error',
      message: message,
      icon: const Icon(Icons.error, color: Colors.white),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  static void showInfoFlushbar(BuildContext context, String message, {String? title}) {
    Flushbar(
      title: title ?? 'Info',
      message: message,
      icon: const Icon(Icons.info, color: Colors.white),
      backgroundColor: const Color(0xFF4A90E2),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  static void showWarningFlushbar(BuildContext context, String message, {String? title}) {
    Flushbar(
      title: title ?? 'Warning',
      message: message,
      icon: const Icon(Icons.warning, color: Colors.white),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  static void showBottomFlushbar(BuildContext context, String message, {String? title, Color? backgroundColor}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? const Color(0xFF4A90E2),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.BOTTOM,
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 300),
    ).show(context);
  }

  // Android-style toasts using fluttertoast
  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showLongToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Notification-like overlays using overlay_support
  static void showNotificationOverlay(String title, String message, {VoidCallback? onTap}) {
    showOverlayNotification(
      (context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications, color: Colors.white, size: 20),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(message),
            trailing: const Icon(Icons.close, size: 20),
            onTap: () {
              OverlaySupportEntry.of(context)?.dismiss();
              onTap?.call();
            },
          ),
        );
      },
      duration: const Duration(seconds: 4),
      position: NotificationPosition.top,
    );
  }

  static void showTaskCompletionOverlay(String taskTitle) {
    showOverlayNotification(
      (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Task Completed! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      taskTitle,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      duration: const Duration(seconds: 3),
      position: NotificationPosition.top,
    );
  }

  static void showHabitStreakOverlay(String habitName, int streak) {
    showOverlayNotification(
      (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak Day Streak! 🔥',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      habitName,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      duration: const Duration(seconds: 4),
      position: NotificationPosition.top,
    );
  }

  static void showCustomOverlay({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    showOverlayNotification(
      (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              OverlaySupportEntry.of(context)?.dismiss();
              onTap?.call();
            },
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      duration: duration,
      position: NotificationPosition.top,
    );
  }

  // Utility methods for common scenarios
  static void showTaskCreated(BuildContext context, String taskTitle) {
    showSuccessFlushbar(context, 'Task "$taskTitle" created successfully');
  }

  static void showTaskDeleted(BuildContext context, String taskTitle) {
    showWarningFlushbar(context, 'Task "$taskTitle" deleted');
  }

  static void showHabitCreated(BuildContext context, String habitName) {
    showSuccessFlushbar(context, 'Habit "$habitName" created successfully');
  }

  static void showDataSaved(BuildContext context) {
    showToast('Data saved successfully');
  }

  static void showError(BuildContext context, String error) {
    showErrorFlushbar(context, error);
  }

  static void showNetworkError(BuildContext context) {
    showErrorFlushbar(context, 'Network error. Please check your connection.');
  }
}
import 'package:flutter/material.dart';

class HotelErrorHandler {
  static void handleError(
    BuildContext context,
    String error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    String message = customMessage ?? _getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static String _getErrorMessage(String error) {
    if (error.contains('Network error')) {
      return 'Network connection problem. Please check your internet connection.';
    } else if (error.contains('Access denied. Only owners can create hotels')) {
      return 'Permission denied. Only hotel owners can create hotels.';
    } else if (error.contains('Access denied. Only owners can update hotels')) {
      return 'Permission denied. Only hotel owners can update hotels.';
    } else if (error.contains('Access denied. Only owners can delete hotels')) {
      return 'Permission denied. Only hotel owners can delete hotels.';
    } else if (error.contains('Failed to load hotels')) {
      return 'Unable to load hotels. Please try again.';
    } else if (error.contains('Failed to create hotel')) {
      return 'Unable to create hotel. Please check your information and try again.';
    } else if (error.contains('Failed to update hotel')) {
      return 'Unable to update hotel. Please try again.';
    } else if (error.contains('Failed to delete hotel')) {
      return 'Unable to delete hotel. Please try again.';
    } else if (error.contains('404')) {
      return 'Hotel not found.';
    } else if (error.contains('401') || error.contains('403')) {
      return 'Authentication error. Please log in again.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showValidationErrors(BuildContext context, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Validation Errors'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDestructive ? Icons.warning : Icons.help,
              color: isDestructive ? Colors.red[600] : Colors.blue[600],
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red[600] : null,
            ),
            child: Text(
              confirmText,
              style: TextStyle(color: isDestructive ? Colors.white : null),
            ),
          ),
        ],
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

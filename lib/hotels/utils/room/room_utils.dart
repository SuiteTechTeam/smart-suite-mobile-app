import 'package:flutter/material.dart';

IconData getStatusIcon(String state) {
  switch (state.toLowerCase()) {
    case 'ocupado':
      return Icons.close;
    case 'disponible':
      return Icons.check;
    default:
      return Icons.help_outline;
  }
}

Color getStatusColor(String state) {
  switch (state.toLowerCase()) {
    case 'ocupado':
      return Colors.red;
    case 'disponible':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

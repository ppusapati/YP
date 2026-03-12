import 'package:flutter/material.dart';

import '../../domain/entities/alert_entity.dart';

class SeverityIcon extends StatelessWidget {
  const SeverityIcon({
    super.key,
    required this.severity,
    this.size = 24.0,
  });

  final AlertSeverity severity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      color: _color,
      size: size,
    );
  }

  IconData get _icon {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.critical:
        return Icons.error_outline;
    }
  }

  Color get _color {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFF0288D1);
      case AlertSeverity.warning:
        return const Color(0xFFF9A825);
      case AlertSeverity.critical:
        return const Color(0xFFD32F2F);
    }
  }

  static Color colorForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFF0288D1);
      case AlertSeverity.warning:
        return const Color(0xFFF9A825);
      case AlertSeverity.critical:
        return const Color(0xFFD32F2F);
    }
  }

  static Color backgroundColorForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFFB3E5FC);
      case AlertSeverity.warning:
        return const Color(0xFFFFF9C4);
      case AlertSeverity.critical:
        return const Color(0xFFFCDAD6);
    }
  }
}

import 'package:flutter/material.dart';

/// Shows a success or error message after a download completes/fails.
class StatusMessageCard extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const StatusMessageCard({
    super.key,
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? Colors.green : Colors.redAccent;
    final iconColor = isSuccess ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: iconColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

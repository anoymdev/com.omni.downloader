import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

/// Shows download progress bar, speed, and bytes downloaded/total.
class DownloadProgressCard extends StatelessWidget {
  final String phase;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double speed;
  final bool isStalled;

  const DownloadProgressCard({
    super.key,
    required this.phase,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.isStalled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase label + percentage.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isStalled)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.hourglass_top,
                            color: Colors.amber, size: 14),
                      ),
                    Expanded(
                      child: Text(
                        phase,
                        style: TextStyle(
                          color: isStalled ? Colors.amber : Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (progress > 0 && progress < 1)
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalBytes > 0 ? progress : null,
              minHeight: 7,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isStalled ? Colors.amber : colors.primary),
            ),
          ),
          // Downloaded / total and speed.
          if (totalBytes > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatBytes(downloadedBytes)} / ${formatBytes(totalBytes)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  formatSpeed(speed),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

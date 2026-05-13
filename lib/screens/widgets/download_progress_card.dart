import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isStalled ? Colors.amber.withValues(alpha: 0.1) : colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isStalled ? Icons.hourglass_empty_rounded : Icons.cloud_download_outlined,
                  color: isStalled ? Colors.amber : colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase,
                      style: TextStyle(
                        color: isStalled ? Colors.amber : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (totalBytes > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${formatBytes(downloadedBytes)} / ${formatBytes(totalBytes)} • ${formatSpeed(speed)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (progress > 0 && progress < 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalBytes > 0 ? progress : null,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isStalled ? Colors.amber : colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

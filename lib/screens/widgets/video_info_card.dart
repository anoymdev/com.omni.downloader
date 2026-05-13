import 'package:flutter/material.dart';
import '../../models/video_metadata.dart';
import '../../utils/formatters.dart';

class VideoInfoCard extends StatelessWidget {
  final VideoMetadata video;

  const VideoInfoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'thumbnail_${video.title}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: video.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      video.thumbnailUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackIcon(),
                    )
                  : _fallbackIcon(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        video.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (video.duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(video.duration!),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.play_circle_fill_rounded,
          color: Color(0xFF7C4DFF), size: 40),
    );
  }
}

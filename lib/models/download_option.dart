/// Represents a single downloadable stream option.
///
/// Used by both the UI (for display) and the download service (for downloading).
class DownloadOption {
  /// The primary format ID (from yt-dlp).
  final String formatId;

  /// Optional separate audio format ID. Non-null when the primary is
  /// video-only and needs to be merged with audio via FFmpeg.
  final String? audioFormatId;

  /// File extension for this format (e.g. "mp4", "webm", "m4a").
  final String ext;

  /// Whether FFmpeg merge is needed (video-only + separate audio).
  final bool needsMerge;

  /// Short tag used for filename suffix, e.g. "720p_vo_mp4", "128kbps_audio".
  final String tag;

  /// Whether this option is an audio-only download.
  final bool isAudioOnly;

  /// Human-readable label for the UI dropdown.
  final String label;

  /// Index in the flat list — must match between UI and service.
  final int globalIndex;

  const DownloadOption({
    required this.formatId,
    this.audioFormatId,
    required this.ext,
    required this.needsMerge,
    required this.tag,
    required this.isAudioOnly,
    required this.label,
    required this.globalIndex,
  });
}

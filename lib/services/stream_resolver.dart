import '../models/download_option.dart';
import '../models/video_metadata.dart';
import 'ytdlp_service.dart';

/// Resolves stream options from any video URL using yt-dlp.
///
/// This class encapsulates the logic for fetching and sorting available
/// streams, eliminating the dependency on youtube_explode_dart.
class StreamResolver {
  /// Fetches video metadata and available download options from any URL.
  ///
  /// Returns a record of (VideoMetadata, List of DownloadOption).
  Future<(VideoMetadata, List<DownloadOption>)> resolve(String url) async {
    final info = await YtDlpService.extractInfo(url);
    final metadata = VideoMetadata.fromJson(info);
    final options = _buildOptions(info['formats'] as List<dynamic>? ?? []);
    return (metadata, options);
  }

  /// Parses the yt-dlp formats list into a sorted flat list of
  /// [DownloadOption]s: muxed → video-only (+ best audio) → audio-only.
  List<DownloadOption> _buildOptions(List<dynamic> formats) {
    final List<Map<String, dynamic>> muxed = [];
    final List<Map<String, dynamic>> videoOnly = [];
    final List<Map<String, dynamic>> audioOnly = [];

    for (final raw in formats) {
      final f = raw as Map<String, dynamic>;
      final vcodec = (f['vcodec'] ?? 'none').toString();
      final acodec = (f['acodec'] ?? 'none').toString();
      final hasVideo = vcodec != 'none';
      final hasAudio = acodec != 'none';

      if (hasVideo && hasAudio) {
        muxed.add(f);
      } else if (hasVideo) {
        videoOnly.add(f);
      } else if (hasAudio) {
        audioOnly.add(f);
      }
    }

    // Sort muxed & video-only by resolution (height) descending.
    muxed.sort((a, b) => _height(b).compareTo(_height(a)));
    videoOnly.sort((a, b) => _height(b).compareTo(_height(a)));
    // Sort audio-only by bitrate descending.
    audioOnly.sort((a, b) => _abr(b).compareTo(_abr(a)));

    // Find the best audio stream for merging with video-only.
    final bestAudio = audioOnly.isNotEmpty ? audioOnly.first : null;

    final List<DownloadOption> options = [];
    var idx = 0;

    // --- Muxed streams ---
    final seenMuxedRes = <int>{};
    for (final f in muxed) {
      final h = _height(f);
      if (h > 0 && !seenMuxedRes.add(h)) continue; // deduplicate
      final sizeMb = _sizeMb(f);
      final ext = (f['ext'] ?? 'mp4').toString();
      options.add(DownloadOption(
        formatId: f['format_id'].toString(),
        ext: ext,
        needsMerge: false,
        tag: '${h}p_muxed',
        isAudioOnly: false,
        label: '${h}p  \u00b7  ${ext.toUpperCase()}'
            '  \u00b7  Video+Audio'
            '${sizeMb.isNotEmpty ? "  \u00b7  $sizeMb" : ""}',
        globalIndex: idx++,
      ));
    }

    // --- Video-only streams (needs FFmpeg merge) ---
    final seenVoRes = <int>{};
    for (final f in videoOnly) {
      final h = _height(f);
      if (h > 0 && !seenVoRes.add(h)) continue; // deduplicate
      final sizeMb = _sizeMb(f);
      final ext = (f['ext'] ?? 'mp4').toString();
      options.add(DownloadOption(
        formatId: f['format_id'].toString(),
        audioFormatId: bestAudio?['format_id']?.toString(),
        ext: ext,
        needsMerge: bestAudio != null,
        tag: '${h}p_vo_$ext',
        isAudioOnly: false,
        label: '${h}p  \u00b7  ${ext.toUpperCase()}'
            '  \u00b7  Video+Audio (FFmpeg)'
            '${sizeMb.isNotEmpty ? "  \u00b7  $sizeMb" : ""}',
        globalIndex: idx++,
      ));
    }

    // --- Audio-only streams ---
    final seenAudioBr = <int>{};
    for (final f in audioOnly) {
      final abr = _abr(f);
      if (abr > 0 && !seenAudioBr.add(abr)) continue; // deduplicate
      final sizeMb = _sizeMb(f);
      final ext = (f['ext'] ?? 'm4a').toString();
      options.add(DownloadOption(
        formatId: f['format_id'].toString(),
        ext: ext,
        needsMerge: false,
        tag: '${abr}kbps_audio',
        isAudioOnly: true,
        label: '$abr kbps  \u00b7  ${ext.toUpperCase()}'
            '  \u00b7  Audio Only'
            '${sizeMb.isNotEmpty ? "  \u00b7  $sizeMb" : ""}',
        globalIndex: idx++,
      ));
    }

    return options;
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  int _height(Map<String, dynamic> f) => (f['height'] as num?)?.toInt() ?? 0;

  int _abr(Map<String, dynamic> f) => (f['abr'] as num?)?.toInt() ?? 0;

  String _sizeMb(Map<String, dynamic> f) {
    final size = (f['filesize'] as num?)?.toInt() ?? 0;
    if (size <= 0) return '';
    return '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

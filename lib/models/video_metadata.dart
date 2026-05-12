class VideoMetadata {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration? duration;

  const VideoMetadata({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    this.duration,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    final durSeconds = json['duration'] is num ? (json['duration'] as num).toInt() : 0;
    return VideoMetadata(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Title',
      author: json['uploader']?.toString() ?? 'Unknown Author',
      thumbnailUrl: json['thumbnail']?.toString() ?? '',
      duration: durSeconds > 0 ? Duration(seconds: durSeconds) : null,
    );
  }
}

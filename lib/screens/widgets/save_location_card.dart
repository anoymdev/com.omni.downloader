import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';

/// Displays the currently selected save directory with a button to change it.
class SaveLocationCard extends StatelessWidget {
  final String directoryPath;
  final bool enabled;
  final VoidCallback? onPickDirectory;

  const SaveLocationCard({
    super.key,
    required this.directoryPath,
    this.enabled = true,
    this.onPickDirectory,
  });

  @override
  Widget build(BuildContext context) {
    // Show a user-friendly shortened path.
    final displayPath = _shortenPath(directoryPath);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: Color(0xFF7C4DFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.saveLocation,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayPath,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPickDirectory : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: enabled ? Colors.white70 : Colors.white24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.changeLocation,
                      style: TextStyle(
                        color: enabled ? Colors.white70 : Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortenPath(String path) {
    // Remove common Android storage prefix for readability.
    const prefix = '/storage/emulated/0/';
    if (path.startsWith(prefix)) {
      return path.substring(prefix.length);
    }
    return path;
  }
}

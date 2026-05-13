import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';

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
    final displayPath = _shortenPath(directoryPath);

    return InkWell(
      onTap: enabled ? onPickDirectory : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: Color(0xFF7C4DFF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.saveLocation,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayPath,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: enabled ? Colors.grey : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  String _shortenPath(String path) {
    const prefix = '/storage/emulated/0/';
    if (path.startsWith(prefix)) {
      return path.substring(prefix.length);
    }
    return path;
  }
}

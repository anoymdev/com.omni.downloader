import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';

import '../../models/download_option.dart';

/// Displays the list of available stream options as selectable tiles.
class StreamList extends StatelessWidget {
  final List<DownloadOption> options;
  final DownloadOption? selected;
  final bool isDownloading;
  final ValueChanged<DownloadOption> onSelect;
  final VoidCallback? onDownload;
  final VoidCallback? onCancel;

  const StreamList({
    super.key,
    required this.options,
    required this.selected,
    required this.isDownloading,
    required this.onSelect,
    required this.onDownload,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.selectQuality,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((opt) => _StreamTile(
              option: opt,
              isSelected: selected == opt,
              isDownloading: isDownloading,
              onTap: () => onSelect(opt),
            )),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (isDownloading || selected == null)
                    ? null
                    : onDownload,
                icon: isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  isDownloading ? AppLocalizations.of(context)!.downloading : AppLocalizations.of(context)!.download,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            if (isDownloading) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StreamTile extends StatelessWidget {
  final DownloadOption option;
  final bool isSelected;
  final bool isDownloading;
  final VoidCallback onTap;

  const _StreamTile({
    required this.option,
    required this.isSelected,
    required this.isDownloading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAudio = option.isAudioOnly;
    final isMerge = option.needsMerge;

    return GestureDetector(
      onTap: isDownloading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : const Color(0xFF1C1C1C),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : Colors.white.withValues(alpha: 0.06),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isAudio
                  ? Icons.headphones
                  : isMerge
                      ? Icons.merge_type
                      : Icons.videocam,
              color: isSelected ? colors.primary : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

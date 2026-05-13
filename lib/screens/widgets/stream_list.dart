import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';
import '../../models/download_option.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectQuality,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((opt) => _StreamTile(
              option: opt,
              isSelected: selected == opt,
              isDownloading: isDownloading,
              onTap: () => onSelect(opt),
            )),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: (isDownloading || selected == null)
                      ? null
                      : onDownload,
                  icon: isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    isDownloading ? AppLocalizations.of(context)!.downloading : AppLocalizations.of(context)!.download,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: isDownloading || selected == null ? 0 : 4,
                  ),
                ),
              ),
            ),
            if (isDownloading) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                width: 54,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.close_rounded, size: 24),
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
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : const Color(0xFF18181B),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAudio
                    ? Icons.headphones_rounded
                    : isMerge
                        ? Icons.merge_type_rounded
                        : Icons.videocam_rounded,
                color: isSelected ? colors.primary : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

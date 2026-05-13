import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';

/// URL input field and search button card.
class UrlInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onSearch;

  const UrlInputCard({
    super.key,
    required this.controller,
    required this.enabled,
    required this.isLoading,
    required this.onSearch,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.videoUrlLabel,
              labelStyle: TextStyle(color: colors.primary, fontSize: 14),
              hintText: AppLocalizations.of(context)!.videoUrlHint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: Icon(Icons.link, color: colors.primary, size: 20),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.search, size: 18),
            label: Text(
              isLoading ? AppLocalizations.of(context)!.fetchingData : AppLocalizations.of(context)!.fetchInfo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white10,
              disabledForegroundColor: Colors.white30,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

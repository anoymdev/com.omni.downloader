import 'package:flutter/material.dart';
import 'package:omni_downloader/l10n/app_localizations.dart';

class UrlInputCard extends StatefulWidget {
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
  State<UrlInputCard> createState() => _UrlInputCardState();
}

class _UrlInputCardState extends State<UrlInputCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.videoUrlLabel,
              labelStyle: TextStyle(color: colors.primary.withValues(alpha: 0.8), fontSize: 14),
              hintText: AppLocalizations.of(context)!.videoUrlHint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.link_rounded, color: colors.primary, size: 22),
              suffixIcon: widget.controller.text.isNotEmpty && widget.enabled ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.grey),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
              ) : null,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.5), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => widget.onSearch?.call(),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: widget.onSearch,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.search_rounded, size: 20),
                label: Text(
                  widget.isLoading ? AppLocalizations.of(context)!.fetchingData : AppLocalizations.of(context)!.fetchInfo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: widget.isLoading ? 0 : 4,
                  shadowColor: colors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

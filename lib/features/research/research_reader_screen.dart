import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';
import '../../providers/prefs_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import 'academic_sidebar_callout.dart';

class ResearchReaderScreen extends ConsumerStatefulWidget {
  const ResearchReaderScreen({super.key});

  @override
  ConsumerState<ResearchReaderScreen> createState() => _ResearchReaderScreenState();
}

class _ResearchReaderScreenState extends ConsumerState<ResearchReaderScreen> {
  bool showSidebar = true;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final asyncSections = ref.watch(bookSectionsProvider);
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(userPrefsProvider);
    final textScale = prefs.maybeWhen(data: (value) => value.textScale, orElse: () => 1.0);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.research),
        actions: [
          IconButton(
            icon: Icon(showSidebar ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => showSidebar = !showSidebar),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.searchHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                    onChanged: (value) => setState(() => query = value),
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: l10n.toggleAcademicSidebar,
                  child: IconButton(
                    icon: Icon(showSidebar ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined),
                    onPressed: () => setState(() => showSidebar = !showSidebar),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncSections.when(
                data: (sections) {
                  final filtered = query.isEmpty
                      ? sections
                      : sections.where((section) {
                          final text = '${section.heading}\n${section.body}'.toLowerCase();
                          return text.contains(query.toLowerCase());
                        }).toList();
                  if (filtered.isEmpty) {
                    return EmptyState(message: l10n.emptyState);
                  }
                  final bodyStyle = theme.textTheme.bodyLarge;
                  final headingSmall = theme.textTheme.headlineSmall;
                  final headingMedium = theme.textTheme.titleLarge;
                  final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: bodyStyle?.copyWith(
                      height: 1.6,
                      fontSize: bodyStyle.fontSize != null ? bodyStyle.fontSize! * textScale : null,
                    ),
                    h2: headingSmall?.copyWith(
                      fontSize: headingSmall.fontSize != null ? headingSmall.fontSize! * textScale : null,
                    ),
                    h3: headingMedium?.copyWith(
                      fontSize: headingMedium.fontSize != null ? headingMedium.fontSize! * textScale : null,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
                    ),
                  );
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final section = filtered[index];
                          final words = section.body.split(RegExp(r'\s+')).length;
                          final minutes = (words / 180).clamp(1, 12).round();
                          final content = <Widget>[
                            if (section.heading.isNotEmpty)
                              Text(
                                section.heading,
                                style: headingSmall?.copyWith(
                                  fontSize: headingSmall.fontSize != null
                                      ? headingSmall.fontSize! * textScale
                                      : headingSmall?.fontSize,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 18, color: theme.colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.readingTime(minutes),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MarkdownBody(
                              data: section.body,
                              styleSheet: markdownStyle,
                              selectable: true,
                              shrinkWrap: true,
                            ),
                          ];
                          return AppCard(
                            child: isWide && showSidebar && section.body.contains('[')
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: content,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 2,
                                        child: AcademicSidebarCallout(text: section.body),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...content,
                                      if (showSidebar && section.body.contains('[')) ...[
                                        const SizedBox(height: 16),
                                        AcademicSidebarCallout(text: section.body),
                                      ],
                                    ],
                                  ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorState(message: error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

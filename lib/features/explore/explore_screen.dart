import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/lesson_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/section_header.dart';
import 'search_bar.dart';
import 'tag_chip.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController controller;
  final tags = const ['faith', 'prophets', 'law', 'spirituality', 'interfaith'];
  final sortOptions = const {
    'relevance': 'Relevance',
    'level': 'Level',
    'tradition': 'Tradition',
  };
  String activeTag = '';
  String sort = 'relevance';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _updateQuery(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  List<Widget> _buildTagChips() {
    return tags
        .map(
          (tag) => TagChip(
            label: tag,
            selected: activeTag == tag,
            onSelected: (value) {
              setState(() {
                activeTag = value ? tag : '';
              });
              final next = value ? tag : controller.text;
              controller.value = TextEditingValue(
                text: next,
                selection: TextSelection.collapsed(offset: next.length),
              );
              _updateQuery(next);
            },
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final asyncResults = ref.watch(searchResultsProvider(query));
    final theme = Theme.of(context);
    final tagChipWidgets = _buildTagChips();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.explore)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExploreSearchBar(
                controller: controller,
                hint: l10n.searchHint,
                onChanged: (value) {
                  setState(() => activeTag = '');
                  _updateQuery(value);
                },
                onSubmitted: _updateQuery,
                onClear: () {
                  setState(() => activeTag = '');
                  _updateQuery('');
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tagChipWidgets.length,
                  itemBuilder: (context, index) => tagChipWidgets[index],
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Try combining filters (e.g., "faith beginner") to surface the most relevant study path.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: l10n.searchResults,
                subtitle: query.isEmpty
                    ? 'Browse the catalogue or start typing to see curated recommendations.'
                    : 'Showing tailored lessons for "$query"',
                action: SegmentedButton<String>(
                  segments: sortOptions.entries
                      .map(
                        (entry) => ButtonSegment<String>(
                          value: entry.key,
                          label: Text(entry.value),
                        ),
                      )
                      .toList(growable: false),
                  selected: {sort},
                  onSelectionChanged: (values) {
                    setState(() => sort = values.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: asyncResults.when(
                    data: (lessons) {
                      if (lessons.isEmpty) {
                        return EmptyState(message: l10n.emptyState);
                      }

                      final filtered = activeTag.isEmpty
                          ? lessons
                          : lessons.where((lesson) => lesson.tags.contains(activeTag)).toList();

                      if (filtered.isEmpty) {
                        return EmptyState(
                          message: 'No lessons match "$activeTag" yet. Try a different theme or broaden the search.',
                        );
                      }

                      final sorted = [...filtered];
                      switch (sort) {
                        case 'level':
                          sorted.sort((a, b) => a.level.compareTo(b.level));
                          break;
                        case 'tradition':
                          sorted.sort((a, b) => a.tradition.compareTo(b.tradition));
                          break;
                        default:
                          break;
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 1024
                              ? 3
                              : width > 680
                                  ? 2
                                  : 1;

                          if (crossAxisCount == 1) {
                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: sorted.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final lesson = sorted[index];
                                return _LessonResultCard(lesson: lesson);
                              },
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: width > 1200 ? 1.2 : 1.1,
                            ),
                            itemCount: sorted.length,
                            itemBuilder: (context, index) {
                              final lesson = sorted[index];
                              return _LessonResultCard(lesson: lesson);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => ErrorState(message: error.toString()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonResultCard extends StatelessWidget {
  const _LessonResultCard({required this.lesson});

  final LessonCard lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => GoRouter.of(context).go('/lessons/${lesson.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lesson.title,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(lesson.level.toString().toUpperCase()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lesson.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.apartment, size: 16),
                label: Text(lesson.tradition),
              ),
              ...lesson.tags.map(
                (tag) => Chip(
                  label: Text(tag),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

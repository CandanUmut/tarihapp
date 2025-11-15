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

class LessonListScreen extends ConsumerStatefulWidget {
  const LessonListScreen({super.key});

  @override
  ConsumerState<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends ConsumerState<LessonListScreen> {
  String activeTag = '';
  String activeLevel = 'all';
  String searchTerm = '';
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncCards = ref.watch(lessonCardsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lessons)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => searchTerm = value.toLowerCase()),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: asyncCards.when(
                  data: (lessons) {
                    if (lessons.isEmpty) {
                      return EmptyState(message: l10n.emptyState);
                    }

                    final allTags = lessons
                        .expand((lesson) => lesson.tags)
                        .toSet()
                        .toList()
                      ..sort();
                    final uniqueLevels = lessons
                        .map((lesson) => lesson.level.toLowerCase())
                        .toSet()
                        .toList()
                      ..sort();
                    final levelSegments = ['all', ...uniqueLevels];
                    final effectiveLevel = levelSegments.contains(activeLevel) ? activeLevel : 'all';
                    final queryDisplay = searchController.text.trim();
                    final filtered = lessons.where((lesson) {
                      final matchesTag = activeTag.isEmpty || lesson.tags.contains(activeTag);
                      final matchesLevel =
                          effectiveLevel == 'all' || lesson.level.toLowerCase() == effectiveLevel;
                      final lowerTitle = lesson.title.toLowerCase();
                      final lowerSummary = lesson.summary.toLowerCase();
                      final matchesSearch = searchTerm.isEmpty ||
                          lowerTitle.contains(searchTerm) ||
                          lowerSummary.contains(searchTerm) ||
                          lesson.keyPoints.any((point) => point.toLowerCase().contains(searchTerm));
                      return matchesTag && matchesLevel && matchesSearch;
                    }).toList()
                      ..sort((a, b) => a.title.compareTo(b.title));

                    final selectionLabel = queryDisplay.isEmpty
                        ? 'Showing ${filtered.length} lessons'
                        : 'Found ${filtered.length} results for "$queryDisplay"';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: l10n.lessons,
                          subtitle: selectionLabel,
                          action: SegmentedButton<String>(
                            segments: levelSegments
                                .map(
                                  (level) => ButtonSegment<String>(
                                    value: level,
                                    label: Text(
                                      level == 'all'
                                          ? 'All levels'
                                          : '${level[0].toUpperCase()}${level.substring(1)}',
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            selected: {effectiveLevel},
                            onSelectionChanged: (values) {
                              setState(() => activeLevel = values.first);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allTags.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final tag = allTags[index];
                              final selected = tag == activeTag;
                              return FilterChip(
                                label: Text(tag),
                                selected: selected,
                                onSelected: (value) {
                                  setState(() => activeTag = value ? tag : '');
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filtered.isEmpty
                              ? EmptyState(
                                  message:
                                      'No lessons match these filters yet. Try another tag or broaden the search.',
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    final crossAxisCount = width > 1024
                                        ? 3
                                        : width > 720
                                            ? 2
                                            : 1;

                                    if (crossAxisCount == 1) {
                                      return ListView.separated(
                                        padding: const EdgeInsets.only(bottom: 24),
                                        itemCount: filtered.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final lesson = filtered[index];
                                          return _LessonCard(lesson: lesson);
                                        },
                                      );
                                    }

                                    return GridView.builder(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: width > 1200 ? 1.25 : 1.1,
                                      ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final lesson = filtered[index];
                                        return _LessonCard(lesson: lesson);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ErrorState(message: error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final LessonCard lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.go('/lessons/${lesson.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lesson.title,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 8),
              Chip(label: Text(lesson.level.toUpperCase())),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.account_balance, size: 18),
              const SizedBox(width: 6),
              Text(lesson.tradition, style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: lesson.keyPoints
                .take(3)
                .map(
                  (point) => Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16),
                    label: Text(point),
                  ),
                )
                .toList(growable: false),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...lesson.tags.map((tag) => Chip(label: Text(tag))).toList(growable: false),
              FilledButton.tonal(
                onPressed: () => context.go('/lessons/${lesson.id}'),
                child: const Text('Open lesson'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';
import '../../providers/progress_providers.dart';
import '../../widgets/error_state.dart';

class LessonQuizScreen extends ConsumerStatefulWidget {
  const LessonQuizScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends ConsumerState<LessonQuizScreen> {
  final Map<int, String> answers = {};
  bool submitted = false;
  bool showValidation = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lessonsAsync = ref.watch(lessonCardsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz)),
      body: lessonsAsync.when(
        data: (lessons) {
          final lessonIndex = lessons.indexWhere((element) => element.id == widget.lessonId);
          if (lessonIndex == -1) {
            return const ErrorState(message: 'Lesson not found.');
          }
          final lesson = lessons[lessonIndex];
          final totalQuestions = lesson.quiz.length;
          final correctCount = submitted
              ? List.generate(totalQuestions, (index) => answers[index] == lesson.quiz[index].answer)
                  .where((value) => value)
                  .length
              : 0;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(l10n.lessonQuizTitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: totalQuestions,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final question = lesson.quiz[index];
                      final selected = answers[index];
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Q${index + 1}', style: Theme.of(context).textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text(question.question, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              ...question.options.map(
                                (option) => RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue: selected,
                                  onChanged: submitted
                                      ? null
                                      : (value) => setState(() {
                                            answers[index] = value ?? '';
                                            showValidation = false;
                                          }),
                                ),
                              ),
                              if (submitted)
                                Text(
                                  selected == question.answer
                                      ? l10n.answerCorrect
                                      : '${l10n.answerIncorrect} (${question.answer})',
                                  style: TextStyle(
                                    color: selected == question.answer
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (showValidation && answers.length < totalQuestions)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.quizIncomplete,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 8),
                if (submitted)
                  Text(
                    l10n.quizScore(correctCount, totalQuestions),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: submitted
                      ? () => Navigator.pop(context)
                      : () async {
                          if (answers.length < totalQuestions) {
                            setState(() {
                              showValidation = true;
                            });
                            return;
                          }
                          final correct = List.generate(
                            totalQuestions,
                            (index) => answers[index] == lesson.quiz[index].answer,
                          ).where((value) => value).length;
                          final percent = totalQuestions == 0 ? 0.0 : correct / totalQuestions;
                          setState(() {
                            submitted = true;
                            showValidation = false;
                          });
                          await ref
                              .read(progressControllerProvider.notifier)
                              .mark(contentId: lesson.id, percent: percent);
                        },
                  child: Text(submitted ? l10n.actionContinue : l10n.quiz),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(message: error.toString()),
      ),
    );
  }
}

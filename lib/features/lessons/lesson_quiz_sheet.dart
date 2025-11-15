import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/progress_providers.dart';

class LessonQuizSheet extends ConsumerStatefulWidget {
  const LessonQuizSheet({super.key, required this.lesson});

  final LessonCard lesson;

  @override
  ConsumerState<LessonQuizSheet> createState() => _LessonQuizSheetState();
}

class _LessonQuizSheetState extends ConsumerState<LessonQuizSheet> {
  final Map<int, String> answers = {};
  bool submitted = false;
  bool showValidation = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalQuestions = widget.lesson.quiz.length;
    final correctCount = submitted
        ? List.generate(totalQuestions, (index) => answers[index] == widget.lesson.quiz[index].answer)
            .where((value) => value)
            .length
        : 0;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.lesson.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...List.generate(totalQuestions, (index) {
            final question = widget.lesson.quiz[index];
            final selected = answers[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    selected == question.answer ? l10n.answerCorrect : l10n.answerIncorrect,
                    style: TextStyle(
                      color: selected == question.answer ? Colors.green : Colors.red,
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            );
          }),
          if (showValidation && answers.length < totalQuestions)
            Text(
              l10n.quizIncomplete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (submitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.quizScore(correctCount, totalQuestions),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          const SizedBox(height: 12),
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
                      (index) => answers[index] == widget.lesson.quiz[index].answer,
                    ).where((value) => value).length;
                    final percent = totalQuestions == 0 ? 0.0 : correct / totalQuestions;
                    setState(() {
                      submitted = true;
                      showValidation = false;
                    });
                    final service = await ref.read(progressServiceProvider.future);
                    await service.mark(contentId: widget.lesson.id, percent: percent);
                  },
            child: Text(submitted ? l10n.actionContinue : l10n.quiz),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

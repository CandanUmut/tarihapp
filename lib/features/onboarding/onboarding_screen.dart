import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_provider.dart';
import '../../data/models/user_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/prefs_providers.dart';
import '../../providers/reminder_provider.dart';
import 'daily_goal_select.dart';
import 'language_select.dart';
import 'privacy_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0;
  String lang = 'en';
  int goal = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefsAsync = ref.watch(userPrefsProvider);
    final content = prefsAsync.when(
      data: (prefs) {
        lang = prefs.lang;
        goal = prefs.dailyGoal;
        return _buildContent(context, l10n, prefs);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: content,
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, UserPrefs prefs) {
    final steps = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chooseLanguage, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          LanguageSelect(
            selected: lang,
            englishLabel: l10n.languageEnglish,
            turkishLabel: l10n.languageTurkish,
            onChanged: (value) {
              setState(() => lang = value);
              ref.read(localeProvider.notifier).setLocale(Locale(value));
            },
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dailyGoalTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(l10n.dailyGoalPrompt),
          const SizedBox(height: 16),
          DailyGoalSelect(
            selected: goal,
            onChanged: (value) => setState(() => goal = value),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.privacyNote, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          PrivacyScreen(message: l10n.reminderBanner),
        ],
      ),
    ];
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: steps[step],
          ),
        ),
        Row(
          children: [
            if (step > 0)
              TextButton(
                onPressed: () => setState(() => step -= 1),
                child: const Text('Back'),
              ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                if (step < steps.length - 1) {
                  setState(() => step += 1);
                  return;
                }
                final notifier = ref.read(userPrefsProvider.notifier);
                final updated = prefs.copyWith(
                  lang: lang,
                  dailyGoal: goal,
                  onboardingDone: true,
                );
                await notifier.update(updated);
                ref.read(localeProvider.notifier).setLocale(Locale(lang));
                final reminder = ref.read(reminderServiceProvider);
                if (reminder.isSupportedOnWeb) {
                  await reminder.init();
                  await reminder.scheduleDaily(
                    hour: updated.reminderHour,
                    minute: updated.reminderMinute,
                  );
                }
                if (!mounted) return;
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Text(step == steps.length - 1 ? l10n.finish : l10n.actionContinue),
            ),
          ],
        ),
      ],
    );
  }
}

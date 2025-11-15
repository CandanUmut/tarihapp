import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/prefs_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefsAsync = ref.watch(userPrefsProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: prefsAsync.when(
        data: (prefs) {
          final notifier = ref.read(userPrefsProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: prefs.lang,
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                      DropdownMenuItem(value: 'tr', child: Text(l10n.languageTurkish)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      notifier.update(prefs.copyWith(lang: value));
                      ref.read(localeProvider.notifier).setLocale(Locale(value));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.settingsAppearance, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.auto_awesome),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.wb_sunny_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.nights_stay_outlined),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  ref.read(themeModeProvider.notifier).setTheme(selection.first);
                },
              ),
              const SizedBox(height: 32),
              Text(l10n.settingsReading, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                l10n.textSizeLabel(prefs.textScale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: prefs.textScale,
                min: 0.9,
                max: 1.4,
                divisions: 5,
                label: l10n.textSizeLabel(prefs.textScale),
                onChanged: (value) {
                  notifier.update(prefs.copyWith(textScale: double.parse(value.toStringAsFixed(2))));
                },
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Text(
                  l10n.textSizePreview,
                  textScaleFactor: prefs.textScale,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.dailyGoal, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Slider(
                value: prefs.dailyGoal.toDouble(),
                min: 5,
                max: 45,
                divisions: 8,
                label: l10n.minutesPerDay(prefs.dailyGoal),
                onChanged: (value) {
                  notifier.update(prefs.copyWith(dailyGoal: value.round()));
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.dailyGoalHelper),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

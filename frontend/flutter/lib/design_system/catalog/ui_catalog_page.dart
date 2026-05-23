import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';

/// Internal catalog of design tokens (and, after later phases, atoms /
/// molecules / charts). Registered only outside prod via `app_router.dart`.
class UiCatalogPage extends StatelessWidget {
  const UiCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Catalog (dev)')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const <Widget>[
          _SectionTitle('Brand & semantic colors'),
          _ColorGrid(<_Swatch>[
            _Swatch('primary', AppColors.primary),
            _Swatch('primaryContainer', AppColors.primaryContainer),
            _Swatch('secondary', AppColors.secondary),
            _Swatch('accent', AppColors.accent),
            _Swatch('success', AppColors.success),
            _Swatch('warning', AppColors.warning),
            _Swatch('error', AppColors.error),
            _Swatch('info', AppColors.info),
          ]),
          SizedBox(height: AppSpacing.xl),

          _SectionTitle('Domain accents'),
          _ColorGrid(<_Swatch>[
            _Swatch('domainDiet', AppColors.domainDiet),
            _Swatch('domainExercise', AppColors.domainExercise),
            _Swatch('domainHealth', AppColors.domainHealth),
            _Swatch('domainAiCoach', AppColors.domainAiCoach),
          ]),
          SizedBox(height: AppSpacing.xl),

          _SectionTitle('Typography'),
          _TypographySample(),
          SizedBox(height: AppSpacing.xl),

          _SectionTitle('Spacing scale'),
          _SpacingScale(),
          SizedBox(height: AppSpacing.xl),

          _SectionTitle('Radius scale'),
          _RadiusScale(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _Swatch {
  const _Swatch(this.name, this.color);
  final String name;
  final Color color;
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid(this.swatches);
  final List<_Swatch> swatches;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: swatches.map((s) => _SwatchTile(s)).toList(),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile(this.swatch);
  final _Swatch swatch;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: swatch.color,
              borderRadius: const BorderRadius.all(AppRadius.md),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(swatch.name, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TypographySample extends StatelessWidget {
  const _TypographySample();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final samples = <(String, TextStyle?)>[
      ('displayLarge', t.displayLarge),
      ('displayMedium', t.displayMedium),
      ('titleLarge', t.titleLarge),
      ('titleMedium', t.titleMedium),
      ('bodyLarge', t.bodyLarge),
      ('bodyMedium', t.bodyMedium),
      ('labelLarge', t.labelLarge),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final s in samples)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text('${s.$1} — Oncare 헬스케어', style: s.$2),
          ),
      ],
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();
  @override
  Widget build(BuildContext context) {
    const tokens = <(String, double)>[
      ('xxs (2)', AppSpacing.xxs),
      ('xs (4)', AppSpacing.xs),
      ('sm (8)', AppSpacing.sm),
      ('md (12)', AppSpacing.md),
      ('lg (16)', AppSpacing.lg),
      ('xl (24)', AppSpacing.xl),
      ('xxl (32)', AppSpacing.xxl),
      ('xxxl (48)', AppSpacing.xxxl),
    ];
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final t in tokens)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: Text(
                    t.$1,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Container(width: t.$2, height: 16, color: color),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusScale extends StatelessWidget {
  const _RadiusScale();
  @override
  Widget build(BuildContext context) {
    const tokens = <(String, Radius)>[
      ('xs (4)', AppRadius.xs),
      ('sm (8)', AppRadius.sm),
      ('md (12)', AppRadius.md),
      ('lg (16)', AppRadius.lg),
      ('xl (24)', AppRadius.xl),
      ('pill (999)', AppRadius.pill),
    ];
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        for (final t in tokens)
          Column(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(t.$2),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(t.$1, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

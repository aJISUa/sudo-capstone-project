import 'package:flutter/widgets.dart';

import 'package:oncare/design_system/tokens/breakpoints.dart';

/// LayoutBuilder-backed selector. Pass [mobile] (required) and any of
/// [tablet] / [desktop] — missing branches fall through to the next
/// smaller form.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  /// Picks the effective form factor for a given incoming [width],
  /// honouring which branches were actually provided. Exposed so
  /// unit tests can verify the breakpoint logic without spinning up
  /// a Flutter binding.
  static DeviceForm selectFormFor(
    double width, {
    required bool hasTablet,
    required bool hasDesktop,
  }) {
    if (width >= AppBreakpoints.desktop && hasDesktop) {
      return DeviceForm.desktop;
    }
    if (width >= AppBreakpoints.tablet && hasTablet) {
      return DeviceForm.tablet;
    }
    return DeviceForm.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final form = selectFormFor(
          constraints.maxWidth,
          hasTablet: tablet != null,
          hasDesktop: desktop != null,
        );
        return switch (form) {
          DeviceForm.desktop => desktop!(ctx),
          DeviceForm.tablet => tablet!(ctx),
          DeviceForm.mobile => mobile(ctx),
        };
      },
    );
  }
}

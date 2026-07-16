/// Layout tokens for the trainer app's web-first surface. The Figma is
/// a phone mock; on desktop/tablet web the content column is centered
/// and capped so lists/chat don't stretch edge-to-edge.
class AppLayout {
  AppLayout._();

  /// Max width of the main content column (tabs, detail, chat).
  static const double contentMaxWidth = 720;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.useMockApi,
    this.sentryDsn,
  });

  final Environment environment;
  final String apiBaseUrl;
  final String? sentryDsn;

  /// When true, [MockApiInterceptor] short-circuits any HTTP request
  /// matching a known path and returns canned data. Used while the
  /// real REST backend (Q1 decision) is being built.
  final bool useMockApi;

  bool get isProd => environment == Environment.prod;
  bool get isDev => environment == Environment.dev;

  factory AppConfig.fromEnvironment() {
    const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
    final env = switch (envStr) {
      'prod' => Environment.prod,
      'staging' => Environment.staging,
      _ => Environment.dev,
    };
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev.api.oncare.example.com',
    );
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);
    return AppConfig(
      environment: env,
      apiBaseUrl: apiBaseUrl,
      sentryDsn: sentryDsn.isEmpty ? null : sentryDsn,
      useMockApi: useMockApi,
    );
  }
}

/// Override in [ProviderScope] at app startup with the value resolved
/// from [AppConfig.fromEnvironment]. Reading it before override throws.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError(
    'appConfigProvider must be overridden in ProviderScope before use.',
  );
});

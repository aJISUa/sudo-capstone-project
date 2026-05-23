import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/config/app_config.dart';
import 'package:oncare/core/logging/app_logger.dart';
import 'package:oncare/core/network/interceptors/api_logging_interceptor.dart';
import 'package:oncare/core/network/interceptors/auth_interceptor.dart';
import 'package:oncare/core/network/interceptors/local_api_interceptor.dart';
import 'package:oncare/core/network/interceptors/mock_api_interceptor.dart';
import 'package:oncare/core/storage/app_database.dart';

/// App-wide `Dio` instance, wired with logging/auth/mock interceptors
/// based on the current [AppConfig]. Feature data sources should read
/// this provider rather than constructing their own `Dio`.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(appLoggerProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ),
  );

  // Order matters: LocalApi (drift-backed) and the legacy in-memory
  // MockApi both short-circuit before auth/logging fire.
  if (config.useMockApi) {
    dio.interceptors
      ..add(LocalApiInterceptor(ref.watch(appDatabaseProvider), logger))
      ..add(MockApiInterceptor(logger));
  }
  dio.interceptors.add(AuthInterceptor(ref));
  if (!config.isProd) {
    dio.interceptors.add(ApiLoggingInterceptor(logger));
  }

  ref.onDispose(dio.close);
  return dio;
}, name: 'dio');

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/auth_token.dart';

/// Attaches `Authorization: Bearer <token>` to outgoing requests when a
/// session token is present. In mock mode the LocalApiInterceptor resolves
/// requests before this runs, so the token only matters against the real
/// FastAPI backend (USE_MOCK_API=false).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(authAccessTokenProvider);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

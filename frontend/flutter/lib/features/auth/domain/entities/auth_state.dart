enum AuthProvider { apple, google, kakao, naver }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.provider,
  });

  final String id;
  final String name;
  final AuthProvider provider;
}

class AuthState {
  const AuthState({this.user});
  final AuthUser? user;
  bool get isSignedIn => user != null;
}

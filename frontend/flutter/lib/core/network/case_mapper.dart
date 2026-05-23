/// snake_case ↔ camelCase helpers. The FastAPI server emits snake_case
/// JSON (Pydantic alias convention); Flutter prefers camelCase.
/// Used by `LocalApiInterceptor` so the dummy backend can pretend it
/// is the real server.
Object? toCamelCaseJson(Object? value) {
  if (value is Map<String, Object?>) {
    return <String, Object?>{
      for (final entry in value.entries)
        _snakeToCamel(entry.key): toCamelCaseJson(entry.value),
    };
  }
  if (value is List<Object?>) {
    return <Object?>[for (final v in value) toCamelCaseJson(v)];
  }
  return value;
}

Object? toSnakeCaseJson(Object? value) {
  if (value is Map<String, Object?>) {
    return <String, Object?>{
      for (final entry in value.entries)
        _camelToSnake(entry.key): toSnakeCaseJson(entry.value),
    };
  }
  if (value is List<Object?>) {
    return <Object?>[for (final v in value) toSnakeCaseJson(v)];
  }
  return value;
}

String _snakeToCamel(String s) {
  final parts = s.split('_');
  if (parts.length == 1) return s;
  final head = parts.first;
  final tail = parts.skip(1).map((String w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1);
  });
  return head + tail.join();
}

String _camelToSnake(String s) {
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final ch = s[i];
    if (i > 0 && ch == ch.toUpperCase() && ch != ch.toLowerCase()) {
      buf.write('_');
      buf.write(ch.toLowerCase());
    } else {
      buf.write(ch);
    }
  }
  return buf.toString();
}

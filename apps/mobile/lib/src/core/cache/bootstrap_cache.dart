import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_models.dart';

class CachedBootstrap {
  CachedBootstrap({
    required this.data,
    required this.cachedAt,
  });

  final AppBootstrap data;
  final DateTime? cachedAt;
}

class BootstrapCache {
  static const _bootstrapKey = 'lo_renaciente.cached_bootstrap';
  static const _cachedAtKey = 'lo_renaciente.cached_bootstrap_at';

  Future<CachedBootstrap?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_bootstrapKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    final payload = jsonDecode(rawJson) as Map<String, dynamic>;
    final cachedAtRaw = prefs.getString(_cachedAtKey);

    return CachedBootstrap(
      data: AppBootstrap.fromJson(payload),
      cachedAt: cachedAtRaw == null ? null : DateTime.tryParse(cachedAtRaw),
    );
  }

  Future<void> write(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bootstrapKey, rawJson);
    await prefs.setString(_cachedAtKey, DateTime.now().toIso8601String());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bootstrapKey);
    await prefs.remove(_cachedAtKey);
  }
}

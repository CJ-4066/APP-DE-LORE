import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/app_models.dart';

class SeedBootstrapLoader {
  Future<AppBootstrap?> load() async {
    try {
      final rawJson = await rootBundle.loadString(
        'assets/bootstrap/bootstrap_seed.json',
      );
      final payload = jsonDecode(rawJson) as Map<String, dynamic>;
      return AppBootstrap.fromJson(payload);
    } catch (_) {
      return null;
    }
  }
}


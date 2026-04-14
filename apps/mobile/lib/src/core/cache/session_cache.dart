import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_models.dart';

class SessionCache {
  static const _sessionKey = 'lo_renaciente.phone_session';

  Future<PhoneAuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_sessionKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    final payload = jsonDecode(rawJson) as Map<String, dynamic>;
    return PhoneAuthSession.fromJson(payload);
  }

  Future<void> write(PhoneAuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}

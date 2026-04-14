import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:4000';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:4000'
        : 'http://127.0.0.1:4000';
  }

  static String connectionHelpMessage(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    final host = uri?.host ?? '';

    if (host == '127.0.0.1' || host == 'localhost' || host == '10.0.2.2') {
      return 'No se pudo conectar a la API en $baseUrl. Si estás usando un celular físico, ejecuta la app con --dart-define=API_BASE_URL=http://<IP-DE-TU-MAC>:4000.';
    }

    if (host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host.startsWith('172.')) {
      return 'No se pudo conectar a la API en $baseUrl. En iPhone revisa Ajustes > Privacidad y seguridad > Red local y confirma que Lo Renaciente tenga permiso. También verifica que el iPhone y la Mac estén en la misma red y que el backend siga levantado.';
    }

    return 'No se pudo conectar a la API en $baseUrl. Verifica que el backend esté levantado y accesible desde tu dispositivo.';
  }
}

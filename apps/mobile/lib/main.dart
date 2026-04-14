import 'dart:async';

import 'package:flutter/material.dart';

import 'src/app/app.dart';

void main() {
  runZonedGuarded(
    () {
      debugPrint('LR Dart main start');
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Zone.current.handleUncaughtError(
          details.exception,
          details.stack ?? StackTrace.current,
        );
      };

      debugPrint('LR Dart runApp');
      runApp(const LoRenacienteApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shain/app.dart';

/// Titik masuk aplikasi Shain dengan ProviderScope sebagai root Riverpod.
void main() {
  runApp(ProviderScope(retry: (_, _) => null, child: const ShainApp()));
}

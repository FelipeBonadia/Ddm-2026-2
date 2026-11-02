import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: MathPuzzleApp()));
}
// Here we take the value from the MyHomePage object that was created by
// the App.build method, and use it to set our appbar title.
// Removed the starter counter fragment as it is no longer needed.

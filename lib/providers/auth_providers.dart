import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value ??
      ref.watch(authServiceProvider).currentUser;
});

/// Chaves dos desafios que o usuário atual já resolveu (lidas do Firestore).
/// Use `ref.invalidate` depois de salvar um desafio para recarregar.
final solvedChallengesProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return <String>{};
  return ref.watch(firestoreServiceProvider).fetchSolvedChallenges(user.uid);
});

class LastRouteNotifier extends Notifier<String?> {
  static const _key = 'last_route';

  @override
  String? build() {
    Future.microtask(_load);
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> save(String route) async {
    if (route.isEmpty) return;
    state = route;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, route);
  }
}

final lastRouteProvider = NotifierProvider<LastRouteNotifier, String?>(
  LastRouteNotifier.new,
);

class PendingNumberNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;

  void skip() => state = null;
}

final pendingNumberProvider = NotifierProvider<PendingNumberNotifier, int?>(
  PendingNumberNotifier.new,
);

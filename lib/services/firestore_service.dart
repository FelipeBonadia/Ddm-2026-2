import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Um documento por desafio resolvido: `users/{uid}/progress/{id}`.
  CollectionReference<Map<String, dynamic>> _progressCol(String uid) =>
      _userDoc(uid).collection('progress');

  // ── Progresso ─────────────────────────────────────────────────────────────

  /// Grava um desafio resolvido. Não bloqueia esperando o servidor: o
  /// Firestore aplica a escrita no cache local na hora (o stream já emite) e
  /// sincroniza quando houver rede. O Future só completa após o ack do
  /// servidor, então quem chama não deve dar `await` se quiser UI instantânea.
  Future<void> addProgressEntry(String uid, Map<String, dynamic> data) async {
    await _progressCol(uid).add(data);
  }

  /// Todos os desafios resolvidos do usuário, mais recente primeiro.
  Stream<List<Map<String, dynamic>>> watchProgressEntries(String uid) {
    return _progressCol(uid)
        .orderBy('solvedAt', descending: true)
        .snapshots()
        .map((snap) => [for (final doc in snap.docs) doc.data()]);
  }

  // ── Números resolvidos (já existia) ───────────────────────────────────────

  Future<void> saveSolvedNumber(String uid, int number) async {
    await _userDoc(uid).set({
      'solvedNumbers': FieldValue.arrayUnion([number]),
    }, SetOptions(merge: true));
  }

  Future<Set<int>> fetchSolvedNumbers(String uid) async {
    final snapshot = await _userDoc(uid).get();
    return _parse(snapshot.data());
  }

  Stream<Set<int>> watchSolvedNumbers(String uid) {
    return _userDoc(uid).snapshots().map((snap) => _parse(snap.data()));
  }

  Set<int> _parse(Map<String, dynamic>? data) {
    if (data == null) return <int>{};
    final list = (data['solvedNumbers'] as List<dynamic>?) ?? const [];
    return list.map((e) => (e as num).toInt()).toSet();
  }
}

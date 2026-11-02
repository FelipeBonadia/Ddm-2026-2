import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> saveSolvedNumber(String uid, int number) async {
    await _userDoc(uid).set(
      {
        'solvedNumbers': FieldValue.arrayUnion([number]),
      },
      SetOptions(merge: true),
    );
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
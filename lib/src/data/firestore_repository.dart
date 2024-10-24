import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker_app_flutter_firebase/src/data/job.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore;
  FirestoreRepository(this._firestore);

  // add Job, uid, title, company
  Future<void> addJob(String uid, String title, String company) async {
    await _firestore.collection('users/$uid/jobs').add({
      'title': title,
      'company': company,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // update Job, uid, title, company
  Future<void> updateJob(
      String uid, String jobId, String title, String company) async {
    _firestore
        .doc('users/$uid/jobs/$jobId')
        .update({'uid': uid, 'title': title, 'company': company});
  }

  // get Jobs, uid
  Query<Job> jobsQuery(String uid) {
    return _firestore
        .collection('users/$uid/jobs')
        .withConverter<Job>(
          fromFirestore: (snapshot, _) => Job.fromMap(snapshot.data()!),
          toFirestore: (job, _) => job.toMap(),
        )
        .orderBy('createdAt', descending: true);
  }

  // delete Job, jobId
  Future<void> deleteJob(String uid, String jobId) async {
    _firestore.doc('users/$uid/jobs/$jobId').delete();
  }
}

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(FirebaseFirestore.instance);
});

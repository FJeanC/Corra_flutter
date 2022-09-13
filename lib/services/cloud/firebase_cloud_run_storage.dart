import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/cloud_storage_constants.dart';
import 'package:corra/services/cloud/cloud_storage_exceptions.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudRunStorage {
  final runs = FirebaseFirestore.instance.collection('runs');
  static final FirebaseCloudRunStorage _shared =
      FirebaseCloudRunStorage._sharedInstance();
  FirebaseCloudRunStorage._sharedInstance();
  factory FirebaseCloudRunStorage() => _shared;

  Future<void> createNewRun({
    required String ownerUserId,
    required String tempo,
    required String velocidade,
    required String data,
  }) async {
    await runs.add({
      ownerUserIdFieldName: ownerUserId,
      tempoFieldName: tempo,
      velocidadeFieldName: velocidade,
      dataFieldName: data,
    });
    print('Nota criada: $tempo, $ownerUserId');
  }

  Future<void> deleteRun({required String documentId}) async {
    try {
      await runs.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteRunException();
    }
    try {
      final ref =
          FirebaseStorage.instance.ref().child('runs_image/$documentId');
      await ref.delete();
    } catch (e) {
      print('Maybe ');
      return;
    }
  }

  Stream<Iterable<CloudRun>> allRuns({required String ownerUserId}) {
    print('I was called');
    return runs.orderBy('data', descending: true).snapshots().map((event) =>
        event.docs
            .map((doc) => CloudRun.fromSnapshot(doc))
            .where((run) => run.ownerUserId == ownerUserId));
  }
}

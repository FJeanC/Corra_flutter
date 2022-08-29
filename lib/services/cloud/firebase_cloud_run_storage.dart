import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corra/services/auth/auth_exceptions.dart';
import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/cloud_storage_constants.dart';
import 'package:corra/services/cloud/cloud_storage_exceptions.dart';

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
  }

  Stream<Iterable<CloudRun>> allRuns({required String ownerUserId}) {
    return runs.snapshots().map((event) => event.docs
        .map((doc) => CloudRun.fromSnapshot(doc))
        .where((run) => run.ownerUserId == ownerUserId));
  }
}

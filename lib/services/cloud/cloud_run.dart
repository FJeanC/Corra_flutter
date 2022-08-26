import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corra/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudRun {
  final String documentId;
  final String ownerUserId;
  final String tempo;
  final String velocidade;
  final String data;

  const CloudRun({
    required this.tempo,
    required this.velocidade,
    required this.data,
    required this.documentId,
    required this.ownerUserId,
  });

  CloudRun.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        tempo = snapshot.data()[tempoFieldName] as String,
        velocidade = snapshot.data()[velocidadeFieldName] as String,
        data = snapshot.data()[dataFieldName] as String;
}

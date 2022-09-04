import 'dart:io';
import 'dart:typed_data';

import 'package:corra/enums/menu_action.dart';
import 'package:corra/services/cloud/cloud_run.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class RunDetailView extends StatefulWidget {
  const RunDetailView({Key? key}) : super(key: key);

  @override
  State<RunDetailView> createState() => _RunDetailViewState();
}

class _RunDetailViewState extends State<RunDetailView> {
  File? fileImage;
  UploadTask? uploadTask;

  Future<void> uploadFile(CloudRun run) async {
    // final String newPath =
    //     path.join(path.dirname(fileImage!.path), run.documentId);
    final pathToSave = 'runs_image/${run.documentId}';
    final fileToUpload = (File(fileImage!.path));

    final ref = FirebaseStorage.instance.ref().child(pathToSave);

    setState(() {
      uploadTask = ref.putFile(fileToUpload);
    });
    final snap = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snap.ref.getDownloadURL();
    print('DonwloadLink: $urlDownload');
    setState(() {
      uploadTask = null;
    });
  }

  Future<String> imageAlreadyExists(CloudRun run) async {
    try {
      final pathToSave = 'runs_image/${run.documentId}';
      final ref = FirebaseStorage.instance.ref().child(pathToSave);
      final result = await ref.getDownloadURL();
      return result;
    } on FirebaseException catch (e) {
      print('HERE I AM ou ${e.code} and ${e.message}');
      return e.code;
    }
  }

  Future<void> pickImage() async {
    // isImageSave();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        fileImage = imageTemporary;
      });

      buildProgess();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget buildProgess() {
    return StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 30,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final run = ModalRoute.of(context)!.settings.arguments as CloudRun;
    bool flag = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail view'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                break;
              case MenuAction.save:
                try {
                  await uploadFile(run);
                } on Exception {
                  print('ERRRO');
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.save,
                child: Text('Save'),
              ),
            ];
          })
        ],
      ),
      body: Column(
        children: [
          Text(run.data),
          Text(run.velocidade),
          Text(run.tempo),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Take a picture'),
          ),
          FutureBuilder<String>(
            future: imageAlreadyExists(run),
            builder: ((context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.data! != 'object-not-found') {
                    print('AQUI');
                    flag = true;
                    return buildImage(snapshot.data!);
                  } else {
                    return Container();
                  }
                default:
                  return const CircularProgressIndicator();
              }
            }),
          ),
          if (fileImage != null && !flag)
            Expanded(
              child: Container(
                color: Colors.blue[100],
                child: Image.file(File(fileImage!.path),
                    width: double.infinity, fit: BoxFit.cover),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildImage(String documentName) {
    return Center(
      child: Image.network(
        documentName,
        fit: BoxFit.cover,
      ),
    );
  }
}

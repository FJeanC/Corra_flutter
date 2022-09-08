import 'dart:io';
import 'package:corra/enums/menu_action.dart';
import 'package:corra/services/cloud/cloud_run.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      print("IM not being called");
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
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ModalRoute.of(context)!.settings.arguments as CloudRun;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.detailView),
        actions: [
          IconButton(onPressed: pickImage, icon: const Icon(Icons.camera)),
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
            return [
              PopupMenuItem<MenuAction>(
                value: MenuAction.save,
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ];
          })
        ],
      ),
      body: Column(
        children: [
          // ElevatedButton(
          //   onPressed: pickImage,
          //   child: Text(AppLocalizations.of(context)!.takePic),
          // ),
          Expanded(child: buildRunInfo(run)),
          Expanded(child: buildCompleteImage(run))
        ],
      ),
    );
  }

  Widget buildCompleteImage(CloudRun run) {
    if (fileImage != null) {
      return buildImageInMemory();
    }
    return FutureBuilder<String>(
      future: imageAlreadyExists(run),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data! != 'object-not-found') {
              print('AQUI');
              //flag = true;
              return buildImage(snapshot.data!);
            } else {
              print("Hello darksness");
              return Image.asset('assets/images/Shoe.png');
            }
          default:
            return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  Widget buildImageInMemory() {
    return Container(
      color: Colors.blue[100],
      child: Image.file(
        File(fileImage!.path),
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildRunInfo(CloudRun run) {
    return Column(
      children: [
        Text(run.data),
        Text(run.velocidade),
        Text(run.tempo),
      ],
    );
  }

  Widget buildImage(String documentName) {
    return Center(
      child: Image.network(
        documentName,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/utilities/dialogs/error_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RunDetailView extends StatefulWidget {
  const RunDetailView({Key? key}) : super(key: key);

  @override
  State<RunDetailView> createState() => _RunDetailViewState();
}

class _RunDetailViewState extends State<RunDetailView> {
  File? fileImage;
  UploadTask? uploadTask;
  bool showSaveButton = false;

  Future<void> uploadFile(CloudRun run) async {
    if (fileImage == null) {
      return showErrorDialog(
          context, AppLocalizations.of(context)!.couldntSaveImage);
    }
    try {
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
      var snackBar =
          SnackBar(content: Text(AppLocalizations.of(context)!.imageSaved));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on Exception catch (_) {
      return showErrorDialog(
          context, AppLocalizations.of(context)!.couldntSaveImage);
    }
  }

  Future<String> imageAlreadyExists(CloudRun run) async {
    try {
      final pathToSave = 'runs_image/${run.documentId}';
      final ref = FirebaseStorage.instance.ref().child(pathToSave);
      final result = await ref.getDownloadURL();
      return result;
    } on FirebaseException catch (e) {
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
    } on PlatformException catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ModalRoute.of(context)!.settings.arguments as CloudRun;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.detailView),
        actions: [
          IconButton(onPressed: pickImage, icon: const Icon(Icons.camera_alt)),
          IconButton(
              onPressed: () => uploadFile(run), icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
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
              return buildImage(snapshot.data!);
            } else {
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
      decoration: BoxDecoration(border: Border.all(width: 4)),
      child: Image.file(
        File(fileImage!.path),
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildRunInfo(CloudRun run) {
    final distancia = (double.parse(run.velocidade) *
        ((getTimeInMilli(run.tempo) / 3600000)));
    double pace = 1 / (double.parse(run.velocidade) / 60);
    if (pace == double.infinity) {
      pace = 0.0;
    }

    bool isHeightLarge = MediaQuery.of(context).size.height >= 810;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: isHeightLarge ? 32 : 16, bottom: 10),
          child: Text(
            AppLocalizations.of(context)!.runFrom,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Text(
            run.data.substring(0, 10).replaceAll("-", "/"),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        CustomPaint(
          child: Container(
            // width: 250,
            // height: 130,
            color: const Color.fromARGB(255, 60, 234, 253),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Flex(
                direction: isHeightLarge ? Axis.vertical : Axis.horizontal,
                children: [
                  Text(
                    AppLocalizations.of(context)!.distance,
                    style: const TextStyle(fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${distancia.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    run.tempo,
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isHeightLarge ? 25 : 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Pace',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    pace.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.startTime,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    run.data.substring(11, 19),
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildImage(String documentName) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
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
      ),
    );
  }

  int getTimeInMilli(String globalTime) {
    final timeStr = globalTime;
    final format = DateFormat('HH:mm:ss.S');
    final dt = format.parse(timeStr, true);
    return dt.millisecondsSinceEpoch;
  }
}

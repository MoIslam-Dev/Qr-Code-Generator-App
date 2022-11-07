import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_generator/ui_style/style.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String data = '';
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppStyle.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: buildQrImage(data)
          ),
          SizedBox(
            height: 24.0,
          ),
          Container(
            width: 300.0,
            child: TextField(
              textAlign: TextAlign.center,
              onChanged: (value){
                setState(() {
                  data = value;
                });
              },
              style: TextStyle(
                color: Colors.white
              ),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent, width: 5.0),
                  ),

                hintText: 'Type The Data',
  hintStyle: TextStyle(
    color: Colors.black87),
                filled: true,
                fillColor: AppStyle.textInputColor,
                border: InputBorder.none
              ),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          RawMaterialButton(
         constraints: BoxConstraints.tightFor(width: 200.0,height: 60.0),

              onPressed: () async{

          final image =      await _screenshotController.captureFromWidget(buildQrImage(data));
          if(image == null) return;
          await saveImage(image);
          Fluttertoast.showToast(
              msg: "Downloading ...",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppStyle.primaryColor,
              textColor: AppStyle.accentColor,
              fontSize: 16.0
          );
              },
            fillColor: AppStyle.accentColor,

            shape: StadiumBorder(),
            child: Text(
              'Download Qr Image'
            ),

          ),
          SizedBox(
            height: 24.0,
          ),
          RawMaterialButton(
           constraints: BoxConstraints.tightFor(width: 200.0,height: 60.0),
            onPressed: () async{
              final image =      await _screenshotController.captureFromWidget(buildQrImage(data));
            saveAndShare(image);
            },
            fillColor: AppStyle.accentColor,

            shape: StadiumBorder(),
            child: Text(
                'Share Qr Image'
            ),
          )

        ],
      ),
    );
  }

 Future<String> saveImage(Uint8List image) async{
    await  [Permission.storage].request();
    final time = DateTime.now()
    .toIso8601String()
    .replaceAll('.', '-')
    .replaceAll(';', '-');
    final name = 'qrimage_$time';
    final result =await ImageGallerySaver.saveImage(image , name: name);
    return result['filePath'];
  }

  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final  image =File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);
    await Share.shareXFiles([XFile(image.path)]);

  }
}
Widget buildQrImage (String data) {
  return QrImage(
    data: data,
    version: QrVersions.auto,
    backgroundColor: Colors.white,
    size: 300.0,
  );
}
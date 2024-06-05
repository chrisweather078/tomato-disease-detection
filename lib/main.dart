import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import './yolo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // disable landscape mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  File? _imageFile;
  late int _imageWidth;
  late int _imageHeight;
  late Size _destinationSize;
  late double _contWidth; // remove these values
  late double _contHeight; // remove these values
  bool isLoading = false;
  final List<Color> _classColor = [
    Colors.red,
    Colors.yellow,
    const Color(0xFF007ACC)
  ];

  String _imagePath = "";

  List<Widget> _boundingBoxesWidgets = [];

  Future<void> _detectObjects(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    await testYolov5(_imagePath);

    double x, y, w, h;

    if (_contWidth / _contHeight > _imageWidth / _imageHeight) {
      // taller images
      _destinationSize =
          Size(_imageWidth * _contWidth / _imageHeight, _contHeight);
    } else {
      // for wider images
      _destinationSize =
          Size(_contWidth, _imageHeight * _contWidth / _imageWidth);
    }

    for (var rec in finalRecognitions) {
      x = rec[2] * _destinationSize.width;
      y = rec[3] * _destinationSize.height;
      w = rec[4] * _destinationSize.width;
      h = rec[5] * _destinationSize.height;

      _boundingBoxesWidgets.add(Positioned(
        left: x - w / 2,
        top: y - h / 2,
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
            color: _classColor[rec[0]],
            width: 1,
          )),
        ),
      ));
    }

    setState(() {
      _boundingBoxesWidgets = _boundingBoxesWidgets;
      isLoading = false;

      if (_boundingBoxesWidgets.isNotEmpty) {
        Flushbar(
          message: "🟡Healthy  🔴Early Blight  🔵Late Blight",
          messageSize: 14,
          duration: const Duration(seconds: 10),
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(25),
          borderRadius: BorderRadius.circular(8),
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          backgroundColor: const Color(0xFF4D8C57),
          boxShadows: const [
            BoxShadow(
                color: Colors.blue, offset: Offset(0.0, 2.0), blurRadius: 3.0)
          ],
          backgroundGradient:
              const LinearGradient(colors: [Colors.green, Color(0xFF4D8C57)]),
          isDismissible: true,
          icon: const Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 40,
          ),
        ).show(context);
      } else {
        Flushbar(
          message: "No Detections",
          messageSize: 20,
          duration: const Duration(seconds: 5),
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(25),
          borderRadius: BorderRadius.circular(8),
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.elasticOut,
          backgroundColor: const Color(0xFF4D8C57),
          boxShadows: const [
            BoxShadow(
                color: Colors.blue, offset: Offset(0.0, 2.0), blurRadius: 3.0)
          ],
          backgroundGradient:
              const LinearGradient(colors: [Colors.red, Color(0xFF4D8C57)]),
          isDismissible: true,
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
            size: 40,
          ),
        ).show(context);
      }
    });
  }

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePath = pickedFile.path;
        _boundingBoxesWidgets = [];
      });

      final imageBytes = await _imageFile!.readAsBytes();
      final imageCodec = await instantiateImageCodec(imageBytes);
      final frameInfo = await imageCodec.getNextFrame();

      setState(() {
        _imageWidth = frameInfo.image.width;
        _imageHeight = frameInfo.image.height;
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePath = pickedFile.path;
        _boundingBoxesWidgets = [];
      });

      final imageBytes = await _imageFile!.readAsBytes();
      final imageCodec = await instantiateImageCodec(imageBytes);
      final frameInfo = await imageCodec.getNextFrame();

      setState(() {
        _imageWidth = frameInfo.image.width;
        _imageHeight = frameInfo.image.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    _contWidth = 0.95 * screenWidth;
    _contHeight = 0.65 * screenHeight;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Stack(children: [
          Scaffold(
            appBar: AppBar(
              title: const Text(
                'Blight Detector',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900),
              ),
              centerTitle: true,
              // backgroundColor: const Color(0xFF609966), //41B06E 337357 609966
              backgroundColor: const Color(0xFF4D8C57), //41B06E 337357 609966
            ),
            backgroundColor: Colors.green.shade50,
            body: Center(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    height: _contHeight,
                    width: _contWidth,
                    alignment: Alignment.center,
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(15.0),
                    //     border: Border.all(
                    //       color: Colors.black,
                    //       width: 1.0,
                    //       style: BorderStyle.solid,
                    //     )),
                    child: _imageFile == null
                        ? ClipRRect(
                            child: Image.asset(
                              './assets/no_photo3.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : SizedBox(
                            child: Stack(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                )),
                            ..._boundingBoxesWidgets,
                          ])),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              // color: const Color(0xFF609966),
              color: const Color(0xFF4D8C57),
              height: 0.12 * screenHeight,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: Colors.white,
                    iconSize: 40,
                    tooltip: "Select image from camera",
                    onPressed: _getImageFromCamera,
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    color: Colors.white,
                    iconSize: 40,
                    tooltip: "Select image from gallery",
                    onPressed: _getImageFromGallery,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.large(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              onPressed: () => setState(() {
                if (_imageFile != null) {
                  _detectObjects(context);
                }
                _boundingBoxesWidgets = [];
              }),
              tooltip: 'Perform detection',
              child: const Icon(
                Icons.search,
                // color: Color(0xFF609966),
                color: Color(0xFF4D8C57),
                size: 40,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          ),
          if (isLoading)
            const Opacity(
              opacity: 0.5,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (isLoading) // detecting please wait
            const Center(
              child: Icon(
                Icons.hourglass_bottom,
                size: 100,
                color: Colors.white,
              ),
            ),
        ]));
  }
}

// remove hardcoded values+++++++++++++++++++++
// round image+++++++++++++++++++
// increase padding++++++++++++++++
// text size+++++++++++++++++++++
// add circular indicator / overlay screen with loading state+++++++++++
// restructure buttons; camera & gallery, when image selected, detected and remove++++++
// format results to have only 1 bounding box per image location
// result summary(notification banner)++++++++++++++++++++++++++
// transition when on+++++++++++++++++++++++++++
// app icon and app name+++++++++++++++
// remove debug sticker+++++++++++++
// disable landscape mode++++++++++++++++
// on boarding
// border...white border dark shadow
// detect button pressed in
// add to ios and windows
// add history
// add dark mode

import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import './yolo.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    _contWidth = 0.95 * screenWidth;
    _contHeight = 0.65 * screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tomato Clinic',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4D8C57),
      ),
      backgroundColor: Colors.green.shade50,
      body: isLoading ? buildLoadingScreen() : buildHomepage(),
      bottomNavigationBar: BottomAppBar(
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
      floatingActionButton: GestureDetector(
        onLongPress: _showFlushBar,
        child: FloatingActionButton.large(
            shape: const CircleBorder(),
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            onPressed: () => setState(() {
                  if (_imageFile != null) {
                    isLoading = true;
                    _detectObjects();
                  }
                  _boundingBoxesWidgets = [];
                }),
            child: const Icon(
              Icons.search,
              color: Color(0xFF4D8C57),
              size: 40,
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildLoadingImage() {
    return const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.greenAccent,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Loading image, please wait..."),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingScreen() {
    // return const Opacity(
    //     opacity: 0.5,
    //     child: ModalBarrier(dismissible: false, color: Colors.black));
    return const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
              radius: 50.0, color: CupertinoColors.activeGreen),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Detecting, please wait..."),
          ),
        ],
      ),
    );
  }

  Widget buildHomepage() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            height: _contHeight,
            width: _contWidth,
            alignment: Alignment.center,
            child: _imageFile == null
                ? ClipRRect(
                    child: Image.asset(
                      './assets/no_photo3.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : loadingImage
                    ? buildLoadingImage()
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
    );
  }

  File? _imageFile;
  late int _imageWidth;
  late int _imageHeight;
  late Size _destinationSize;
  late double _contWidth;
  late double _contHeight;
  bool isLoading = false;
  bool loadingImage = false;
  bool sFlush = false;
  final List _classColor = [
    Colors.black,
    Colors.yellow,
    Colors.orange,
    Colors.white,
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.brown
  ];
  String _imagePath = "";

  List<Widget> _boundingBoxesWidgets = [];

  Future<void> _detectObjects() async {
    setState(() {
      isLoading = true;
      sFlush = true;
    });

    await testYolov5(_imagePath);

    double x, y, w, h; // initialize rendering coordinates

    if (_contWidth / _contHeight > _imageWidth / _imageHeight) {
      // check if image is taller than wider
      _destinationSize =
          Size(_imageWidth * _contWidth / _imageHeight, _contHeight);
    } else {
      // check if image is wider than taller
      _destinationSize =
          Size(_contWidth, _imageHeight * _contWidth / _imageWidth);
    }

    // loop through output detections
    for (var rec in finalRecognitions) {
      x = rec[2] *
          _destinationSize
              .width; // format output detections to fit display image
      y = rec[3] * _destinationSize.height;
      w = rec[4] * _destinationSize.width;
      h = rec[5] * _destinationSize.height;

      // render bounding boxes using a widget
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
      _showFlushBar();
    });
  }

  Future<void> _getImageFromCamera() async {
    setState(() {
      sFlush = false;
      loadingImage = true;
    });
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
        loadingImage = false;
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    setState(() {
      sFlush = false;
      loadingImage = true;
    });
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
        loadingImage = false;
      });
    }
  }

  Future<void> _showFlushBar() async {
    if (sFlush) {
      if (_boundingBoxesWidgets.isNotEmpty) {
        Flushbar(
          message:
              "⚫Bacterial Spot\n🟡Early Blight\n🟠Fosarium\n⚪Healthy\n🔴Late Blight\n🟣Leaf Curl\n🔵Mosaic\n🟤Septoria",
          messageSize: 14,
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
                color: Colors.white, offset: Offset(0.0, 2.0), blurRadius: 3.0)
          ],
          backgroundGradient:
              const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
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
          messageSize: 16,
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
                color: Colors.white, offset: Offset(0.0, 2.0), blurRadius: 3.0)
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
    }
  }
}

// if (isLoading)
//             const Opacity(
//               opacity: 0.5,
//               child: ModalBarrier(dismissible: false, color: Colors.black),
//             ),
//           if (isLoading) // detecting please wait
//             const Center(
//               child: Icon(
//                 Icons.hourglass_bottom,
//                 size: 100,
//                 color: Colors.white,
//               ),
//             ),

// detect button pressed but doesnt show detecting on second try
// use int8 model for inferencing
// format results to have only 1 bounding box per image location
// add windows ios 
// add history
// add dark mode

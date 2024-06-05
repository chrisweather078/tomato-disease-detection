// import 'dart:ui';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// // import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:math';
// import './yolo.dart';
// // import './coco.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }

//   File? _imageFile;
//   late int _imageWidth;
//   late int _imageHeight;
//   late Size _destinationSize;
//   late double _contWidth; // remove these values
//   late double _contHeight; // remove these values
//   bool isLoading = false;
//   bool _showSummary = false;
//   final List<Color> _classColor = [Colors.red, Colors.yellow, Colors.blue];

//   String _imagePath = "";

//   List<Widget> _boundingBoxesWidgets = [];

//   Future<void> _detectObjects() async {
//     setState(() {
//       isLoading = true;
//     });

//     await testYolov5(_imagePath);

//     double x, y, w, h;

//     if (_contWidth / _contHeight > _imageWidth / _imageHeight) {
//       // taller images
//       _destinationSize =
//           Size(_imageWidth * _contWidth / _imageHeight, _contHeight);
//     } else {
//       // for wider images
//       _destinationSize =
//           Size(_contWidth, _imageHeight * _contWidth / _imageWidth);
//     }

//     for (var rec in finalRecognitions) {
//       x = rec[2] * _destinationSize.width;
//       y = rec[3] * _destinationSize.height;
//       w = rec[4] * _destinationSize.width;
//       h = rec[5] * _destinationSize.height;

//       _boundingBoxesWidgets.add(Positioned(
//         left: x - w / 2,
//         top: y - h / 2,
//         width: w,
//         height: h,
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//             color: _classColor[rec[0]],
//             width: 1,
//           )),
//         ),
//       ));
//     }

//     setState(() {
//       _boundingBoxesWidgets = _boundingBoxesWidgets;
//       isLoading = false;
//       _showSummary = true;
//     });
//   }

//   Future<void> _getImageFromCamera() async {
//     final picker = ImagePicker();
//     // ignore: deprecated_member_use
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _imagePath = pickedFile.path;
//         _boundingBoxesWidgets = [];
//         _showSummary = false;
//       });

//       final imageBytes = await _imageFile!.readAsBytes();
//       final imageCodec = await instantiateImageCodec(imageBytes);
//       final frameInfo = await imageCodec.getNextFrame();

//       setState(() {
//         _imageWidth = frameInfo.image.width;
//         _imageHeight = frameInfo.image.height;
//       });
//     }
//   }

//   Future<void> _getImageFromGallery() async {
//     final picker = ImagePicker();
//     // ignore: deprecated_member_use
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _imagePath = pickedFile.path;
//         _boundingBoxesWidgets = [];
//         _showSummary = false;
//       });

//       final imageBytes = await _imageFile!.readAsBytes();
//       final imageCodec = await instantiateImageCodec(imageBytes);
//       final frameInfo = await imageCodec.getNextFrame();

//       setState(() {
//         _imageWidth = frameInfo.image.width;
//         _imageHeight = frameInfo.image.height;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _contWidth = 0.98 * MediaQuery.of(context).size.width;
//     _contHeight = 0.55 * MediaQuery.of(context).size.height;

//     return Stack(children: [
//       Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Blight Detector',
//             style: TextStyle(color: Colors.white),
//           ),
//           centerTitle: true,
//           backgroundColor: const Color(0xFFA5DD9B),
//         ),
//         backgroundColor: Colors.green.shade50,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Container(
//                 height: _contHeight,
//                 width: _contWidth,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15.0),
//                     border: Border.all(
//                       color: Colors.black,
//                       width: 1.0,
//                       style: BorderStyle.solid,
//                     )),
//                 child: _imageFile == null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(10.0),
//                         child: Image.asset(
//                           './assets/no_photo3.png',
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : SizedBox(
//                         child: Stack(children: [
//                         ClipRRect(
//                             borderRadius: BorderRadius.circular(10.0),
//                             child: Image.file(
//                               _imageFile!,
//                               fit: BoxFit.cover,
//                             )),
//                         ..._boundingBoxesWidgets,
//                       ])),
//               ),
//               if (_showSummary)
//                 if (_boundingBoxesWidgets.isNotEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(5.0),
//                     child: SizedBox(
//                         // remove these height values
//                         child: Center(
//                             child: Text(
//                       "Healthy - 🟡  Early Blight - 🔴  Late Blight - 🔵",
//                       style: TextStyle(fontSize: 15),
//                     ))),
//                   )
//                 else
//                   const Padding(
//                     padding: EdgeInsets.all(5.0),
//                     child: SizedBox(
//                         // remove these height values
//                         child: Center(
//                             child: Text(
//                       "No Detections",
//                       style: TextStyle(fontSize: 15),
//                     ))),
//                   ),
//               // const SizedBox(
//               //     // remove these height values
//               //     child: Center(
//               //         child: Text(
//               //   "Select Image from: ",
//               //   style: TextStyle(fontSize: 15),
//               // ))),
//               Padding(
//                 padding:
//                     const EdgeInsets.only(bottom: 8), // remove these values
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         IconButton(
//                           icon: const Icon(
//                             Icons.camera_alt_outlined,
//                             size: 50,
//                           ), // Gallery icon
//                           onPressed: _getImageFromCamera,
//                         ),
//                         // ElevatedButton(
//                         //   style: ElevatedButton.styleFrom(
//                         //       foregroundColor: const Color(0xFFF2C18D),
//                         //       backgroundColor: const Color(0xFFA5DD9B)),
//                         //   onPressed: _getImageFromCamera,
//                         //   child: const Text('Camera'),
//                         // ),
//                         const SizedBox(width: 50),
//                         IconButton(
//                           icon: const Icon(Icons.photo_library_outlined,
//                               size: 50), // Camera icon
//                           onPressed: _getImageFromGallery,
//                         ), // remove these values
//                         // ElevatedButton(
//                         //   style: ElevatedButton.styleFrom(
//                         //   foregroundColor: const Color(0xFFF2C18D),
//                         //   backgroundColor: const Color(0xFFA5DD9B)),
//                         //   onPressed: _getImageFromGallery,
//                         //   child: const Icon(Icons.photo_library_outlined,
//                         //       size: 50), //const Text('Gallery'),
//                         // ),
//                         const SizedBox(width: 16), // remove these values
//                       ],
//                     ),
//                     if (_imageFile != null)
//                       // IconButton(
//                       //   icon: const Icon(
//                       //     Icons.search,
//                       //     size: 70,
//                       //     color: Colors.brown,
//                       //   ), // Camera icon
//                       //   onPressed: () async {
//                       //     _detectObjects();
//                       //     setState(() {
//                       //       _boundingBoxesWidgets = [];
//                       //     });
//                       //   },
//                       // ),
//                       ElevatedButton(
//                           onPressed: () async {
//                             _detectObjects();
//                             setState(() {
//                               _boundingBoxesWidgets = [];
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             // foregroundColor: const Color(0xFFF2C18D),
//                             // backgroundColor: const Color(0xFFA5DD9B),
//                             shape: const CircleBorder(), // Round shape
//                             padding: const EdgeInsets.all(20.0),
//                           ),
//                           child: const Icon(
//                             Icons.search,
//                             size: 50,
//                           ))
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       if (isLoading)
//         const Opacity(
//           opacity: 0.5,
//           child: ModalBarrier(dismissible: false, color: Colors.black),
//         ),
//       if (isLoading)
//         const Center(
//           child: Icon(
//             Icons.hourglass_bottom,
//             size: 50,
//             color: Colors.white,
//           ), //Text("detecting..."),
//           //   AnimatedDefaultTextStyle(
//           // style: TextStyle(
//           //     color: Colors.white,
//           //     fontSize: 30,
//           //     fontStyle: FontStyle.italic,
//           //     letterSpacing: 4.0),
//           // duration: Duration(seconds: 1),
//           // curve: Curves.bounceIn,
//           // child:
//           //)
//         ),
//     ]);
//   }
// }

// // remove hardcoded values+++++++++++++++++++++
// // round image+++++++++++++++++++
// // increase padding++++++++++++++++
// // text size+++++++++++++++++++++
// // add circular indicator / overlay screen with loading state+++++++++++
// // format results to have only 1 bounding box per image location
// // result summary(notification banner) +++++++++++++++++
// // restructure buttons; camera & gallery, when image selected, detected and remove
// // transition when on
// // on boarding
// // border...white border dark shadow
// // color wheel: 3 colors(title&back), buttons&border
// // disable landscape mode
// // app icon
// // remove debug sticker
// // detect button pressed in

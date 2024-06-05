// // main.dart
// import 'dart:math';

// import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite/tflite.dart';
// // import 'package:flutter/widgets.dart';
// import 'dart:io';
// import 'dart:ui' as ui;

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
//   File? _imageFile;
//   List<dynamic>? _recognitions;
//   List<Widget> _personBoxes = [];
//   GlobalKey imageKey = GlobalKey();

//   // late double _imageWidth;
//   // late double _imageHeight;

//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }

//   Future<void> _loadModel() async {
//     // Load the TFLite model from the assets folder
//     Tflite.close();
//     String? res;
//     try {
//       res = await Tflite.loadModel(
//         model: 'assets/yolov5.tflite',
//         labels: 'assets/yolov5.txt',
//         // model: "assets/yolov2_tiny.tflite",
//         // labels: "assets/yolov2_tiny.txt",
//       );
//     } catch (e) {
//       print(e);
//     }
//     print(res);
//     // [{rect: {w: 0.7892502546310425,
//     //x: 0.1785871833562851,
//     //h: 0.9506446123123169,
//     //y: 0.01879747025668621},
//     //confidenceInClass: 0.6324225068092346,
//     //detectedClass: person}]
//   }

//   Future<void> _detectObjects() async {
//     if (_imageFile != null) {
//       var recognitions = await Tflite.detectObjectOnImage(
//         path: _imageFile!.path,
//         model: "YOLO",
//         threshold: 0.5,
//         imageMean: 0.0,
//         imageStd: 255.0,
//         numResultsPerClass: 5,
//         // blockSize: 16,
//         // anchors: [0.485, 0.456, 0.406],
//         // numBoxesPerBlock: 2,
//         // asynch: true,
//       );

//       setState(() {
//         print(_recognitions);
//         _recognitions = recognitions;
//       });
//     }
//   }

//   List<Widget> renderBoxes(ui.Size screen) {
//     if (_recognitions == null) return [];
//     print(screen.width);
//     print(screen.height);

//     return _recognitions!.map((re) {
//       Color blue = Colors.primaries[Random().nextInt(Colors.primaries.length)];

//       return Positioned(
//         left: re["rect"]["x"] * screen.width,
//         top: re["rect"]["y"] * screen.height,
//         width: re["rect"]["w"] * screen.width,
//         height: re["rect"]["h"] * screen.height,
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//             color: blue,
//             width: 3,
//           )),
//           child: Text(
//             "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toString()}",
//             style: TextStyle(
//                 background: Paint()..color = blue,
//                 color: Colors.white,
//                 fontSize: 15),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   Future<void> _getImageFromCamera() async {
//     final picker = ImagePicker();
//     // ignore: deprecated_member_use
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });

//       // final imageData = await _imageFile!.readAsBytes();
//       // final decodedImage = await decodeImageFromList(imageData);

//       // setState(() {
//       //   _imageHeight = decodedImage.height.toDouble();
//       //   _imageWidth = decodedImage.width.toDouble();
//       // });
//     }
//   }

//   Future<void> _getImageFromGallery() async {
//     final picker = ImagePicker();
//     // ignore: deprecated_member_use
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });

//       // final imageData = await _imageFile!.readAsBytes();
//       // final decodedImage = await decodeImageFromList(imageData);

//       // setState(() {
//       //   _imageHeight = decodedImage.height.toDouble();
//       //   _imageWidth = decodedImage.width.toDouble();
//       // });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ui.Size size = MediaQuery.of(context).size;
//     // List<Widget> stackChildren = [];

//     // stackChildren.addAll(renderBoxes(size));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Object Detection'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _imageFile == null
//                 ? const SizedBox(
//                     height: 300,
//                     child: Center(
//                       child: Text('No Image Selected'),
//                     ),
//                   )
//                 : Container(
//                     constraints: const BoxConstraints(
//                         minWidth: 500,
//                         minHeight: 500,
//                         maxHeight: 500,
//                         maxWidth: 500),
//                     child: Stack(
//                       children: [
//                         Image.file(
//                           key: imageKey,
//                           _imageFile!,
//                           fit: BoxFit.contain,
//                           alignment: Alignment.center,
//                         ),
//                         ..._personBoxes
//                       ],
//                     ),
//                   ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _getImageFromCamera,
//                   child: const Text('Camera'),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: _getImageFromGallery,
//                   child: const Text('Gallery'),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await _detectObjects();
//                     final result = renderBoxes(Size(
//                         imageKey.currentContext!.size!.width,
//                         imageKey.currentContext!.size!.height));
//                     setState(() {
//                       _personBoxes = result;
//                     });
//                   },
//                   child: const Text('Detect'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

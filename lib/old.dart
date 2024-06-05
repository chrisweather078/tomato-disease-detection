// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:math';
// import './yolo.dart';

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
//   GlobalKey imageKey = GlobalKey();

//   String _imagePath = "";

//   final List<Widget> _boundingBoxesWidgets = [];

//   Future<void> _detectObjects(double width, double height) async {
//     testYolov5(_imagePath);
//     // print(finalRecognitions);
//     for (var rec in finalRecognitions) {
//       Color rndClr =
//           Colors.primaries[Random().nextInt(Colors.primaries.length)];

//       _boundingBoxesWidgets.add(Positioned(
//         left: rec[2] * width,
//         top: rec[3] * height,
//         width: rec[4] * width,
//         height: rec[5] * height,
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//             color: rndClr,
//             width: 3,
//           )),
//           child: Text(
//             "${rec[0]} ${(rec[1] * 100).toString()}",
//             style: TextStyle(
//                 background: Paint()..color = rndClr,
//                 color: Colors.white,
//                 fontSize: 15),
//           ),
//         ),
//       ));
//     }
//     // print(_boundingBoxesWidgets);
//   }

//   Future<void> _getImageFromCamera() async {
//     final picker = ImagePicker();
//     // ignore: deprecated_member_use
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _imagePath = pickedFile.path;
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
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tomato Disease Detection'),
//         centerTitle: true,
//         backgroundColor: Colors.greenAccent,
//       ),
//       backgroundColor: Colors.blueGrey.shade200,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _imageFile == null
//                 ? const SizedBox(
//                     height: 450,
//                     child: Center(
//                       child: Text('No Image Selected'),
//                     ),
//                   )
//                 : Container(
//                     //padding: const EdgeInsets.all(8),
//                     height: 450,
//                     // width: 320,
//                     //margin: const EdgeInsets.symmetric(horizontal: 8),
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         border: Border.all(
//                             color: Colors.black,
//                             width: 5.0,
//                             style: BorderStyle.solid)),
//                     // constraints: const BoxConstraints(
//                     //     minWidth: 400,
//                     //     minHeight: 400,
//                     //     maxHeight: 400,
//                     //     maxWidth: 500),
//                     child: Stack(
//                       children: [
//                         Image.file(
//                           key: imageKey,
//                           _imageFile!,
//                           fit: BoxFit.contain,
//                         ),
//                         ..._boundingBoxesWidgets,
//                       ],
//                     ),
//                   ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 50),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _getImageFromCamera,
//                         child: const Text('Camera'),
//                       ),
//                       const SizedBox(width: 50),
//                       ElevatedButton(
//                         onPressed: _getImageFromGallery,
//                         child: const Text('Gallery'),
//                       ),
//                       const SizedBox(width: 16),
//                     ],
//                   ),
//                   ElevatedButton(
//                       onPressed: () async {
//                         _detectObjects(imageKey.currentContext!.size!.width,
//                             imageKey.currentContext!.size!.height);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         shape: const CircleBorder(), // Round shape
//                         padding: const EdgeInsets.all(30.0),
//                         //backgroundColor: Colors.blue, // Background color
//                       ),
//                       child: const Text('Detect'))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

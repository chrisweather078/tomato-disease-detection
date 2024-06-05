import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

late Interpreter interpreter;
late List finalRecognitions;

loadModel() async {
  interpreter = await Interpreter.fromAsset('assets/model.lite');
}

testYolov5(String imagePath) async {
  img.Image? image = await _loadImage(imagePath);
  final input = _preProcess(image!);

  final output = List<num>.filled(1 * 6300 * 8, 0).reshape([1, 6300, 8]);
  int predictionTimeStart = DateTime.now().millisecondsSinceEpoch;

  interpreter.run([input], output);

  int predictionTime =
      DateTime.now().millisecondsSinceEpoch - predictionTimeStart;
  print('Prediction time: $predictionTime ms');

  finalRecognitions = formatRecognitions(output);
  // print(finalRecognitions);

  // return recognitions;
}

// how to figure out the structure of the output after running inference
Future<img.Image?> _loadImage(String imagePath) async {
  final file = File(imagePath);
  final imageData = await file.readAsBytes();
  return img.decodeImage(imageData.buffer.asUint8List());
}

List<List<List<num>>> _preProcess(img.Image image) {
  final imgResized = img.copyResize(image, width: 320, height: 320);

  return convertImageToMatrix(imgResized);
}

// yolov5 requires input normalized between 0 and 1
List<List<List<num>>> convertImageToMatrix(img.Image image) {
  return List.generate(
    image.height,
    (y) => List.generate(
      image.width,
      (x) {
        final pixel = image.getPixel(x, y);
        return [pixel.rNormalized, pixel.gNormalized, pixel.bNormalized];
      },
    ),
  );
}

List<List> formatRecognitions(List recognitions) {
  List<List> recognitionList = [];
  const double confThr = 0.50;
  const int classNum = 3;
  const double classConf = 0.50;

  // Iterate through each detection
  for (var recognition in recognitions[0]) {
    // check obj conf
    if (recognition[4] < confThr) {
      continue; // checks if the array is an actual object
    }

    // check cls conf
    double maxClsConf = recognition.sublist(5, 8).reduce(
        (double max, double current) =>
            current > max ? current : max); //;.reduce(max);
    if (maxClsConf < classConf) {
      continue; // check which of the classes the object belongs
    }

    // add detects
    int classIndex = recognition.sublist(5, 8).indexOf(maxClsConf) % classNum;

    double confidence = maxClsConf;
    double x = recognition[0];
    double y = recognition[1];
    double w = recognition[2];
    double h = recognition[3];

    // const List<String> displayLabels = ['Early Blight','Healthy','Late Blight'];

    recognitionList.add([classIndex, confidence, x, y, w, h]);
  }

  return recognitionList;
}

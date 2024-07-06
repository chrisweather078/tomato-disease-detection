import 'package:tflite_flutter/tflite_flutter.dart'; // importing of package
import 'package:image/image.dart' as img;
import 'dart:io';

late Interpreter interpreter; // initializing interpreter for inference
late List finalRecognitions;

loadModel() async {
  interpreter =
      await Interpreter.fromAsset('assets/model.lite'); // loading tflite model
}

testYolov5(String imagePath) async {
  img.Image? image = await _loadImage(imagePath);
  final input = _preProcess(image!);

  final output = List<num>.filled(1 * 25200 * 13, 0).reshape([1, 25200, 13]);
  int predictionTimeStart = DateTime.now().millisecondsSinceEpoch;

  interpreter.run([input], output); // running inference on pre-processed image

  int predictionTime =
      DateTime.now().millisecondsSinceEpoch - predictionTimeStart;
  print('Prediction time: $predictionTime ms');

  finalRecognitions = formatRecognitions(output);
  // print(finalRecognitions);
}

// how to figure out the structure of the output after running inference
Future<img.Image?> _loadImage(String imagePath) async {
  final file = File(imagePath);
  final imageData = await file.readAsBytes();
  return img.decodeImage(imageData.buffer.asUint8List());
}

List<List<List<num>>> _preProcess(img.Image image) {
  final imgResized =
      img.copyResize(image, width: 640, height: 640); // resizing of image

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
  const double confThr = 0.80; // class confidence threshold
  const int classNum = 8; // number of output classes
  const double classScr = 0.50; // class score threshold

  // Iterate through each detection
  for (var recognition in recognitions[0]) {
    // check obj conf
    if (recognition[4] < confThr) {
      continue; // checks if the array is an actual object
    }

    // check cls conf
    double maxClsConf = recognition.sublist(5).reduce(
        (double max, double current) =>
            current > max ? current : max); //;.reduce(max);
    if (maxClsConf < classScr) {
      continue; // check which of the classes the object belongs
    }

    // add detects
    int classIndex = recognition.sublist(5).indexOf(maxClsConf) % classNum;

    double confidence = maxClsConf;
    double x = recognition[0];
    double y = recognition[1];
    double w = recognition[2];
    double h = recognition[3];

    recognitionList.add([classIndex, confidence, x, y, w, h]);
  }

  return recognitionList;
}

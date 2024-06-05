class Recognition {
  final int classIndex;
  final double confidence;
  final BoundingBox box;

  Recognition({
    required this.classIndex,
    required this.confidence,
    required this.box,
  });
}

class BoundingBox {
  final double xMin;
  final double yMin;
  final double xMax;
  final double yMax;

  BoundingBox({
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });
}

// List<Recognition> predict(List outputLocations) {
//   const int inputSize = 320;
//   // late List<List<int>> _outputShapes;
//   // late List<TfLiteType> _outputTypes;

//   const int clsNum = 9;
//   const double objConfTh = 0.25;
//   const double clsConfTh = 0.25;

//   /// make recognition
//   final recognitions = <Recognition>[];
//   List<double> results = outputLocations; //.getDoubleList();
//   for (var i = 0; i < results.length; i += (5 + clsNum)) {
//     // check obj conf
//     if (results[i + 4] < objConfTh) continue;

//     /// check cls conf
//     // double maxClsConf = results[i + 5];
//     double maxClsConf = results.sublist(i + 5, i + 5 + clsNum - 1).reduce(max);
//     if (maxClsConf < clsConfTh) continue;

//     /// add detects
//     // int cls = 0;
//     int cls =
//         results.sublist(i + 5, i + 5 + clsNum - 1).indexOf(maxClsConf) % clsNum;
//     Rect outputRect = Rect.fromCenter(
//       center: Offset(
//         results[i] * inputSize,
//         results[i + 1] * inputSize,
//       ),
//       width: results[i + 2] * inputSize,
//       height: results[i + 3] * inputSize,
//     );
//     // Rect transformRect = imageProcessor!.inverseTransformRect(outputRect, image.height, image.width);
//     recognitions.add(Recognition(i, cls, maxClsConf, outputRect));
//   }
//   return recognitions;
// }


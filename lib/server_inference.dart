import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> serverDetect(String imagePath) async {
  final url = Uri.parse('http://192.168.43.121:5000/detect');
  final request = http.MultipartRequest('POST', url);

  request.files.add(await http.MultipartFile.fromPath('image', imagePath));

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      // var jsonResponse = json.decode(responseBody);
      print('Inference result: $responseBody');
    } else {
      print('Failed to get inference. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending request: $e');
  }
}

List<List<num>> convertResponse(List<List<String>> response) {
  return response.map((sublist) {
    return sublist.map((item) {
      if (item.contains('.')) {
        return double.parse(item);
      } else {
        return int.parse(item);
      }
    }).toList();
  }).toList();
}

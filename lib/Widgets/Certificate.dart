import 'package:http/http.dart' as http;

fetchImage() async {
  final url = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/sis-system-e2f83.appspot.com/o/Users%2FImages%2FvGM8uw0fKoeI4SEnmMOzqi8fi8r1.jpg?alt=media&token=a408e6db-79aa-491c-bbc7-8f55d79a8050');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successfully fetched the image data.
      // You can use response.bodyBytes to access the image data as bytes.
      // Example: Uint8List imageBytes = response.bodyBytes;
      // You can then display the image using an Image.memory widget or save it to a file.
      return url;
    } else {
      // Handle HTTP error (e.g., 404 not found).
    }
  } catch (e) {
    // Handle any other errors that might occur during the request.
    print('Error: $e');
  }
}

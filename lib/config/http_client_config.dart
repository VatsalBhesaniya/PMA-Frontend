class HttpClientConfig {
  HttpClientConfig({
    required this.baseUrl,
  });

  final String baseUrl;
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:pma/constants/api_constants.dart';

// class HttpClientConfig {
//   String get baseUrl => Platform.isAndroid ? androidBaseUrl : iosBaseUrl;

//   Future<dynamic> get(String url) async {
//     final dynamic responseJson;
//     try {
//       final http.Response response = await http.get(Uri.parse(baseUrl + url));
//       responseJson = _response(response);
//     } on SocketException {
//       throw const SocketException('No Internet connection');
//     }
//     return responseJson;
//   }

//   dynamic _response(http.Response response) {
//     switch (response.statusCode) {
//       case 200:
//         return jsonDecode(response.body);
//       case 400:
//         throw http.ClientException(response.body);
//       case 401:
//       case 403:
//         throw super(response.body, 'Unauthorized');
//       case 500:

//       default:
//         throw FetchDataException(
//             'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
//     }
//   }
// }

class DioConfig {
  DioConfig({
    required this.baseUrl,
    required this.headers,
  });
  final String baseUrl;
  final Map<String, dynamic> headers;

  void addAccessTokenToHeader({required String value}) {
    headers['authorization'] = value;
  }
}

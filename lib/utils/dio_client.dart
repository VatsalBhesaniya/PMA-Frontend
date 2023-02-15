import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pma/constants/enum.dart';

export 'package:dio/dio.dart';
export 'package:pma/constants/enum.dart';

class DioClient {
  DioClient({
    required this.baseURL,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseURL,
            connectTimeout: const Duration(minutes: 1),
            receiveTimeout: const Duration(minutes: 1),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
          ),
        );

  final String baseURL;
  final Dio _dio;

  void addAccessTokenToHeader({required String value}) {
    _dio.options.headers['authorization'] = value;
  }

  Future<T?> request<T>({
    required HttpMethod httpMethod,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    FormData? data,
  }) async {
    try {
      late Response<T> response;
      switch (httpMethod) {
        case HttpMethod.get:
          response = await _dio.get<T>(
            url,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case HttpMethod.post:
          response = await _dio.post<T>(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case HttpMethod.put:
          response = await _dio.put<T>(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case HttpMethod.delete:
          response = await _dio.delete<T>(
            url,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case HttpMethod.patch:
          response = await _dio.patch<T>(
            url,
            data: queryParameters,
            options: Options(
              headers: headers,
            ),
          );
          break;
      }
      return response.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException('Unable to process the data');
    } on Exception catch (_) {
      rethrow;
    }
  }
}

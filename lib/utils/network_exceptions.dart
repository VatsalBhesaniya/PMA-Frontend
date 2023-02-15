import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions with _$NetworkExceptions {
  factory NetworkExceptions.dioException(Exception exception) {
    try {
      NetworkExceptions networkExceptions;
      if (exception is DioError) {
        switch (exception.type) {
          case DioErrorType.cancel:
            networkExceptions = const NetworkExceptions.requestCancelled();
            break;
          case DioErrorType.connectionTimeout:
            networkExceptions = const NetworkExceptions.requestTimeout();
            break;
          case DioErrorType.receiveTimeout:
            networkExceptions = const NetworkExceptions.receiveTimeout();
            break;
          case DioErrorType.sendTimeout:
            networkExceptions = const NetworkExceptions.sendTimeout();
            break;
          case DioErrorType.badCertificate:
            networkExceptions = const NetworkExceptions.badCertificate();
            break;
          case DioErrorType.connectionError:
            networkExceptions = const NetworkExceptions.noInternetConnection();
            break;
          case DioErrorType.unknown:
            networkExceptions = const NetworkExceptions.unexpectedError();
            break;
          case DioErrorType.badResponse:
            networkExceptions = NetworkExceptions.handleResponse(exception);
            break;
        }
      } else if (exception is SocketException) {
        networkExceptions = const NetworkExceptions.noInternetConnection();
      } else {
        networkExceptions = const NetworkExceptions.unexpectedError();
      }
      return networkExceptions;
    } on FormatException catch (_) {
      return const NetworkExceptions.formatException();
    } on Exception catch (_) {
      return const NetworkExceptions.unexpectedError();
    }
  }

  const factory NetworkExceptions.requestCancelled() = RequestCancelled;
  const factory NetworkExceptions.requestTimeout() = RequestTimeout;
  const factory NetworkExceptions.receiveTimeout() = ReceiveTimeout;
  const factory NetworkExceptions.sendTimeout() = SendTimeout;
  const factory NetworkExceptions.badCertificate() = BadCertificate;
  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;
  const factory NetworkExceptions.unexpectedError() = UnexpectedError;
  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.badRequest(DioError e) = BadRequest;
  const factory NetworkExceptions.unauthorizedAccess() = UnauthorizedAccess;
  const factory NetworkExceptions.unauthorizedRequest() = UnauthorizedRequest;
  const factory NetworkExceptions.notFound(String reason) = NotFound;
  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;
  const factory NetworkExceptions.notAcceptable() = NotAcceptable;
  const factory NetworkExceptions.conflict() = Conflict;
  const factory NetworkExceptions.unprocessableEntity() = UnprocessableEntity;
  const factory NetworkExceptions.internalServerError() = InternalServerError;
  const factory NetworkExceptions.notImplemented() = NotImplemented;
  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;
  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  factory NetworkExceptions.handleResponse(DioError e) {
    switch (e.response?.statusCode) {
      case 400:
        return NetworkExceptions.badRequest(e);
      case 401:
        return const NetworkExceptions.unauthorizedAccess();
      case 403:
        return const NetworkExceptions.unauthorizedRequest();
      case 404:
        return const NetworkExceptions.notFound('Not found');
      case 405:
        return const NetworkExceptions.methodNotAllowed();
      case 406:
        return const NetworkExceptions.notAcceptable();
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 409:
        return const NetworkExceptions.conflict();
      case 422:
        return const NetworkExceptions.unprocessableEntity();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 501:
        return const NetworkExceptions.notImplemented();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        final int? responseCode = e.response?.statusCode;
        return NetworkExceptions.defaultError(
          'Received invalid status code: $responseCode',
        );
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    String errorMessage = '';
    networkExceptions.when(
      requestCancelled: () {
        errorMessage = 'Request Cancelled';
      },
      requestTimeout: () {
        errorMessage = 'Connection request timeout';
      },
      receiveTimeout: () {
        errorMessage = 'Recieve timeout';
      },
      sendTimeout: () {
        errorMessage = 'Send timeout in connection with API server';
      },
      badCertificate: () {
        errorMessage = 'Bad Certificate';
      },
      noInternetConnection: () {
        errorMessage = 'No internet connection';
      },
      unexpectedError: () {
        errorMessage = 'Unexpected error occurred';
      },
      formatException: () {
        errorMessage = 'Unexpected error occurred';
      },
      badRequest: (DioError e) {
        if (e.response == null) {
          errorMessage = 'Bad request';
        } else {
          errorMessage = jsonEncode(e.response);
        }
      },
      unauthorizedAccess: () {
        errorMessage = 'Unauthorized access';
      },
      unauthorizedRequest: () {
        errorMessage = 'Unauthorized request';
      },
      notFound: (String reason) {
        errorMessage = reason;
      },
      methodNotAllowed: () {
        errorMessage = 'Method Not Allowed';
      },
      notAcceptable: () {
        errorMessage = 'Not acceptable';
      },
      conflict: () {
        errorMessage = 'Error due to a conflict';
      },
      unprocessableEntity: () {
        errorMessage = 'Unable to process the data';
      },
      internalServerError: () {
        errorMessage = 'Internal Server Error';
      },
      notImplemented: () {
        errorMessage = 'Not Implemented';
      },
      serviceUnavailable: () {
        errorMessage = 'Service unavailable';
      },
      defaultError: (String error) {
        errorMessage = error;
      },
    );
    return errorMessage;
  }
}

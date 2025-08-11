import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/services/api_service.dart';

final client = ApiService(Dio());

final dio = getDio();

Dio getDio() {
  BaseOptions options = BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  Dio dio = Dio(options);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) {
        debugPrint("API request BODY: ${request.data}");
        return handler.next(request);
      },
      onResponse: (response, handler) {
        debugPrint("API Response: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final response = e.response;
        debugPrint("API Error --> statusCode: ${response?.statusCode} --> ${response?.statusMessage}: Error --> ${e.toString()}");
        return handler.next(e);
      },
    ),
  );

  return dio;
}
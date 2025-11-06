// Добавьте этот класс в тот же файл dio_client.dart
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('🌐 REQUEST[${options.method}] => FULL URL: ${options.uri}');
    print('📋 REQUEST[${options.method}] => HEADERS: ${options.headers}');
    if (options.data != null) {
      print('📦 REQUEST[${options.method}] => BODY: ${options.data}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📄 RESPONSE[${response.statusCode}] => DATA: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ ERROR[${err.response?.statusCode}] => MESSAGE: ${err.message}');
    print('❌ ERROR[${err.response?.statusCode}] => TYPE: ${err.type}');
    if (err.response != null) {
      print('❌ ERROR[${err.response?.statusCode}] => RESPONSE DATA: ${err.response?.data}');
      print('❌ ERROR[${err.response?.statusCode}] => RESPONSE HEADERS: ${err.response?.headers}');
    }
    return super.onError(err, handler);
  }
}
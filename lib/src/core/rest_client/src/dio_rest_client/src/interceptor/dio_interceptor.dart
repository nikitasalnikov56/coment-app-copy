// import 'dart:io';
// import 'package:coment_app/src/core/rest_client/rest_client.dart';

// import 'package:dio/dio.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:coment_app/src/core/utils/talker_logger_util.dart';
// import 'package:coment_app/src/feature/app/logic/not_auth_logic.dart';

// /// `DioInterceptor` - This class is used to intercept `dio` errors.
// class DioInterceptor extends Interceptor {
//   const DioInterceptor({
//     required IRestClient restClient,

//   })  : _restClient = restClient;


//   // final Dio _dio;
//   final IRestClient _restClient;
//   // @override
//   // Future<void> onError(
//   //   DioException err,
//   //   ErrorInterceptorHandler handler,
//   // ) async {
//   //   final errorMessage = _parseDioError(err);

//   //   if ((err.response?.statusCode ?? 0) == HttpStatus.unauthorized) {
//   //     NotAuthLogic().statusSubject.add(401);
//   //     return handler.reject(
//   //       DioException(
//   //         error: err,
//   //         message: errorMessage,
//   //         requestOptions: err.requestOptions,
//   //         response: err.response,
//   //         type: err.type,
//   //       ),
//   //     );
//   //   }

//   //   return handler.reject(
//   //     DioException(
//   //       error: err,
//   //       message: errorMessage,
//   //       requestOptions: err.requestOptions,
//   //       response: err.response,
//   //       type: err.type,
//   //     ),
//   //   );
//   // }

//   @override
//   Future<void> onError(
//       DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       try {
//         // 1. Обновляем access_token
//         final authRepo = _restClient.authRepository;
//         await authRepo.refreshAccessToken();

//         // 2. Повторяем запрос через ТОТ ЖЕ Dio клиент (со всеми интерцепторами!)
//         final options = err.requestOptions;
//         final newResponse = await _restClient.dio.fetch<Response>(options);

//         return handler.resolve(newResponse);
//       } catch (e, st) {
//         TalkerLoggerUtil.talker.error('Token refresh failed', e, st);
//         final authRepo = _restClient.authRepository;
//         await authRepo.clearUser();
//         NotAuthLogic().statusSubject.add(401);
//         return handler.reject(err);
//       }
//     }

//     return super.onError(err, handler);
//   }

//   /// Return text of error message based on Error type
//   String _parseDioError(DioException error) {
//     switch (error.response?.statusCode) {
//       case HttpStatus.unauthorized:
//         try {
//           return ((error.response?.data as Map<String, dynamic>)['message']
//                   as String?) ??
//               'HttpStatus.unauthorized';
//         } catch (e, st) {
//           TalkerLoggerUtil.talker.error('Not authorized: $e');
//           // ISpectTalker.handle(exception: 'Not authorized: $e', stackTrace: st);
//           _sentryLogger(error: 'Not authorized: $e', stackTrace: st);
//           return 'Not authorized. Please log in again!';
//         }
//       case HttpStatus.notFound:
//         return ((error.response?.data as Map<String, dynamic>)['message']
//                 as String?) ??
//             'The content you are looking for has not been found!';
//       // return 'The content you are looking for has not been found!';
//       case HttpStatus.requestEntityTooLarge:
//         return 'Request Entity Too Large';
//       case HttpStatus.internalServerError:
//         try {
//           return ((error.response?.data as Map<String, dynamic>)['message']
//                   as String?) ??
//               'Unknown error[500]';
//         } catch (e, st) {
//           TalkerLoggerUtil.talker
//               .error('Something is wrong with our servers: $e');
//           // ISpectTalker.handle(
//           //   exception: 'Something is wrong with our servers: $e',
//           //   stackTrace: st,
//           // );
//           _sentryLogger(
//             error: '''Something is wrong with our servers: $e''',
//             stackTrace: st,
//           );
//           return '''Something is wrong with our servers, the problem will be solved soon!''';
//         }
//       default:
//         try {
//           _sentryLogger(error: error, stackTrace: error.stackTrace);
//           return ((error.response?.data as Map<String, dynamic>?)?['message']
//                   as String?) ??
//               'Unknown error[${error.response?.statusCode}]';
//         } catch (e, st) {
//           TalkerLoggerUtil.talker.error(
//             '''HTTP NetworkException: $e\nStatus code: ${error.response?.statusCode}\nError type: ${error.type.name}\nResponse data: ${error.response?.data}''',
//           );
//           // ISpectTalker.handle(
//           //   exception:
//           //       '''HTTP NetworkException: $e\nStatus code: ${error.response?.statusCode}\nError type: ${error.type.name}\nResponse data: ${error.response?.data}''',
//           //   stackTrace: st,
//           // );
//           _sentryLogger(error: 'HTTP NetworkException: $e', stackTrace: st);
//           return error.response?.statusCode != null
//               ? '''HTTP (${error.response?.statusCode}) ${error.type.name} -  ${error.response?.data} : $e'''
//               : 'NetworkException: ${error.type.name}';
//         }
//     }
//   }

//   /// Send error to Sentry
//   void _sentryLogger({required Object error, required StackTrace stackTrace}) {
//     Sentry.captureException(error, stackTrace: stackTrace);
//   }
// }
import 'package:dio/dio.dart';
import 'package:coment_app/src/feature/app/logic/not_auth_logic.dart';
class DioInterceptor extends Interceptor {
  



  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
    
        NotAuthLogic().statusSubject.add(401);
        return handler.reject(err);
    }
    return super.onError(err, handler);
  }
}
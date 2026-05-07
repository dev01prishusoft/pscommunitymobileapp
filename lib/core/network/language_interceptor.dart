import 'package:dio/dio.dart';
import 'package:get/get.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final locale = Get.locale?.languageCode ?? 'en';
    options.headers['Accept-Language'] = locale;
    handler.next(options);
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String locale = Get.locale?.languageCode ?? 'en';
    if (locale == 'gu') {
      locale = 'gj';
    }
    options.headers['Accept-Language'] = locale;
    handler.next(options);
  }
}

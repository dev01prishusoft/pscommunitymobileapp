import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:pscommunitymobileapp/core/localization/localization_service.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String locale = 'en';
    if (Get.isRegistered<LocalizationService>()) {
      locale = Get.find<LocalizationService>().currentLocale.value.languageCode;
    } else {
      locale = Get.locale?.languageCode ?? 'en';
    }
    options.headers['Accept-Language'] = locale;
    handler.next(options);
  }
}

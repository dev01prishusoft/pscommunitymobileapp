import 'dart:async';

import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/errors/failures.dart';

enum FormSubmissionState { idle, loading, success, error }

mixin FormStateMixin on GetxController {
  final Rx<FormSubmissionState> formState = FormSubmissionState.idle.obs;
  final RxnString formError = RxnString();
  
  bool get isFormLoading => formState.value == FormSubmissionState.loading;
  bool get isFormSuccess => formState.value == FormSubmissionState.success;
  bool get isFormError => formState.value == FormSubmissionState.error;

  bool _isThrottling = false;
  Future<void> submitThrottled(Future<void> Function() submitAction) async {
    if (_isThrottling || isFormLoading) return;
    
    _isThrottling = true;
    formState.value = FormSubmissionState.loading;
    formError.value = null;

    try {
      await submitAction();
      formState.value = FormSubmissionState.success;
    } on Failure catch (f) {
      formError.value = f.message;
      formState.value = FormSubmissionState.error;
    } catch (e) {
      formError.value = e.toString();
      formState.value = FormSubmissionState.error;
    } finally {
      _isThrottling = false;
    }
  }

  void resetFormState() {
    formState.value = FormSubmissionState.idle;
    formError.value = null;
  }
}

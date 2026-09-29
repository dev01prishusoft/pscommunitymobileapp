import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/pending_payment.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/retry.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';
import 'package:pscommunitymobileapp/features/events/repositories/events_repositories.dart';
import 'package:pscommunitymobileapp/features/payment/repositories/payment_repository.dart';
import 'package:pscommunitymobileapp/features/payment/repositories/pending_payment_store.dart';

/// Verifies captured Razorpay payments with the backend, retrying transient
/// failures. Shared by the payment/event controllers (right after checkout)
/// and by HomeController (on the next launch, for interrupted verifications).
class PaymentReconciler {
  PaymentReconciler({
    required PaymentRepository paymentRepository,
    required EventsRepositories eventsRepository,
    required PendingPaymentStore store,
  }) : _paymentRepository = paymentRepository,
       _eventsRepository = eventsRepository,
       _store = store;

  factory PaymentReconciler.fromGet() => PaymentReconciler(
    paymentRepository: Get.find<PaymentRepository>(),
    eventsRepository: Get.find<EventsRepositories>(),
    store: PendingPaymentStore(Get.find<SecureStorageService>()),
  );

  final PaymentRepository _paymentRepository;
  final EventsRepositories _eventsRepository;
  final PendingPaymentStore _store;

  PendingPaymentStore get store => _store;

  /// Throws the last failure if verification did not succeed. The pending
  /// record is cleared only on success, or when the server definitively
  /// rejects it (so it is not retried forever).
  Future<Map<String, dynamic>> verifyPayment(PendingPayment p) async {
    try {
      final result = await retryTransient(
        () => _paymentRepository.verifyPayment(
          razorpayOrderId: p.razorpayOrderId,
          razorpayPaymentId: p.razorpayPaymentId,
          razorpaySignature: p.razorpaySignature,
          amount: p.amount,
          paymentTypeId: p.paymentTypeId,
          paymentCategoryId: p.paymentCategoryId,
          adminPaymentRequestId: p.adminPaymentRequestId,
          isRecurring: p.isRecurring,
        ),
      );
      await _store.clearPayment();
      return result;
    } catch (e) {
      if (!isTransientFailure(e)) await _store.clearPayment();
      rethrow;
    }
  }

  /// Same contract as [verifyPayment]; returns the server's success response.
  Future<ApiResponse<Map<String, dynamic>>> verifyEventPayment(
    PendingEventPayment p,
  ) async {
    try {
      final response = await retryTransient(() async {
        // No CancelToken on purpose: the money is already captured, so this
        // request must never be cancelled by unrelated screen activity.
        final result = await _eventsRepository.eventVerifyPayment(
          razorpayOrderId: p.razorpayOrderId,
          razorpayPaymentId: p.razorpayPaymentId,
          razorpaySignature: p.razorpaySignature,
          eventId: p.eventId,
          memberId: p.memberId,
          eventCouponId: p.eventCouponId,
          notes: '',
          guests: p.guests,
        );
        return switch (result) {
          Success(:final data) => data,
          Error(:final failure) => throw failure,
        };
      });
      await _store.clearEventPayment();
      return response;
    } catch (e) {
      if (!isTransientFailure(e)) await _store.clearEventPayment();
      rethrow;
    }
  }

  /// Retries any verification left over from a previous session. Safe to call
  /// on every launch; does nothing when there is no pending record.
  Future<void> reconcilePending() async {
    final payment = await _store.readPayment();
    if (payment != null) {
      try {
        await verifyPayment(payment);
      } catch (e, stack) {
        CrashReporter.recordError(
          e,
          stack,
          reason: 'PaymentReconciler: pending payment still unverified',
        );
      }
    }

    final eventPayment = await _store.readEventPayment();
    if (eventPayment != null) {
      try {
        await verifyEventPayment(eventPayment);
      } catch (e, stack) {
        CrashReporter.recordError(
          e,
          stack,
          reason: 'PaymentReconciler: pending event payment still unverified',
        );
      }
    }
  }
}

import 'dart:convert';

import 'package:pscommunitymobileapp/core/models/pending_payment.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';

/// Persists captured-but-unverified payments in secure storage.
///
/// Logout wipes secure storage, so a record never outlives the member who
/// made the payment; the backend webhook is the backstop for that case.
class PendingPaymentStore {
  PendingPaymentStore(this._storage);
  final SecureStorageService _storage;

  static const _paymentKey = 'pending_payment_verification';
  static const _eventPaymentKey = 'pending_event_payment_verification';

  Future<void> savePayment(PendingPayment payment) =>
      _storage.write(_paymentKey, jsonEncode(payment.toJson()));

  Future<PendingPayment?> readPayment() async {
    final json = await _readJson(_paymentKey);
    return json == null ? null : PendingPayment.fromJson(json);
  }

  Future<void> clearPayment() => _storage.delete(_paymentKey);

  Future<void> saveEventPayment(PendingEventPayment payment) =>
      _storage.write(_eventPaymentKey, jsonEncode(payment.toJson()));

  Future<PendingEventPayment?> readEventPayment() async {
    final json = await _readJson(_eventPaymentKey);
    return json == null ? null : PendingEventPayment.fromJson(json);
  }

  Future<void> clearEventPayment() => _storage.delete(_eventPaymentKey);

  Future<Map<String, dynamic>?> _readJson(String key) async {
    final raw = await _storage.read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Corrupt record: drop it rather than retrying garbage forever.
      await _storage.delete(key);
      return null;
    }
  }
}

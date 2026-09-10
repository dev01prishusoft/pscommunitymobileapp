import 'dart:convert';
import 'package:pscommunitymobileapp/core/module_permission/models/module_permission_model.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/secure_storage_service.dart';

/// Handles persistent encrypted storage of module permissions
/// so they are available immediately on cold launch even before network requests.
class ModulePermissionStorage {
  ModulePermissionStorage(this._storage);

  final SecureStorageService _storage;
  static const String _storageKey = 'cached_module_permissions_v1';

  /// Saves a list of module permissions to secure storage.
  Future<void> saveModules(List<ModulePermissionModel> modules) async {
    try {
      final jsonList = modules.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _storage.write(_storageKey, jsonString);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionStorage.saveModules failed',
      );
    }
  }

  /// Loads the cached list of module permissions from secure storage.
  Future<List<ModulePermissionModel>> loadModules() async {
    try {
      final jsonString = await _storage.read(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return <ModulePermissionModel>[];
      }
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => ModulePermissionModel.fromJson(item))
            .toList();
      }
      return <ModulePermissionModel>[];
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionStorage.loadModules failed',
      );
      return <ModulePermissionModel>[];
    }
  }

  /// Wipes cached module permissions on logout.
  Future<void> clear() async {
    try {
      await _storage.delete(_storageKey);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionStorage.clear failed',
      );
    }
  }
}

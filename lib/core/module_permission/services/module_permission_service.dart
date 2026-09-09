import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/network/api_endpoints.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/app_module.dart';
import 'package:pscommunitymobileapp/core/module_permission/models/module_permission_model.dart';
import 'package:pscommunitymobileapp/core/module_permission/storage/module_permission_storage.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';

/// Central reactive service for managing and querying Samaj module permissions.
class ModulePermissionService extends GetxService {
  ModulePermissionService({
    required ModulePermissionStorage storage,
    ApiClient? apiClient,
  })  : _storage = storage,
        _apiClient = apiClient;

  final ModulePermissionStorage _storage;
  ApiClient? _apiClient;

  /// Easy static accessor: `ModulePermissionService.to`
  static ModulePermissionService get to => Get.find<ModulePermissionService>();

  /// Reactive list of all module permissions
  final RxList<ModulePermissionModel> modules = <ModulePermissionModel>[].obs;

  /// Reactive map indexed by uppercase module code for O(1) checks
  final RxMap<String, ModulePermissionModel> _moduleMap =
      <String, ModulePermissionModel>{}.obs;

  /// Loading state for network fetch
  final RxBool isLoading = false.obs;

  /// Attach ApiClient lazily if not provided at construction time
  void attachApiClient(ApiClient client) {
    _apiClient = client;
  }

  /// Bootstrap service on application launch by reading cached permissions
  Future<void> bootstrap() async {
    try {
      final cached = await _storage.loadModules();
      _setModulesInternal(cached);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionService.bootstrap failed',
      );
    }
  }

  /// Check if a strongly-typed module is accessible (purchased and active).
  /// Primary UI check recommended by API documentation.
  bool isAccessible(AppModule module) {
    return _moduleMap[module.code]?.isAccessible == true;
  }

  /// Alias for [isAccessible], matching the documentation's `canUse(modules, code)` signature.
  bool canUse(AppModule module) => isAccessible(module);

  /// Check access by string code (e.g. 'PAYMENT', 'MATRIMONIAL').
  bool isAccessibleByCode(String? code) {
    if (code == null || code.trim().isEmpty) return false;
    return _moduleMap[code.trim().toUpperCase()]?.isAccessible == true;
  }

  /// Check if any of the given modules are accessible.
  bool isAnyAccessible(Iterable<AppModule> moduleList) {
    return moduleList.any(isAccessible);
  }

  /// Retrieve full permission details for a module.
  ModulePermissionModel? getModule(AppModule module) {
    return _moduleMap[module.code];
  }

  /// Retrieve full permission details by string code.
  ModulePermissionModel? getModuleByCode(String? code) {
    if (code == null) return null;
    return _moduleMap[code.trim().toUpperCase()];
  }

  /// List of only accessible modules.
  List<ModulePermissionModel> get accessibleModules =>
      modules.where((m) => m.isAccessible).toList();

  /// Updates module permissions from raw JSON list (as returned in login/refresh-token/my-modules payload).
  Future<void> updateFromRawList(dynamic rawList) async {
    if (rawList == null) return;
    try {
      final List<ModulePermissionModel> parsed = [];
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map) {
            parsed.add(
              ModulePermissionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          } else if (item is ModulePermissionModel) {
            parsed.add(item);
          }
        }
      }
      await updateModules(parsed);
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionService.updateFromRawList failed',
      );
    }
  }

  /// Replaces active permissions and persists them to secure storage.
  Future<void> updateModules(List<ModulePermissionModel> newModules) async {
    _setModulesInternal(newModules);
    await _storage.saveModules(newModules);
  }

  /// Fetch updated module permissions from the server without requiring re-login.
  /// (Section 9 of API documentation: GET /api/v1/samaj-module/my-modules)
  Future<void> fetchMyModules({bool silent = true}) async {
    final client = _apiClient ?? (Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null);
    if (client == null) return;

    try {
      isLoading.value = true;
      final response = await client.getParsed<List<ModulePermissionModel>>(
        ApiEndpoints.myModules,
        fromJsonT: (json) {
          if (json is List) {
            return json
                .whereType<Map<String, dynamic>>()
                .map((item) => ModulePermissionModel.fromJson(item))
                .toList();
          }
          return <ModulePermissionModel>[];
        },
      );

      final fetchedList = response.dataOrNull?.data;
      if (fetchedList != null) {
        await updateModules(fetchedList);
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'ModulePermissionService.fetchMyModules failed',
      );
      if (!silent) rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears in-memory and persisted module permissions.
  /// Should be called during logout.
  Future<void> clear() async {
    modules.clear();
    _moduleMap.clear();
    await _storage.clear();
  }

  void _setModulesInternal(List<ModulePermissionModel> list) {
    modules.assignAll(list);
    final map = <String, ModulePermissionModel>{};
    for (final mod in list) {
      map[mod.code.toUpperCase()] = mod;
    }
    _moduleMap.assignAll(map);
  }
}

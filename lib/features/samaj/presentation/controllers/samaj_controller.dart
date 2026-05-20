import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajController extends GetxController {
  final SamajRepository _repository;

  SamajController(this._repository);

  // ─── Observable State ─────────────────────────────────────────────────────

  final Rxn<Samaj> samaj = Rxn<Samaj>();
  final RxList<Sanstha> sansthas = <Sanstha>[].obs;

  /// Separate loading flags so the samaj profile and sanstha list
  /// can show their own independent loading indicators.
  final RxBool isSamajLoading = false.obs;
  final RxBool isSansthasLoading = false.obs;

  /// Separate error messages so each section can surface its own failure.
  final RxnString samajError = RxnString();
  final RxnString sansthaError = RxnString();

  // ─── Duplicate-request Guards ─────────────────────────────────────────────

  bool _isFetchingSamaj = false;
  bool _isFetchingSansthas = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Kicks off both calls in parallel and waits for both to complete.
  Future<void> fetchAll() async {
    await Future.wait([
      fetchSamajDetail(),
      fetchSansthas(),
    ]);
  }

  Future<void> fetchSamajDetail() async {
    if (_isFetchingSamaj) return; // Prevent duplicate in-flight request
    _isFetchingSamaj = true;

    isSamajLoading.value = true;
    samajError.value = null;

    try {
      final detail = await _repository.getSamajDetail();
      if (detail != null) {
        samaj.value = detail;
        AppLogger.d('Samaj details loaded: ${samaj.value?.name}');
      }
    } catch (e, stack) {
      samajError.value = e.toString();
      AppLogger.e('Failed to fetch samaj details', e, stack);
    } finally {
      isSamajLoading.value = false;
      _isFetchingSamaj = false;
    }
  }

  Future<void> fetchSansthas() async {
    if (_isFetchingSansthas) return; // Prevent duplicate in-flight request
    _isFetchingSansthas = true;

    isSansthasLoading.value = true;
    sansthaError.value = null;

    try {
      final results = await _repository.getSansthas();
      sansthas.assignAll(results);
      AppLogger.d('Sansthas loaded: ${sansthas.length}');
    } catch (e, stack) {
      sansthaError.value = e.toString();
      AppLogger.e('Failed to fetch sansthas', e, stack);
    } finally {
      isSansthasLoading.value = false;
      _isFetchingSansthas = false;
    }
  }
}

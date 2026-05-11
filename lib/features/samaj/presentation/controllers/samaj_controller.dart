import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajController extends GetxController {
  final SamajRepository _repository;

  SamajController(this._repository);

  final Rxn<Samaj> samaj = Rxn<Samaj>();
  final RxList<Sanstha> sansthas = <Sanstha>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSamajDetail();
    fetchSansthas();
  }

  Future<void> fetchSamajDetail() async {
    isLoading.value = true;
    try {
      final detail = await _repository.getSamajDetail();
      if (detail != null) {
        samaj.value = detail;
        AppLogger.d('Samaj details loaded: ${samaj.value?.name}');
      }
    } catch (e, stack) {
      AppLogger.e('Failed to fetch samaj details', e, stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSansthas() async {
    try {
      final results = await _repository.getSansthas();
      sansthas.assignAll(results);
      AppLogger.d('Sansthas loaded: ${sansthas.length}');
    } catch (e, stack) {
      AppLogger.e('Failed to fetch sansthas', e, stack);
    }
  }
}

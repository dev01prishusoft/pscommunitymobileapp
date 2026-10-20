import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../models/advertisement_tracking_event.dart';

abstract class AdvertisementRepository {
  Future<Result<List<Advertisement>>> getByPlacement(
    AdPlacement placement, {
    int? limit,
  });

  Future<Result<Advertisement>> getById(int id);

  Future<Result<PaginatedResponse<Advertisement>>> getList({
    required int page,
    required int pageSize,
  });

  Future<Result<void>> trackEvents(
    List<AdvertisementTrackingEvent> events,
  );
}

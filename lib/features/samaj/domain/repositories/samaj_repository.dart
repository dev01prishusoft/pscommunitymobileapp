import 'package:pscommunitymobileapp/features/samaj/domain/entities/sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';

abstract class SamajRepository {
  Future<Samaj?> getSamajDetail();
  Future<List<Sanstha>> getSansthas();
}

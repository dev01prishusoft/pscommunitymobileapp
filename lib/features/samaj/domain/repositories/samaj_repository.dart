import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';

abstract class SamajRepository {
  Future<Samaj?> getSamajDetail();
}

import 'package:pscommunitymobileapp/features/marriage/domain/entities/marriage_profile.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/unmarried_count.dart';

abstract class MarriageRepository {
  Future<List<MarriageProfile>> getMatrimonialProfiles();
  Future<List<UnmarriedCount>> getUnmarriedCounts();
}

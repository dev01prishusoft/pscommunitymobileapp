import 'package:pscommunitymobileapp/core/models/marriage_profile.dart';
import 'package:pscommunitymobileapp/core/models/unmarried_count.dart';

abstract class MarriageRepository {
  Future<List<MarriageProfile>> getMatrimonialProfiles();
  Future<List<UnmarriedCount>> getUnmarriedCounts();
}

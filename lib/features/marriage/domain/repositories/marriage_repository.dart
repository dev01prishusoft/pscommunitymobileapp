import 'package:pscommunitymobileapp/features/marriage/domain/entities/marriage_profile.dart';

abstract class MarriageRepository {
  Future<List<MarriageProfile>> getMatrimonialProfiles();
}

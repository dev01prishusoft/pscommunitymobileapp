import 'package:pscommunitymobileapp/features/occupation/domain/repositories/occupation_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/occupation/domain/entities/occupation_item.dart';

class OccupationRepositoryImpl implements OccupationRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  OccupationRepositoryImpl(this._apiClient);

  @override
  Future<List<OccupationItem>> getOccupations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const OccupationItem(name: 'Business', count: 450, iconKey: 'business'),
      const OccupationItem(name: 'Software Engineer', count: 320, iconKey: 'computer'),
      const OccupationItem(name: 'Doctor', count: 85, iconKey: 'medical_services'),
      const OccupationItem(name: 'Teacher', count: 180, iconKey: 'school'),
      const OccupationItem(name: 'Agriculture', count: 650, iconKey: 'agriculture'),
      const OccupationItem(name: 'Government Service', count: 120, iconKey: 'account_balance'),
      const OccupationItem(name: 'Real Estate', count: 95, iconKey: 'home_work'),
    ];
  }
}

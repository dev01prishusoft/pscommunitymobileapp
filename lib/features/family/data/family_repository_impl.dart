import 'package:pscommunitymobileapp/features/family/domain/repositories/family_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family_area.dart';
import 'package:pscommunitymobileapp/features/family/domain/entities/family.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  FamilyRepositoryImpl(this._apiClient);

  @override
  Future<List<FamilyArea>> getFamilyAreas() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const FamilyArea(
        title: 'Satellite',
        location: 'Ahmedabad',
        members: 1250,
        families: 450,
      ),
      const FamilyArea(
        title: 'Bopal',
        location: 'Ahmedabad',
        members: 850,
        families: 280,
      ),
      const FamilyArea(
        title: 'Modasa City',
        location: 'Aravalli',
        members: 3200,
        families: 950,
      ),
      const FamilyArea(
        title: 'Mehsana Rural',
        location: 'Mehsana',
        members: 1500,
        families: 520,
      ),
    ];
  }

  @override
  Future<List<Family>> getFamilies(String areaName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const Family(
        familyName: 'Patel Family',
        members: [
          FamilyMember(
            id: 'RP',
            name: 'Rajesh Patel',
            isHead: true,
            gender: 'Male',
            relation: 'Self',
            maritalStatus: 'Married',
            occupation: 'Business',
          ),
          FamilyMember(
            id: 'PP',
            name: 'Priya Patel',
            isHead: false,
            gender: 'Female',
            relation: 'Wife',
            maritalStatus: 'Married',
            occupation: 'Homemaker',
          ),
        ],
      ),
      const Family(
        familyName: 'Mehta Family',
        members: [
          FamilyMember(
            id: 'AM',
            name: 'Amit Mehta',
            isHead: true,
            gender: 'Male',
            relation: 'Self',
            maritalStatus: 'Married',
            occupation: 'Engineer',
          ),
        ],
      ),
    ];
  }
}

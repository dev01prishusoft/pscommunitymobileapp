import 'package:pscommunitymobileapp/features/marriage/domain/repositories/marriage_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/marriage/domain/entities/marriage_profile.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  // ignore: unused_field
  final ApiClient _apiClient;

  MarriageRepositoryImpl(this._apiClient);

  @override
  Future<List<MarriageProfile>> getMatrimonialProfiles() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      const MarriageProfile(
        name: 'Rajesh Patel',
        age: '28 yrs',
        occupation: 'Engineer',
        gotra: 'Kashyap Gotra',
        location: 'Ahmedabad, Daskroi, Satellite',
        lookingForMarriage: true,
        gender: 'Male',
      ),
      const MarriageProfile(
        name: 'Priya Shah',
        age: '25 yrs',
        occupation: 'Teacher',
        gotra: 'Vashishtha Gotra',
        location: 'Vadodara, Karelibaug',
        lookingForMarriage: true,
        gender: 'Female',
      ),
      const MarriageProfile(
        name: 'Amit Mehta',
        age: '30 yrs',
        occupation: 'Business',
        gotra: 'Bharadwaj Gotra',
        location: 'Surat, Adajan',
        lookingForMarriage: true,
        gender: 'Male',
      ),
      const MarriageProfile(
        name: 'Neha Gupta',
        age: '24 yrs',
        occupation: 'Doctor',
        gotra: 'Kashyap Gotra',
        location: 'Rajkot, Kalavad Road',
        lookingForMarriage: true,
        gender: 'Female',
      ),
    ];
  }
}

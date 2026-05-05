import 'package:pscommunitymobileapp/features/member/domain/repositories/member_repository.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class MemberRepositoryImpl implements MemberRepository {
  final ApiClient _apiClient;

  MemberRepositoryImpl(this._apiClient);

  @override
  Future<List<Map<String, String>>> getMembers() async {
    // In production, this would call the API
    // final response = await _apiClient.get(ApiEndpoints.members);
    // For now, we return the mock data but through a repository
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    
    return [
      {
        'name': 'Rajesh Kumar Patel',
        'info': 'Male • Self • Married • Engineer',
        'location': 'Satellite, Daskroi',
      },
      {
        'name': 'Priya Rajesh Patel',
        'info': 'Female • Wife • Married • Teacher',
        'location': 'Satellite, Daskroi',
      },
      {
        'name': 'Amit Mehta',
        'info': 'Male • Self • Married • Business',
        'location': 'Naranpura, Daskroi',
      },
      {
        'name': 'Neha Mehta',
        'info': 'Female • Wife • Married • Doctor',
        'location': 'Naranpura, Daskroi',
      },
    ];
  }
}

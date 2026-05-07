import 'package:runworld/models/challenge_model.dart';
import 'package:runworld/services/api_service.dart';

class ChallengesService {
  ChallengesService._();
  static final instance = ChallengesService._();

  Future<List<ChallengeModel>> getChallenges() async {
    try {
      final res = await ApiService.instance.dio.get('/challenges');
      ApiService.isOffline = false;
      final list = res.data['challenges'] as List<dynamic>;
      return list
          .map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ApiService.handleException(e);
      return [];
    }
  }

  Future<bool> joinChallenge(String id) async {
    try {
      await ApiService.instance.dio.post('/challenges/$id/join');
      return true;
    } catch (e) {
      ApiService.handleException(e);
      return false;
    }
  }

  Future<bool> leaveChallenge(String id) async {
    try {
      await ApiService.instance.dio.delete('/challenges/$id/join');
      return true;
    } catch (e) {
      ApiService.handleException(e);
      return false;
    }
  }
}

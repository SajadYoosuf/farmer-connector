import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/activity_service.dart';

class RegisterFarmerCommand {
  final AuthService _authService = AuthService();
  final ActivityService _activityService = ActivityService();

  Future<String?> execute({
    required String email,
    required String password,
    required String fullName,
    String? farmName,
    String? location,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final registerData = {
        'fullName': fullName,
        'farmName': farmName,
        'location': location,
        ...?extraData,
      };
      final user = await _authService.signUp(email, password, 'farmer', extraData: registerData);
      if (user != null) {
        await _activityService.logSignupActivity(user.uid, fullName, 'farmer');
        return user.uid;
      }
      return null;
    } catch (e) {
      print("RegisterFarmerCommand failed: $e");
      return null;
    }
  }
}

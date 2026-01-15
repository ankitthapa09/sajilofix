import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel?> getUserById(String authId);

  Future<AuthApiModel?> login(String email, String password);

  Future<AuthApiModel> register(AuthApiModel user);
}

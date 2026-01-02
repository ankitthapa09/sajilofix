import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sajilofix/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sajilofix/features/auth/domain/repositories/auth_repository.dart';
import 'package:sajilofix/features/auth/domain/usecases/login_usecase.dart';
import 'package:sajilofix/features/auth/domain/usecases/signup_usecase.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return const AuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authLocalDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  return SignupUseCase(ref.read(authRepositoryProvider));
});

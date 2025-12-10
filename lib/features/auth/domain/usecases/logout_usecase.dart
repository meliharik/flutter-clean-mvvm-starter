import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  FutureEither<void> call() async {
    return _repository.logout();
  }
}

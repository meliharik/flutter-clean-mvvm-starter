import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  FutureEither<User> call() async {
    return _repository.getCurrentUser();
  }
}

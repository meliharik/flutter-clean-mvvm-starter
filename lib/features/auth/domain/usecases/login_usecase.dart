import 'package:flutter_clean_mvvm_starter/core/types/typedefs.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_clean_mvvm_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Login use case
///
/// WHY USE CASES:
/// 1. SINGLE RESPONSIBILITY: Each use case does ONE thing
/// 2. REUSABILITY: Can be called from multiple ViewModels
/// 3. TESTABILITY: Easy to test business logic in isolation
/// 4. DOMAIN LOGIC: Complex validation, business rules go here
///
/// EXAMPLE: If login requires:
/// - Email validation
/// - Password strength check
/// - Analytics tracking
/// - Multiple API calls
/// All that logic lives here, not in ViewModel
///
/// SIMPLE CASES: If use case just calls repository, it might seem redundant.
/// But it provides consistency and room to grow. When business logic is added,
/// you know exactly where it goes.
@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login
  ///
  /// You could add business logic here:
  /// - Validate email format
  /// - Check password requirements
  /// - Track analytics event
  /// - Multi-factor authentication
  FutureEither<User> call({
    required String email,
    required String password,
  }) async {
    // Example: Add email validation here if needed
    // if (!_isValidEmail(email)) {
    //   return Left(ValidationFailure(message: 'Invalid email format'));
    // }

    return _repository.login(email: email, password: password);
  }
}

import 'package:flutter_clean_mvvm_starter/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model - Data layer
///
/// WHY SEPARATE MODEL FROM ENTITY:
/// 1. API structure might change (entity stays stable)
/// 2. API might have extra fields we don't need (id_token, created_at, etc.)
/// 3. API field names might not match our conventions (user_name vs name)
/// 4. Can have multiple models for same entity (GraphQL vs REST)
///
/// FREEZED BENEFITS:
/// 1. @JsonSerializable: Auto JSON parsing
/// 2. Immutability: Can't accidentally modify
/// 3. copyWith: Easy updates
/// 4. Union types: Can represent different response structures
///
/// CONVERSION:
/// Model (API) -> Entity (Domain) -> Presentation
/// This happens in the repository implementation
@freezed
class UserModel with _$UserModel {
  const UserModel._(); // Required for custom methods

  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatar,
  }) = _UserModel;

  /// From JSON - used when parsing API response
  ///
  /// Example API response:
  /// ```json
  /// {
  ///   "id": "123",
  ///   "email": "user@example.com",
  ///   "name": "John Doe",
  ///   "avatar": "https://example.com/avatar.jpg"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert model to entity
  ///
  /// WHY: Repository returns entities, not models
  /// Domain layer should never know about models
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      avatar: avatar,
    );
  }

  /// Create model from entity
  ///
  /// WHY: Sometimes need to convert entity back to model (for caching, etc.)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      avatar: user.avatar,
    );
  }
}

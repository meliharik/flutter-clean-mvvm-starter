import 'package:equatable/equatable.dart';

/// User entity - Domain layer
///
/// WHY ENTITY IN DOMAIN:
/// 1. Business logic representation (what the app cares about)
/// 2. Platform-agnostic (no JSON, no database details)
/// 3. Independent of data sources (API response can change, entity stays same)
/// 4. Pure Dart class (can be used in any Dart project)
///
/// WHY EQUATABLE:
/// - Value equality (two users with same ID are equal)
/// - Easy to compare in tests
/// - Works well with state management (detects changes)
///
/// DOMAIN vs MODEL:
/// - Entity: Domain layer (business logic)
/// - Model: Data layer (API/Database structure)
/// - Models convert to Entities in repositories
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, email, name, avatar];

  @override
  bool get stringify => true; // For better debugging
}

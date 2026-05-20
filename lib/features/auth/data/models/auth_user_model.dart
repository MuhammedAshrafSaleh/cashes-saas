// lib/features/auth/data/models/auth_user_model.dart
import 'package:cashes/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.companyId,
    super.avatarUrl,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: _parseRole(json['role'] as String),
      companyId: json['company_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  static UserRole _parseRole(String raw) {
    switch (raw) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}

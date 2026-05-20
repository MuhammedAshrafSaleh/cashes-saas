// lib/features/auth/domain/entities/auth_user_entity.dart
import 'package:equatable/equatable.dart';
import 'package:cashes/core/constants/user_role.dart';

export 'package:cashes/core/constants/user_role.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.companyId,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? companyId;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, email, fullName, role, companyId, avatarUrl];
}

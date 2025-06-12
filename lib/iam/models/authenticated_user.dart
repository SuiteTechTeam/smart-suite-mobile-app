import 'package:json_annotation/json_annotation.dart';

part 'authenticated_user.g.dart';

@JsonSerializable()
class AuthenticatedUser {
  final int id;
  final String email;
  final String token;
  final int? roleId;
  final String? role;

  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.token,
    this.roleId,
    this.role,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) =>
      _$AuthenticatedUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticatedUserToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authenticated_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticatedUser _$AuthenticatedUserFromJson(Map<String, dynamic> json) =>
    AuthenticatedUser(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      token: json['token'] as String,
      roleId: json['roleId'] == null ? null : (json['roleId'] as num).toInt(),
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AuthenticatedUserToJson(AuthenticatedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'token': instance.token,
      'roleId': instance.roleId,
      'role': instance.role,
    };

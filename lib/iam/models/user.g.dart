// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  surname: json['surname'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  state: json['state'] as String,
  roleId: (json['roleId'] as num).toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'surname': instance.surname,
  'phone': instance.phone,
  'email': instance.email,
  'state': instance.state,
  'roleId': instance.roleId,
};

import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String state;
  final int roleId;

  const User({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.state,
    required this.roleId,
  });

  UserRole get role => UserRole.fromId(roleId);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

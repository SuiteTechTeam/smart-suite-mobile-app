import 'package:equatable/equatable.dart';
import '../models/authenticated_user.dart';
import '../models/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const AuthSignInRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String password;
  final UserRole role;

  const AuthSignUpRequested({
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, surname, phone, email, password, role];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}

class AuthUserLoaded extends AuthEvent {
  final AuthenticatedUser user;

  const AuthUserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

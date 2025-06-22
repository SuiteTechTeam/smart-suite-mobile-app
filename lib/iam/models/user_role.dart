enum UserRole {
  owner(1, 'Owner'),
  admin(2, 'Admin'),
  guest(3, 'Guest');

  const UserRole(this.id, this.name);

  final int id;
  final String name;

  static UserRole fromId(int id) {
    return UserRole.values.firstWhere((role) => role.id == id);
  }
}

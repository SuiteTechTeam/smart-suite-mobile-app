class Admin {
  int id;
  String? username;
  String? name;
  String? surname;
  String? email;
  int? phone;
  String? state;
  String? password;

  Admin({
    required this.id,
    this.username,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.state,
    this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? 0,
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'] != null ? int.tryParse(json['phone'].toString()) : null,
      state: json['state'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'state': state,
      'password': password,
    };
  }
}

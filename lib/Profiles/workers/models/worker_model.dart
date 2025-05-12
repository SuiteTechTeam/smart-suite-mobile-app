class Worker {
  int id;
  String? username;
  String? name;
  String? surname;
  String? email;
  int? phone;
  String? state;
  String? password;

  Worker({
    required this.id,
    this.username,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.state,
    this.password,
  });

  // Método fromJson para crear una instancia de Worker desde un Map (JSON)
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
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

  // Método para convertir una instancia de Worker a JSON
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

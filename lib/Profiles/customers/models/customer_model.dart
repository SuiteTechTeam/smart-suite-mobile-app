class Customer {
  int id;
  String username;
  String name;
  String surname;
  String email;
  int phone;
  String state;

  Customer({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.state,
  });

  // Factory constructor para crear una instancia desde un JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'],
      state: json['state'],
    );
  }

  // Método para convertir una instancia de Customer a JSON pe
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'state': state,
    };
  }
}

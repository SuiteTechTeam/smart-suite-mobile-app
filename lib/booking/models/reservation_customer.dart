class ReservationCustomer {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String? preferences;

  ReservationCustomer({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    this.preferences,
  });

  factory ReservationCustomer.fromJson(Map<String, dynamic> json) {
    return ReservationCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'preferences': preferences,
    };
  }

  String get fullName => '$name $surname';
}

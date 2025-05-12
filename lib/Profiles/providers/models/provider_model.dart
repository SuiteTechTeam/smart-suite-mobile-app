class Provider {
  int? id;
  String? name;
  String? address;
  String? email;
  int? phone;
  String? state;

  Provider({
    this.id,
    this.name,
    this.address,
    this.email,
    this.phone,
    this.state,
  });

  // Constructor para crear una instancia desde un JSON
  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] != null ? int.tryParse(json['phone'].toString()) : null,
      state: json['state'] as String?,
    );
  }

  // Método para convertir una instancia de Provider a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
      'state': state,
    };
  }
}

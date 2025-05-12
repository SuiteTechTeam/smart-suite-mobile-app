class Supply {
  int id; 
  int providersId;
  String name;
  double price;
  int stock;
  String state;

  Supply({
    required this.id,
    required this.providersId,
    required this.name,
    required this.price,
    required this.stock,
    required this.state,
  });

  // Método fromJson para crear un Supply a partir de un JSON
  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: json['id'],
      providersId: json['providersId'],
      name: json['name'],
      price: json['price'].toDouble(), // Asegurar que el precio sea un double
      stock: json['stock'],
      state: json['state'],
    );
  }

  // Método toJson para convertir un Supply a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providersId': providersId,
      'name': name,
      'price': price,
      'stock': stock,
      'state': state,
    };
  }
}

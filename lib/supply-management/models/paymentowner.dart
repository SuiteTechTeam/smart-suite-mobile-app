class PaymentOwner {
  int id; 
  int ownerId;
  String description;
  double finalAmount;

  PaymentOwner({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.finalAmount,
  });

  // Método fromJson para crear un Supply a partir de un JSON
  factory PaymentOwner.fromJson(Map<String, dynamic> json) {
    return PaymentOwner(
      id: json['id'],
      ownerId: json['ownerId'],
      description: json['description'],
      finalAmount: json['finalAmount'], // Asegurar que el precio sea un double
    );
  }

  // Método toJson para convertir un Supply a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'description': description,
      'finalAmount': finalAmount,
    };
  }
}

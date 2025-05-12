class SupplyRequest {
  int id;
  int paymentsOwnersId;
  int suppliesId;
  int count;
  double amount;

  SupplyRequest({
    required this.id,
    required this.paymentsOwnersId,
    required this.suppliesId,
    required this.count,
    required this.amount,
  });

  // Constructor para crear una instancia a partir de un mapa
  factory SupplyRequest.fromMap(Map<String, dynamic> map) {
    return SupplyRequest(
      id: map['id'] ?? 0, // Default en caso de que id no esté presente
      paymentsOwnersId: map['paymentsOwnersId'],
      suppliesId: map['suppliesId'],
      count: map['count'],
      amount: map['amount']?.toDouble() ?? 0.0, // Asegura que amount sea un double
    );
  }

  // Método para convertir una instancia de SupplyRequest a un mapa
  Map<String, dynamic> toMap() {
    return {
      'paymentsOwnersId': paymentsOwnersId, // Cambiado para coincidir con el backend
      'suppliesId': suppliesId,
      'count': count,
      'amount': amount,
    };
  }
}

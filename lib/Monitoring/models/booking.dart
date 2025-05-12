class Booking {
  final int id;
  final int paymentCustomerId;
  final int roomId;
  final String description;
  final DateTime startDate;
  final DateTime finalDate;
  final double priceRoom;
  final int nightCount;
  final double amount;
  final String bookingState;

  Booking({
    required this.id,
    required this.paymentCustomerId,
    required this.roomId,
    required this.description,
    required this.startDate,
    required this.finalDate,
    required this.priceRoom,
    required this.nightCount,
    required this.amount,
    required this.bookingState,
  });
}

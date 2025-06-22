import 'package:flutter/material.dart';
import './widgets/hotel_detail_view.dart';

class HotelDetailScreen extends StatelessWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return HotelDetailView(hotelId: hotelId);
  }
}

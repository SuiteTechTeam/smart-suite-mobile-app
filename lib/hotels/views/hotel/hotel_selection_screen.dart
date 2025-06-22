import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/hotel_service.dart';
import '../../viewmodels/hotel_bloc.dart';
import '../../viewmodels/hotel_event.dart';
import '../../../iam/services/auth_service.dart';
import './widgets/hotel_selection_view.dart';

class HotelSelectionScreen extends StatelessWidget {
  const HotelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HotelBloc(hotelService: HotelService(), authService: AuthService())
            ..add(HotelLoadRequested()),
      child: const HotelSelectionView(),
    );
  }
}

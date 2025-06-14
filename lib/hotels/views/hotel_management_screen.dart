import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/hotel_service.dart';
import '../models/hotel.dart';
import '../viewmodels/hotel_bloc.dart';
import '../viewmodels/hotel_event.dart';
import '../viewmodels/hotel_state.dart' as hotel_state;
import '../../iam/services/auth_service.dart';

class HotelManagementScreen extends StatelessWidget {
  const HotelManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HotelBloc(
        hotelService: HotelService(),
        authService: AuthService(),
      )..add(HotelLoadRequested()),
      child: const HotelManagementView(),
    );
  }
}

class HotelManagementView extends StatelessWidget {
  const HotelManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HotelBloc, hotel_state.HotelState>(
        listener: (context, state) {
          if (state is hotel_state.HotelOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is hotel_state.HotelError) {            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<HotelBloc, hotel_state.HotelState>(
          builder: (context, state) {
            if (state is hotel_state.HotelLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is hotel_state.HotelError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HotelBloc>().add(HotelLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is hotel_state.HotelLoaded) {
              if (state.hotels.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hotel_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hotels found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.hotels.length,
                itemBuilder: (context, index) {
                  final hotel = state.hotels[index];
                  return _buildHotelCard(context, hotel, state.userRole);
                },
              );
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: BlocBuilder<HotelBloc, hotel_state.HotelState>(
        builder: (context, state) {
          if (state is hotel_state.HotelLoaded && state.userRole?.toLowerCase() == 'owner') {
            return FloatingActionButton(
              onPressed: () => _showCreateHotelDialog(context),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel, String? userRole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hotel,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ID: ${hotel.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, hotel.address),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, hotel.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, hotel.email),
            if (hotel.description != null && hotel.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.description, hotel.description!),
            ],
            if (hotel.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${hotel.rating!.toStringAsFixed(1)} / 5.0',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (userRole?.toLowerCase() == 'owner') ...[
                  TextButton.icon(
                    onPressed: () => _showUpdateHotelDialog(context, hotel),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () => _selectHotel(context, hotel.id),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Select'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _selectHotel(BuildContext context, int hotelId) {
    context.read<HotelBloc>().add(HotelSelected(hotelId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hotel selected: ID $hotelId')),
    );
    Navigator.pop(context, true);
  }

  void _showCreateHotelDialog(BuildContext context) {
    _showHotelDialog(context);
  }

  void _showUpdateHotelDialog(BuildContext context, Hotel hotel) {
    _showHotelDialog(context, existingHotel: hotel);
  }

  void _showHotelDialog(BuildContext context, {Hotel? existingHotel}) {
    final nameController = TextEditingController(text: existingHotel?.name ?? '');
    final addressController = TextEditingController(text: existingHotel?.address ?? '');
    final phoneController = TextEditingController(text: existingHotel?.phone ?? '');
    final emailController = TextEditingController(text: existingHotel?.email ?? '');
    final descriptionController = TextEditingController(text: existingHotel?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(existingHotel != null ? 'Update Hotel' : 'Create Hotel'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hotel Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hotel name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop();
                    final hotelData = {
                    'name': nameController.text.trim(),
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'description': descriptionController.text.trim().isEmpty 
                        ? null : descriptionController.text.trim(),
                    'ownerId': existingHotel?.ownerId ?? 2, // Use existing ownerId or default to 2 as per your example
                  };

                  if (existingHotel != null) {
                    context.read<HotelBloc>().add(
                      HotelUpdateRequested(existingHotel.id, hotelData)
                    );
                  } else {
                    context.read<HotelBloc>().add(
                      HotelCreateRequested(hotelData)
                    );
                  }
                }
              },
              child: Text(existingHotel != null ? 'Update' : 'Create'),
            ),
          ],
        );
      },
    );
  }
}

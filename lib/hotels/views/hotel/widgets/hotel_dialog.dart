import 'package:flutter/material.dart';
import '../../../models/hotel.dart';

class HotelDialog extends StatefulWidget {
  final Hotel? existingHotel;
  final void Function(Map<String, dynamic>) onSave;

  const HotelDialog({
    super.key,
    this.existingHotel,
    required this.onSave,
  });

  @override
  State<HotelDialog> createState() => _HotelDialogState();
}

class _HotelDialogState extends State<HotelDialog> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existingHotel != null) {
      nameController.text = widget.existingHotel!.name;
      addressController.text = widget.existingHotel!.address;
      phoneController.text = widget.existingHotel!.phone;
      emailController.text = widget.existingHotel!.email;
      if (widget.existingHotel!.description != null) {
        descriptionController.text = widget.existingHotel!.description!;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final hotelData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      };

      Navigator.of(context).pop();
      widget.onSave(hotelData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingHotel != null;

    return AlertDialog(
      title: Text(isUpdate ? 'Update Hotel' : 'Create Hotel'),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(isUpdate ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

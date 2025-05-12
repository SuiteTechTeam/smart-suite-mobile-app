import 'package:flutter/material.dart';
import 'package:sweetmanager/Profiles/providers/models/provider_model.dart';
import 'package:sweetmanager/Profiles/providers/services/providerservices.dart';

class ProviderAddScreen extends StatefulWidget {
  const ProviderAddScreen({super.key});

  @override
  State<ProviderAddScreen> createState() => _ProviderAddScreenState();
}

class _ProviderAddScreenState extends State<ProviderAddScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  bool isLoading = false;
  late ProviderService _providerService;
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _providerService = ProviderService();
  }

  Future<void> _addProvider() async {
    if (!_formKey.currentState!.validate()) {
      // Si el formulario no es válido, mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Provider newProvider = Provider(
        id: _idController.text.isNotEmpty ? int.tryParse(_idController.text) : null,
        name: _nameController.text,
        address: _addressController.text,
        email: _emailController.text,
        phone: _phoneController.text.isNotEmpty ? int.tryParse(_phoneController.text) : null,
        state: _stateController.text,
      );

      bool success = await _providerService.createProvider(newProvider.toJson());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider added successfully!')),
        );
        Navigator.of(context).pop(true); // Regresa a la pantalla anterior con éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add provider. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add provider: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add Provider',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF474C74),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(_idController, 'ID (optional)', Icons.key, TextInputType.number, false),
                          _buildTextField(_nameController, 'Name', Icons.business, TextInputType.text, true),
                          _buildTextField(_addressController, 'Address', Icons.location_on, TextInputType.text, true),
                          _buildTextField(_emailController, 'Email', Icons.email, TextInputType.emailAddress, true),
                          _buildTextField(_phoneController, 'Phone', Icons.phone, TextInputType.number, true),
                          _buildTextField(_stateController, 'State', Icons.check_circle, TextInputType.text, true),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                onPressed: isLoading ? null : _addProvider,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF474C74),
                                ),
                                child: const Text(
                                  'Add Provider',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      TextInputType inputType,
      bool isRequired,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: inputType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (inputType == TextInputType.emailAddress && value != null && !value.contains('@')) {
            return 'Enter a valid email';
          }
          if (inputType == TextInputType.number && value != null && int.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}

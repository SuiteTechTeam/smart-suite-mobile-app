import 'package:flutter/material.dart';
import '../../iam/services/guest_service.dart';

class GuestSelection extends StatefulWidget {
  final Function(Guest) onGuestSelected;
  final int? selectedGuestId;
  final int? hotelId;

  const GuestSelection({
    super.key,
    required this.onGuestSelected,
    this.selectedGuestId,
    this.hotelId,
  });

  @override
  State<GuestSelection> createState() => _GuestSelectionState();
}

class _GuestSelectionState extends State<GuestSelection> {
  final GuestService _guestService = GuestService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Guest> _allGuests = [];
  List<Guest> _filteredGuests = [];
  Guest? _selectedGuest;
  bool _isLoading = false;
  bool _isCreatingGuest = false;
  bool _showCreateForm = false;
  
  // Form controllers for creating new guest
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGuests();
    _searchController.addListener(_filterGuests);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadGuests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Guest> guests = await _guestService.getAllGuests(
        hotelId: widget.hotelId,
      );
      
      setState(() {
        _allGuests = guests;
        _filteredGuests = guests;
        _isLoading = false;
      });

      // If there's a pre-selected guest ID, find and select it
      if (widget.selectedGuestId != null) {
        _selectedGuest = _allGuests.firstWhere(
          (guest) => guest.id == widget.selectedGuestId,
          orElse: () => _allGuests.first,
        );
        if (_selectedGuest != null) {
          widget.onGuestSelected(_selectedGuest!);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar huéspedes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterGuests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGuests = _allGuests;
      } else {
        _filteredGuests = _allGuests.where((guest) {
          return guest.name.toLowerCase().contains(query) ||
                 guest.surname.toLowerCase().contains(query) ||
                 guest.email.toLowerCase().contains(query) ||
                 guest.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _createNewGuest() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingGuest = true;
    });

    try {
      Guest newGuest = await _guestService.createGuest(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() {
        _allGuests.add(newGuest);
        _filteredGuests = _allGuests;
        _selectedGuest = newGuest;
        _isCreatingGuest = false;
        _showCreateForm = false;
      });

      // Clear form
      _nameController.clear();
      _surnameController.clear();
      _emailController.clear();
      _phoneController.clear();

      widget.onGuestSelected(newGuest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Huésped creado exitosamente: ${newGuest.fullName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingGuest = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear huésped: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          'Seleccionar Huésped',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Search and create buttons
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar huésped...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateForm = !_showCreateForm;
                  if (!_showCreateForm) {
                    // Clear form when hiding
                    _nameController.clear();
                    _surnameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                  }
                });
              },
              icon: Icon(_showCreateForm ? Icons.close : Icons.add),
              label: Text(_showCreateForm ? 'Cancelar' : 'Nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _showCreateForm ? Colors.grey : Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Create new guest form
        if (_showCreateForm) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Nuevo Huésped',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _surnameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido *',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono *',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreatingGuest ? null : _createNewGuest,
                    child: _isCreatingGuest
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Creando...'),
                            ],
                          )
                        : const Text('Crear Huésped'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Selected guest display
        if (_selectedGuest != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedGuest!.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedGuest!.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedGuest = null;
                    });
                    widget.onGuestSelected(Guest(
                      id: 0,
                      name: '',
                      surname: '',
                      email: '',
                      phone: '',
                      state: '',
                    ));
                  },
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Guests list
        if (!_showCreateForm) ...[
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGuests.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron huéspedes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredGuests.length,
                        itemBuilder: (context, index) {
                          final guest = _filteredGuests[index];
                          final isSelected = _selectedGuest?.id == guest.id;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                              child: Text(
                                guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              guest.fullName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(guest.email),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedGuest = guest;
                              });
                              widget.onGuestSelected(guest);
                            },
                          );
                        },
                      ),
          ),
        ],
      ],
    );
  }
} 
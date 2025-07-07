import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../../../models/type_room.dart';
import '../../../services/room_service.dart';
import '../../../services/type_room_service.dart';

class CreateRoomDialog extends StatefulWidget {
  final int hotelId;
  final void Function(Room) onRoomCreated;
  const CreateRoomDialog({
    super.key,
    required this.hotelId,
    required this.onRoomCreated,
  });

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stateController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  List<TypeRoom> _typeRooms = [];
  TypeRoom? _selectedTypeRoom;
  bool _isLoadingTypeRooms = true;

  @override
  void initState() {
    super.initState();
    _fetchTypeRooms();
  }

  Future<void> _fetchTypeRooms() async {
    setState(() {
      _isLoadingTypeRooms = true;
    });
    try {
      final typeRooms = await TypeRoomService().getAllTypeRooms(widget.hotelId);
      setState(() {
        _typeRooms = typeRooms;
        if (_typeRooms.isNotEmpty) {
          _selectedTypeRoom = _typeRooms.first;
        }
        _isLoadingTypeRooms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTypeRooms = false;
      });
    }
  }

  Future<void> _createTypeRoomDialog() async {
    final descController = TextEditingController();
    final priceController = TextEditingController();
    bool creating = false;
    String? error;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Crear Tipo de Habitación'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: creating
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: creating
                      ? null
                      : () async {
                          if (descController.text.isEmpty || priceController.text.isEmpty) {
                            setStateDialog(() {
                              error = 'Todos los campos son requeridos';
                            });
                            return;
                          }
                          
                          double? price = double.tryParse(priceController.text);
                          if (price == null) {
                            setStateDialog(() {
                              error = 'Precio inválido';
                            });
                            return;
                          }
                          
                          setStateDialog(() {
                            creating = true;
                            error = null;
                          });
                          
                          try {
                            final typeRoom = await TypeRoomService().createTypeRoom(
                              hotelId: widget.hotelId,
                              description: descController.text.trim(),
                              price: price,
                            );
                            
                            // Verificar si el diálogo sigue montado antes de usar el contexto
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              if (typeRoom != null) {
                                _fetchTypeRooms();
                              }
                            }
                          } catch (e) {
                            // Verificar si el diálogo sigue montado antes de usar setStateDialog
                            if (context.mounted) {
                              setStateDialog(() {
                                creating = false;
                                error = 'Error al crear tipo de habitación';
                              });
                            }
                          }
                        },
                  child: creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedTypeRoom == null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final room = Room(
        id: 0, // El backend asignará el ID
        typeRoomId: _selectedTypeRoom!.id,
        hotelId: widget.hotelId,
        state: _stateController.text.trim(),
      );
      final createdRoom = await RoomService().createRoom(room);
      widget.onRoomCreated(createdRoom);
    } catch (e) {
      setState(() {
        _errorMessage =
            'Ocurrió un error al crear la habitación. Intenta nuevamente.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nueva habitación'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoadingTypeRooms
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TypeRoom>(
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Habitación',
                            ),
                            value: _selectedTypeRoom,
                            items: _typeRooms.map((TypeRoom typeRoom) {
                              return DropdownMenuItem<TypeRoom>(
                                value: typeRoom,
                                child: Text(
                                  '${typeRoom.description} - \$${typeRoom.price.toStringAsFixed(2)}',
                                ),
                              );
                            }).toList(),
                            onChanged: (TypeRoom? value) {
                              setState(() {
                                _selectedTypeRoom = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _createTypeRoomDialog,
                          tooltip: 'Crear nuevo tipo',
                        ),
                      ],
                    ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'Estado (available/occupied/maintenance)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}

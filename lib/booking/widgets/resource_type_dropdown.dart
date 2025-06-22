import 'package:flutter/material.dart';

class ResourceTypeDropdown extends StatelessWidget {
  final String selectedResourceType;
  final List<String> resourceTypes;
  final ValueChanged<String?> onChanged;

  const ResourceTypeDropdown({
    super.key,
    required this.selectedResourceType,
    required this.resourceTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedResourceType,
        decoration: const InputDecoration(
          labelText: 'Resource Type',
          border: OutlineInputBorder(),
        ),
        items: resourceTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type.replaceAll('_', ' ').toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

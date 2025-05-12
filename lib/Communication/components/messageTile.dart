import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String title;
  final String recipient;
  final String date;
  final bool isSelected;
  final VoidCallback onSelect;

  const MessageTile(this.title, this.recipient, this.date, {super.key, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('sent to $recipient'),
              ],
            ),
            Text(date),
          ],
        ),
      ),
    );
  }
}
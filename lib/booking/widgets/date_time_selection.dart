import 'package:flutter/material.dart';

class DateTimeSelection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;

  const DateTimeSelection({
    super.key,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onSelectDate,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onSelectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelectStartTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startTime == null
                            ? 'Start Time'
                            : '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: onSelectEndTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endTime == null
                            ? 'End Time'
                            : '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

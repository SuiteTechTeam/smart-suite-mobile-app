import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String planName;
  final String price;
  final List<String> features;
  final Color buttonColor;
  final VoidCallback behavior;
  final String textButton;

  const PlanCard({
    super.key,
    required this.color,
    this.borderColor,
    required this.planName,
    required this.price,
    required this.features,
    required this.buttonColor,
    required this.behavior,
    required this.textButton
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$$price / mes',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...features.map(
            (feature) => Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(feature),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: OutlinedButton(
              onPressed: behavior,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                textButton,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
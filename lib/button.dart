import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  final String title;
  final bool isOn;
  final VoidCallback onPressed;

  const ButtonCard({
    Key? key,
    required this.title,
    required this.isOn,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8, // Increased elevation for a more prominent shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(12), // Match the InkWell with card shape
        child: Container(
          padding: const EdgeInsets.all(10), // Adjusted padding
          constraints: BoxConstraints(
            minHeight: 100, // Set a minimum height
            maxWidth: 100, // Optional: set a max width
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 30, // Increased icon size for visibility
                color: isOn
                    ? Colors.yellow[700]
                    : Colors.grey[600], // More vibrant colors
              ),
              // Space between icon and text
              FittedBox(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12, // Adjusted font size
                    fontWeight: FontWeight.w600, // Bolder text
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                  overflow: TextOverflow.ellipsis, // Handle overflow
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(12), // Match container shape with card
            gradient: LinearGradient(
              colors: [
                isOn
                    ? Colors.blueAccent
                    : Colors
                        .grey[800]!, // Use accent color for better visibility
                isOn ? Colors.lightBlueAccent : Colors.black54,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

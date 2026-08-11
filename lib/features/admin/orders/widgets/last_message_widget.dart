import 'package:flutter/material.dart';

class LastMessageWidget extends StatelessWidget {
  final String message;

  final String senderType;

  final String messageType;

  const LastMessageWidget({
    super.key,
    required this.message,
    required this.senderType,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String title;

    //////////////////////////////////////////////////////
    /// SYSTEM MESSAGE
    //////////////////////////////////////////////////////

    if (senderType == "system") {
      icon = Icons.shopping_bag_outlined;
      color = Colors.deepPurple;
      title = "Order";
    }

    //////////////////////////////////////////////////////
    /// CUSTOMER
    //////////////////////////////////////////////////////

    else if (senderType == "customer") {
      icon = Icons.person_outline;
      color = Colors.blue;
      title = "Customer";
    }

    //////////////////////////////////////////////////////
    /// ADMIN
    //////////////////////////////////////////////////////

    else {
      icon = Icons.support_agent;
      color = Colors.green;
      title = "Admin";
    }

    //////////////////////////////////////////////////////
    /// MESSAGE TYPE
    //////////////////////////////////////////////////////

    String preview = message;

    switch (messageType) {
      case "image":
        preview = "📷 Photo";
        break;

      case "pdf":
        preview = "📄 PDF";
        break;

      case "order":
        preview = "🛍 Order Created";
        break;

      case "text":
      default:
        preview = message;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: color,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$title: ",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: preview,
                  style: const TextStyle(
                    color: Color(0xff666666),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
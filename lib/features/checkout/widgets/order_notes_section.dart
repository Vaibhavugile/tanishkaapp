import 'package:flutter/material.dart';

class OrderNotesSection extends StatelessWidget {
  final TextEditingController controller;

  const OrderNotesSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.edit_note_rounded,
                color: primary,
              ),

              SizedBox(width: 10),

              Text(
                "Order Notes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "Add delivery instructions (Optional)",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            maxLength: 250,
            decoration: InputDecoration(
              hintText:
                  "Example:\n• Please call before delivery.\n• Leave at the security gate.\n• Gift wrap this order.",
              filled: true,
              fillColor: const Color(0xffF8F9FB),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder:
                  const OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(18),
                ),
                borderSide: BorderSide(
                  color: primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
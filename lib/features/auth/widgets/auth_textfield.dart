import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffD81B78);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: const Color(0xffFCFBFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isFocused
              ? primary
              : Colors.grey.shade300,
          width: _isFocused ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? primary.withOpacity(.15)
                : Colors.black.withOpacity(.05),
            blurRadius: _isFocused ? 25 : 15,
            spreadRadius: _isFocused ? 1 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        cursorColor: primary,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff2E2E2E),
          letterSpacing: .2,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              widget.icon,
              color: _isFocused
                  ? primary
                  : const Color(0xffB24772),
              size: 24,
            ),
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 60,
          ),

          hintText: widget.hint,

          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const PasswordField({
    super.key,
    required this.controller,
    this.hint = "Password",
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool hidden = true;

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
          color: _isFocused ? primary : Colors.grey.shade300,
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
        obscureText: hidden,
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
              Icons.lock_outline_rounded,
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
          suffixIcon: IconButton(
            splashRadius: 22,
            onPressed: () {
              setState(() {
                hidden = !hidden;
              });
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                key: ValueKey(hidden),
                color: _isFocused
                    ? primary
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
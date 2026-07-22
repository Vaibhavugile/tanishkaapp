import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class PhoneNumberField extends StatefulWidget {
  final TextEditingController controller;
  final Function(Country) onCountryChanged;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.onCountryChanged,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  Country _selectedCountry = Country.parse('IN');

  @override
  void initState() {
    super.initState();

    widget.onCountryChanged(_selectedCountry);

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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                favorite: const [
                  'IN',
                  'US',
                  'AE',
                  'GB',
                  'CA',
                  'AU',
                ],
                onSelect: (country) {
                  setState(() {
                    _selectedCountry = country;
                  });

                  widget.onCountryChanged(country);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "+${_selectedCountry.phoneCode}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: 1,
            height: 32,
            color: Colors.grey.shade300,
          ),

          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              cursorColor: primary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Mobile Number",
                contentPadding: EdgeInsets.symmetric(horizontal: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
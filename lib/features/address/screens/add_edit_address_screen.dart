import 'package:flutter/material.dart';

import '../../../models/address_model.dart';
import '../../../services/address_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState
    extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController =
      TextEditingController(text: "India");

  bool _default = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    if (address != null) {
      _nameController.text = address.fullName;
      _phoneController.text = address.phone;
      _line1Controller.text = address.addressLine1;
      _line2Controller.text = address.addressLine2;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _pincodeController.text = address.pincode;
      _countryController.text = address.country;
      _default = address.isDefault;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    final address = AddressModel(
      id: widget.address?.id ?? "",
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _line1Controller.text.trim(),
      addressLine2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      country: _countryController.text.trim(),
      isDefault: _default,
    );

    if (widget.address == null) {
      await AddressService.instance.addAddress(
        address,
      );
    } else {
      await AddressService.instance.updateAddress(
        address,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.address == null
              ? "Add Address"
              : "Edit Address",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            _field(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person,
            ),

            _field(
              controller: _phoneController,
              label: "Phone",
              icon: Icons.phone,
              keyboard:
                  TextInputType.phone,
            ),

            _field(
              controller: _line1Controller,
              label: "Address Line 1",
              icon: Icons.home,
            ),

            _field(
              controller: _line2Controller,
              label: "Address Line 2",
              icon: Icons.home_outlined,
            ),

            Row(
              children: [

                Expanded(
                  child: _field(
                    controller:
                        _cityController,
                    label: "City",
                    icon: Icons.location_city,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _field(
                    controller:
                        _stateController,
                    label: "State",
                    icon: Icons.map,
                  ),
                ),
              ],
            ),

            Row(
              children: [

                Expanded(
                  child: _field(
                    controller:
                        _pincodeController,
                    label: "Pincode",
                    icon: Icons.pin_drop,
                    keyboard:
                        TextInputType.number,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _field(
                    controller:
                        _countryController,
                    label: "Country",
                    icon: Icons.public,
                  ),
                ),
              ],
            ),

            SwitchListTile(
              value: _default,
              activeColor:
                  const Color(0xffE91E63),
              title: const Text(
                "Set as Default Address",
              ),
              onChanged: (v) {
                setState(() {
                  _default = v;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xffE91E63),
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                onPressed:
                    _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        widget.address == null
                            ? "Save Address"
                            : "Update Address",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard =
        TextInputType.text,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
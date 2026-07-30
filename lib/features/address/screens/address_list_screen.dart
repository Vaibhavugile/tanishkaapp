import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_edit_address_screen.dart';
import '../../../models/address_model.dart';
import '../../../services/address_service.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({
    super.key,
    this.selectMode = false,
  });

  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          selectMode
              ? "Select Address"
              : "My Addresses",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xffE91E63),
        foregroundColor: Colors.white,
       onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const AddEditAddressScreen(),
    ),
  );
},
        icon: const Icon(Icons.add),
        label: const Text("Add Address"),
      ),

      body: StreamBuilder<List<AddressModel>>(
        stream: AddressService.instance.addressStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final addresses = snapshot.data!;

          if (addresses.isEmpty) {
            return const Center(
              child: Text(
                "No Address Added",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];

              return _AddressCard(
                address: address,
                selectMode: selectMode,
              );
            },
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool selectMode;

  const _AddressCard({
    required this.address,
    required this.selectMode,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  address.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),

              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(.1),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Default",
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(address.phone),

          const SizedBox(height: 10),

          Text(
            address.fullAddress,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AddressService.instance
                        .setDefaultAddress(
                      address.id,
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Set Default"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor:
                        Colors.white,
                  ),
                 onPressed: () async {
  if (selectMode) {
    Navigator.pop(
      context,
      address,
    );
  } else {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAddressScreen(
          address: address,
        ),
      ),
    );
  }
},
                  icon: Icon(
                    selectMode
                        ? Icons.check_circle
                        : Icons.edit,
                  ),
                  label: Text(
                    selectMode
                        ? "Select"
                        : "Edit",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
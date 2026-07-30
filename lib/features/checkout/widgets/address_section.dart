import 'package:flutter/material.dart';

class AddressSection extends StatelessWidget {
  final bool hasAddress;

  final String name;
  final String phone;
  final String address;

  final VoidCallback onChange;
  final VoidCallback onAdd;

  const AddressSection({
    super.key,
    required this.hasAddress,
    required this.name,
    required this.phone,
    required this.address,
    required this.onChange,
    required this.onAdd,
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
      child: hasAddress
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(.1),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Text(
                        "Delivery Address",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            primary.withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        "Default",
                        style: TextStyle(
                          color: primary,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color:
                          Colors.grey.shade600,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "+91 $phone",
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color:
                          Colors.grey.shade500,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          primary,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size(
                        double.infinity,
                        52,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    onPressed: onChange,
                    icon: const Icon(
                      Icons.edit_location_alt,
                    ),
                    label: const Text(
                      "Change Address",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const Icon(
                  Icons.location_off,
                  size: 60,
                  color: primary,
                ),

                const SizedBox(height: 16),

                const Text(
                  "No Address Selected",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Add a delivery address to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primary,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size(
                        double.infinity,
                        52,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Add New Address",
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
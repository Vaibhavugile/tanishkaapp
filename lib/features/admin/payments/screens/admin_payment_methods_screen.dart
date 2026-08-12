import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/payment_method_model.dart';
import '../../../../services/payment_method_service.dart';

class AdminPaymentMethodsScreen extends StatefulWidget {
  const AdminPaymentMethodsScreen({
    super.key,
  });

  @override
  State<AdminPaymentMethodsScreen> createState() =>
      _AdminPaymentMethodsScreenState();
}

class _AdminPaymentMethodsScreenState
    extends State<AdminPaymentMethodsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final ImagePicker _picker =
      ImagePicker();

  bool _uploading = false;

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xff241B2F),
        title: const Text(
          "Payment Methods",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xffE91E63),
        foregroundColor: Colors.white,
        elevation: 8,

        onPressed: _uploading
            ? null
            : () {
                _showAddPaymentMethod();
              },

        icon: const Icon(
          Icons.add_rounded,
        ),

        label: const Text(
          "Add Scanner",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<
          List<PaymentMethodModel>>(
        stream:
            PaymentMethodService.instance
                .allPaymentMethodsStream(),

        builder: (
          context,
          snapshot,
        ) {
          //////////////////////////////////////////////////
          /// LOADING
          //////////////////////////////////////////////////

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xffE91E63),
              ),
            );
          }

          //////////////////////////////////////////////////
          /// ERROR
          //////////////////////////////////////////////////

          if (snapshot.hasError) {
            return _buildError(
              snapshot.error.toString(),
            );
          }

          final methods =
              snapshot.data ?? [];

          //////////////////////////////////////////////////
          /// EMPTY
          //////////////////////////////////////////////////

          if (methods.isEmpty) {
            return _buildEmpty();
          }

          //////////////////////////////////////////////////
          /// LIST
          //////////////////////////////////////////////////

          return ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              110,
            ),

            physics:
                const BouncingScrollPhysics(),

            itemCount:
                methods.length,

            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              height: 14,
            ),

            itemBuilder: (
              context,
              index,
            ) {
              return _buildPaymentMethodCard(
                methods[index],
              );
            },
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PAYMENT METHOD CARD
  ///////////////////////////////////////////////////////////

  Widget _buildPaymentMethodCard(
    PaymentMethodModel method,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              const Color(0xffEFE5EA),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.045),
            blurRadius: 20,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(14),

        child: Row(
          children: [

            //////////////////////////////////////////////////
            /// QR PREVIEW
            //////////////////////////////////////////////////

            GestureDetector(
              onTap: () {
                if (method.image.isNotEmpty) {
                  _showPreview(
                    method.image,
                    method.name,
                  );
                }
              },

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(18),

                child: Container(
                  width: 92,
                  height: 92,

                  color:
                      const Color(0xffF8F3F6),

                  child:
                      method.image.isEmpty
                          ? const Icon(
                              Icons
                                  .qr_code_2_outlined,
                              color:
                                  Color(
                                0xffE91E63,
                              ),
                              size: 40,
                            )
                          : Image.network(
                              method.image,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .broken_image_outlined,
                                  color:
                                      Colors.grey,
                                );
                              },
                            ),
                ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            //////////////////////////////////////////////////
            /// DETAILS
            //////////////////////////////////////////////////

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    method.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          Color(0xff241B2F),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    method.type
                        .toUpperCase(),

                    style:
                        const TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: .7,
                      color:
                          Color(0xff8A7B87),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration:
                        BoxDecoration(
                      color: method.isActive
                          ? Colors.green
                              .withOpacity(.10)
                          : Colors.grey
                              .withOpacity(.10),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      method.isActive
                          ? "ACTIVE"
                          : "DISABLED",

                      style:
                          TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w900,
                        color: method.isActive
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////
            /// MENU
            //////////////////////////////////////////////////

            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color:
                    Color(0xff6F6270),
              ),

              onSelected:
                  (value) {
                switch (value) {
                  case "edit":
                    _showEditPaymentMethod(
                      method,
                    );
                    break;

                  case "toggle":
                    _togglePaymentMethod(
                      method,
                    );
                    break;

                  case "delete":
                    _deletePaymentMethod(
                      method,
                    );
                    break;
                }
              },

              itemBuilder:
                  (_) => [
                const PopupMenuItem(
                  value: "edit",
                  child: Text(
                    "Edit",
                  ),
                ),

                PopupMenuItem(
                  value: "toggle",
                  child: Text(
                    method.isActive
                        ? "Disable"
                        : "Enable",
                  ),
                ),

                const PopupMenuItem(
                  value: "delete",
                  child: Text(
                    "Delete",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ADD
  ///////////////////////////////////////////////////////////

  Future<void>
      _showAddPaymentMethod() async {
    final nameController =
        TextEditingController();

    final orderController =
        TextEditingController(
      text: "1",
    );

    String type = "upi";

    XFile? selectedImage;

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (
        context,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              padding:
                  EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        20,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    //////////////////////////////////////////////////
                    /// TITLE
                    //////////////////////////////////////////////////

                    const Text(
                      "Add Payment Scanner",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            Color(0xff241B2F),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "Add a QR scanner that admins can use while collecting payment.",
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //////////////////////////////////////////////////
                    /// IMAGE
                    //////////////////////////////////////////////////

                    GestureDetector(
                      onTap: () async {
                        final image =
                            await _picker.pickImage(
                          source:
                              ImageSource.gallery,
                          imageQuality: 90,
                        );

                        if (image != null) {
                          setSheetState(() {
                            selectedImage =
                                image;
                          });
                        }
                      },

                      child: Container(
                        width:
                            double.infinity,
                        height: 190,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xffF8F3F6,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xffEFE0E7,
                            ),
                          ),
                        ),

                        child:
                            selectedImage ==
                                    null
                                ? const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .cloud_upload_outlined,
                                        color:
                                            Color(
                                          0xffE91E63,
                                        ),
                                        size: 42,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Upload QR Scanner",
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                          color:
                                              Color(
                                            0xff241B2F,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Tap to select image",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey,
                                          fontSize:
                                              11,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      22,
                                    ),
                                    child:
                                        Image.file(
                                      File(
                                        selectedImage!
                                            .path,
                                      ),
                                      fit:
                                          BoxFit.contain,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    //////////////////////////////////////////////////
                    /// NAME
                    //////////////////////////////////////////////////

                    TextField(
                      controller:
                          nameController,

                      decoration:
                          _inputDecoration(
                        "Scanner name",
                        Icons
                            .drive_file_rename_outline,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    //////////////////////////////////////////////////
                    /// TYPE
                    //////////////////////////////////////////////////

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          type,

                      decoration:
                          _inputDecoration(
                        "Payment type",
                        Icons
                            .payments_outlined,
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "upi",
                          child:
                              Text("UPI"),
                        ),
                        DropdownMenuItem(
                          value: "qr",
                          child:
                              Text("QR"),
                        ),
                        DropdownMenuItem(
                          value: "bank",
                          child:
                              Text("Bank"),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            type = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    //////////////////////////////////////////////////
                    /// SORT ORDER
                    //////////////////////////////////////////////////

                    TextField(
                      controller:
                          orderController,

                      keyboardType:
                          TextInputType.number,

                      decoration:
                          _inputDecoration(
                        "Display order",
                        Icons
                            .sort_rounded,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //////////////////////////////////////////////////
                    /// SAVE
                    //////////////////////////////////////////////////

                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,

                      child:
                          ElevatedButton(
                        onPressed:
                            _uploading
                                ? null
                                : () async {
                                    final name =
                                        nameController
                                            .text
                                            .trim();

                                    if (name
                                        .isEmpty) {
                                      _showError(
                                        "Enter scanner name.",
                                      );
                                      return;
                                    }

                                    if (selectedImage ==
                                        null) {
                                      _showError(
                                        "Select a QR image.",
                                      );
                                      return;
                                    }

                                    final sortOrder =
                                        int.tryParse(
                                              orderController
                                                  .text,
                                            ) ??
                                            1;

                                    Navigator.pop(
                                      context,
                                    );

                                    await _createPaymentMethod(
                                      name:
                                          name,
                                      type:
                                          type,
                                      sortOrder:
                                          sortOrder,
                                      image:
                                          selectedImage!,
                                    );
                                  },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xffE91E63,
                          ),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              17,
                            ),
                          ),
                        ),

                        child:
                            const Text(
                          "Save Scanner",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    orderController.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// CREATE
  ///////////////////////////////////////////////////////////

  Future<void>
      _createPaymentMethod({
    required String name,
    required String type,
    required int sortOrder,
    required XFile image,
  }) async {
    setState(() {
      _uploading = true;
    });

    try {
      final doc =
          _firestore
              .collection(
                "paymentMethods",
              )
              .doc();

      final storageRef =
          _storage
              .ref()
              .child(
                "paymentMethods/${doc.id}.jpg",
              );

      await storageRef.putFile(
        File(image.path),
      );

      final imageUrl =
          await storageRef
              .getDownloadURL();

      await doc.set({
        "name": name,
        "type": type,
        "image": imageUrl,
        "isActive": true,
        "sortOrder": sortOrder,
        "createdAt":
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showSuccess(
        "Payment scanner added.",
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        "Unable to upload scanner.",
      );

      debugPrint(
        "Payment scanner error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  ///////////////////////////////////////////////////////////
  /// EDIT
  ///////////////////////////////////////////////////////////

  Future<void>
      _showEditPaymentMethod(
    PaymentMethodModel method,
  ) async {
    final nameController =
        TextEditingController(
      text: method.name,
    );

    final orderController =
        TextEditingController(
      text: method.sortOrder.toString(),
    );

    String type = method.type;

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (
        context,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              padding:
                  EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        20,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Edit Payment Method",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          Color(0xff241B2F),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  TextField(
                    controller:
                        nameController,

                    decoration:
                        _inputDecoration(
                      "Scanner name",
                      Icons
                          .drive_file_rename_outline,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue: type,

                    decoration:
                        _inputDecoration(
                      "Payment type",
                      Icons
                          .payments_outlined,
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "upi",
                        child:
                            Text("UPI"),
                      ),
                      DropdownMenuItem(
                        value: "qr",
                        child:
                            Text("QR"),
                      ),
                      DropdownMenuItem(
                        value: "bank",
                        child:
                            Text("Bank"),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() {
                          type = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        orderController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        _inputDecoration(
                      "Display order",
                      Icons
                          .sort_rounded,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,

                    child:
                        ElevatedButton(
                      onPressed: () async {
                        final name =
                            nameController
                                .text
                                .trim();

                        final sortOrder =
                            int.tryParse(
                                  orderController
                                      .text,
                                ) ??
                                method.sortOrder;

                        if (name.isEmpty) {
                          return;
                        }

                        await _firestore
                            .collection(
                              "paymentMethods",
                            )
                            .doc(method.id)
                            .update({
                          "name": name,
                          "type": type,
                          "sortOrder":
                              sortOrder,
                        });

                        if (context
                            .mounted) {
                          Navigator.pop(
                            context,
                          );
                        }

                        if (mounted) {
                          _showSuccess(
                            "Payment method updated.",
                          );
                        }
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xffE91E63,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),

                      child:
                          const Text(
                        "Save Changes",
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    orderController.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// TOGGLE
  ///////////////////////////////////////////////////////////

  Future<void>
      _togglePaymentMethod(
    PaymentMethodModel method,
  ) async {
    await _firestore
        .collection("paymentMethods")
        .doc(method.id)
        .update({
      "isActive": !method.isActive,
    });

    if (!mounted) return;

    _showSuccess(
      method.isActive
          ? "Scanner disabled."
          : "Scanner enabled.",
    );
  }

  ///////////////////////////////////////////////////////////
  /// DELETE
  ///////////////////////////////////////////////////////////

  Future<void>
      _deletePaymentMethod(
    PaymentMethodModel method,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: const Text(
            "Delete Scanner?",
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          content: Text(
            "Delete ${method.name}? This cannot be undone.",
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                "Delete",
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      if (method.image.isNotEmpty) {
        try {
          await _storage
              .refFromURL(
            method.image,
          )
              .delete();
        } catch (_) {
          // Storage image may already be gone.
        }
      }

      await _firestore
          .collection(
            "paymentMethods",
          )
          .doc(method.id)
          .delete();

      if (!mounted) return;

      _showSuccess(
        "Scanner deleted.",
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        "Unable to delete scanner.",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// PREVIEW
  ///////////////////////////////////////////////////////////

  void _showPreview(
    String image,
    String name,
  ) {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(.82),
      builder: (_) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          insetPadding:
              const EdgeInsets.all(18),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              Align(
                alignment:
                    Alignment.centerRight,

                child:
                    IconButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                  ),
                  icon:
                      const Icon(
                    Icons.close_rounded,
                    color:
                        Colors.white,
                  ),
                ),
              ),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),

                child: Container(
                  color: Colors.white,

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  child:
                      InteractiveViewer(
                    child:
                        Image.network(
                      image,
                      fit:
                          BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                name,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// INPUT
  ///////////////////////////////////////////////////////////

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,

      prefixIcon:
          Icon(
        icon,
        size: 20,
        color:
            const Color(0xff8A7B87),
      ),

      filled: true,

      fillColor:
          const Color(0xffF8F5F7),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide.none,
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              Color(0xffE91E63),
          width: 1.2,
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// EMPTY
  ///////////////////////////////////////////////////////////

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Container(
              width: 82,
              height: 82,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffFCE4EC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  26,
                ),
              ),

              child: const Icon(
                Icons
                    .qr_code_2_rounded,
                color:
                    Color(0xffE91E63),
                size: 40,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              "No Payment Scanners",
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xff241B2F),
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              "Add your first QR scanner to start receiving payments.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  Widget _buildError(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            const Icon(
              Icons
                  .error_outline_rounded,
              color: Colors.redAccent,
              size: 42,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              "Unable to load payment methods.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              error,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUCCESS
  ///////////////////////////////////////////////////////////

  void _showSuccess(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(16),

        backgroundColor:
            const Color(0xff2E7D32),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),

        content: Row(
          children: [

            const Icon(
              Icons
                  .check_circle_rounded,
              color: Colors.white,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR SNACKBAR
  ///////////////////////////////////////////////////////////

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(16),

        backgroundColor:
            const Color(0xffC62828),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),

        content: Row(
          children: [

            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
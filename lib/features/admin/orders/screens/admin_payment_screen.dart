import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/admin_chat_service.dart';
import 'package:tanishka/models/payment_method_model.dart';
import 'package:tanishka/services/payment_method_service.dart';

class AdminPaymentScreen extends StatefulWidget {
  final String orderId;

  const AdminPaymentScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminPaymentScreen> createState() =>
      _AdminPaymentScreenState();
}

class _AdminPaymentScreenState
    extends State<AdminPaymentScreen> {
  PaymentMethodModel? _selectedMethod;
bool _sendingPaymentRequest = false;
  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////
Future<void> _confirmPayment({
  required double amount,
  required PaymentMethodModel paymentMethod,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Confirm Payment",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          "Confirm that ₹${amount.toStringAsFixed(2)} "
          "has been received successfully?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xffE91E63),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Confirm",
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
    await AdminChatService.instance
        .markPaymentSuccessful(
      orderId: widget.orderId,
      amount: amount,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Payment marked as successful",
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Unable to verify payment: $e",
        ),
      ),
    );
  }
}
///////////////////////////////////////////////////////////
/// SEND PAYMENT REQUEST TO CUSTOMER
///////////////////////////////////////////////////////////

Future<void> _sendPaymentRequest({
  required double amount,
  required PaymentMethodModel paymentMethod,
}) async {
  if (_sendingPaymentRequest) {
    return;
  }

  setState(() {
    _sendingPaymentRequest = true;
  });

  try {
    await AdminChatService.instance
        .sendPaymentRequest(
      orderId: widget.orderId,
      amount: amount,
      paymentMethodId: paymentMethod.id,
      paymentMethodName: paymentMethod.name,
      qrImage: paymentMethod.image,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Payment request sent to customer",
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Unable to send payment request: $e",
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (!mounted) return;

    setState(() {
      _sendingPaymentRequest = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff241B2F),
        centerTitle: false,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.orderId)
            .snapshots(),

        builder: (
          context,
          orderSnapshot,
        ) {
          /////////////////////////////////////////////////////
          /// ORDER LOADING
          /////////////////////////////////////////////////////

          if (orderSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xffE91E63),
              ),
            );
          }

          /////////////////////////////////////////////////////
          /// ORDER ERROR
          /////////////////////////////////////////////////////

          if (orderSnapshot.hasError) {
            return _buildError(
              "Unable to load order.",
            );
          }

          /////////////////////////////////////////////////////
          /// ORDER NOT FOUND
          /////////////////////////////////////////////////////

          if (!orderSnapshot.hasData ||
              !orderSnapshot.data!.exists) {
            return _buildError(
              "Order not found.",
            );
          }

          final orderData =
              orderSnapshot.data!.data() ?? {};

          /////////////////////////////////////////////////////
          /// AMOUNT
          /////////////////////////////////////////////////////

          final totalAmount =
              _toDouble(
            orderData["totalAmount"],
          );

          final paymentStatus =
              (orderData["paymentStatus"] ??
                      "Pending")
                  .toString();

          /////////////////////////////////////////////////////
          /// PAYMENT METHODS
          /////////////////////////////////////////////////////

          return StreamBuilder<
              List<PaymentMethodModel>>(
            stream:
                PaymentMethodService.instance
                    .activePaymentMethodsStream(),

            builder: (
              context,
              paymentSnapshot,
            ) {
              //////////////////////////////////////////////////
              /// PAYMENT METHODS LOADING
              //////////////////////////////////////////////////

              if (paymentSnapshot.connectionState ==
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
              /// PAYMENT METHODS ERROR
              //////////////////////////////////////////////////

              if (paymentSnapshot.hasError) {
                return _buildError(
                  "Unable to load payment methods.",
                );
              }

              final methods =
                  paymentSnapshot.data ?? [];

              //////////////////////////////////////////////////
              /// NO METHODS
              //////////////////////////////////////////////////

              if (methods.isEmpty) {
                return _buildNoPaymentMethods();
              }

              //////////////////////////////////////////////////
              /// DEFAULT METHOD
              //////////////////////////////////////////////////

              if (_selectedMethod == null) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (!mounted) return;

                  setState(() {
                    _selectedMethod =
                        methods.first;
                  });
                });
              }

              //////////////////////////////////////////////////
              /// MAIN UI
              //////////////////////////////////////////////////

              return SafeArea(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    32,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      //////////////////////////////////////////////////
                      /// PAYMENT STATUS
                      //////////////////////////////////////////////////

                      _buildStatusCard(
                        paymentStatus,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      //////////////////////////////////////////////////
                      /// AMOUNT
                      //////////////////////////////////////////////////

                      _buildAmountCard(
                        totalAmount,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      //////////////////////////////////////////////////
                      /// PAYMENT METHODS
                      //////////////////////////////////////////////////

                      const Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 18,
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
                        "Select a scanner to receive the payment.",
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildPaymentMethods(
                        methods,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      //////////////////////////////////////////////////
                      /// SELECTED QR
                      //////////////////////////////////////////////////

                      if (_selectedMethod != null)
                        _buildSelectedScanner(
                          _selectedMethod!,
                        ),

                      const SizedBox(
                        height: 24,
                      ),

                      //////////////////////////////////////////////////
                      /// SUCCESS BUTTON
                      //////////////////////////////////////////////////

             ///////////////////////////////////////////////////////////
/// SEND PAYMENT REQUEST
///////////////////////////////////////////////////////////

if (_selectedMethod != null)
  _buildSendPaymentButton(
    totalAmount,
    _selectedMethod!,
  ),

const SizedBox(height: 12),

///////////////////////////////////////////////////////////
/// MARK SUCCESSFUL
///////////////////////////////////////////////////////////

_buildSuccessButton(
  paymentStatus,
  totalAmount,
),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// STATUS CARD
  ///////////////////////////////////////////////////////////

  Widget _buildStatusCard(
    String status,
  ) {
    final paid =
        status.toLowerCase() == "paid" ||
        status.toLowerCase() == "successful";

    final color =
        paid ? Colors.green : Colors.orange;

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(
            0xffEFE5EA,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              paid
                  ? Icons
                      .check_circle_outline
                  : Icons
                      .schedule_outlined,
              color: color,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Status",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// AMOUNT CARD
  ///////////////////////////////////////////////////////////

  Widget _buildAmountCard(
    double amount,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff241B2F),
            Color(0xff3B2947),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.10),
            blurRadius: 20,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Amount to Collect",
            style: TextStyle(
              color: Colors.white
                  .withOpacity(.65),
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "Order #${widget.orderId}",
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white
                  .withOpacity(.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PAYMENT METHOD LIST
  ///////////////////////////////////////////////////////////

  Widget _buildPaymentMethods(
    List<PaymentMethodModel> methods,
  ) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,

        physics:
            const BouncingScrollPhysics(),

        itemCount:
            methods.length,

        separatorBuilder: (_, __) =>
            const SizedBox(
          width: 10,
        ),

        itemBuilder: (
          context,
          index,
        ) {
          final method =
              methods[index];

          final selected =
              _selectedMethod?.id ==
                  method.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod =
                    method;
              });
            },

            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 220,
              ),

              width: 145,

              padding:
                  const EdgeInsets.all(
                12,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? const Color(
                        0xffFCE4EC,
                      )
                    : Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                border: Border.all(
                  color: selected
                      ? const Color(
                          0xffE91E63,
                        )
                      : const Color(
                          0xffEEE6EA,
                        ),
                  width:
                      selected ? 1.5 : 1,
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(
                      color:
                          selected
                              ? const Color(
                                  0xffE91E63,
                                ).withOpacity(
                                  .12,
                                )
                              : const Color(
                                  0xffF7F3F5,
                                ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      method.isBank
                          ? Icons
                              .account_balance_outlined
                          : Icons
                              .qr_code_2_outlined,
                      color: selected
                          ? const Color(
                              0xffE91E63,
                            )
                          : const Color(
                              0xff6F6270,
                            ),
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 9,
                  ),

                  Expanded(
                    child: Text(
                      method.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                        color: selected
                            ? const Color(
                                0xffE91E63,
                              )
                            : const Color(
                                0xff241B2F,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SELECTED SCANNER
  ///////////////////////////////////////////////////////////

  Widget _buildSelectedScanner(
    PaymentMethodModel method,
  ) {
    if (method.image.trim().isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: const Color(
              0xffEEE6EA,
            ),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons
                  .image_not_supported_outlined,
              size: 42,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "No scanner image available",
              style: TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: const Color(
            0xffEEE6EA,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.04),
            blurRadius: 18,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  method.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        Color(0xff241B2F),
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffE91E63,
                  ).withOpacity(.08),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(
                    color:
                        Color(0xffE91E63),
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          GestureDetector(
            onTap: () {
              _showScannerPreview(
                method,
              );
            },

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  method.image,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                    context,
                    child,
                    progress,
                  ) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            Color(0xffE91E63),
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons
                            .broken_image_outlined,
                        size: 42,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            "Tap the scanner to view it larger",
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUCCESS BUTTON
  ///////////////////////////////////////////////////////////

  Widget _buildSuccessButton(
  String paymentStatus,
  double amount,
) {
    final paid =
        paymentStatus.toLowerCase() ==
                "paid" ||
            paymentStatus.toLowerCase() ==
                "successful";

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
       onPressed: paid
    ? null
    : () {
        if (_selectedMethod == null) {
          return;
        }

        _confirmPayment(
          amount: amount,
          paymentMethod: _selectedMethod!,
        );
      },

        icon: Icon(
          paid
              ? Icons.check_circle_outline
              : Icons.verified_outlined,
        ),

        label: Text(
          paid
              ? "Payment Successful"
              : "Mark Payment Successful",
          style: const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xffE91E63),
          foregroundColor:
              Colors.white,
          disabledBackgroundColor:
              Colors.green
                  .withOpacity(.15),
          disabledForegroundColor:
              Colors.green,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// FULL SCREEN SCANNER
  ///////////////////////////////////////////////////////////

  void _showScannerPreview(
    PaymentMethodModel method,
  ) {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(.85),
      builder: (_) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.all(20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Align(
                alignment:
                    Alignment.centerRight,
                child: IconButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  child: Image.network(
                    method.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                method.name,
                style: const TextStyle(
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
/// SEND PAYMENT BUTTON
///////////////////////////////////////////////////////////

Widget _buildSendPaymentButton(
  double amount,
  PaymentMethodModel method,
) {
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton.icon(
      onPressed:
          _sendingPaymentRequest
              ? null
              : () {
                  _sendPaymentRequest(
                    amount: amount,
                    paymentMethod: method,
                  );
                },

      icon: _sendingPaymentRequest
          ? const SizedBox(
              width: 20,
              height: 20,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                  Colors.white,
                ),
              ),
            )
          : const Icon(
              Icons.send_rounded,
            ),

      label: Text(
        _sendingPaymentRequest
            ? "Sending..."
            : "Send Payment Request",
        style: const TextStyle(
          fontWeight:
              FontWeight.w800,
          fontSize: 15,
        ),
      ),

      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xff241B2F),

        foregroundColor:
            Colors.white,

        disabledBackgroundColor:
            const Color(0xffB8ADB5),

        elevation: 0,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
      ),
    ),
  );
}
  ///////////////////////////////////////////////////////////
  /// EMPTY PAYMENT METHODS
  ///////////////////////////////////////////////////////////

  Widget _buildNoPaymentMethods() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xffFCE4EC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: const Icon(
                Icons
                    .qr_code_2_outlined,
                color:
                    Color(0xffE91E63),
                size: 34,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              "No Payment Methods",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xff241B2F),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "No active payment scanners are available.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
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
    String message,
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

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xff241B2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// NUMBER HELPER
  ///////////////////////////////////////////////////////////

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/admin_order_service.dart';
import '../widgets/order_card.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Color(0xff241B2F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream:
            AdminOrderService.instance
                .latestOrderChats(),
        builder: (context, snapshot) {
          //////////////////////////////////////
          /// LOADING
          //////////////////////////////////////

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          //////////////////////////////////////
          /// ERROR
          //////////////////////////////////////

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          //////////////////////////////////////
          /// EMPTY
          //////////////////////////////////////

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No Orders Found",
              ),
            );
          }

          //////////////////////////////////////
          /// LIST
          //////////////////////////////////////

          return ListView.separated(
            padding:
                const EdgeInsets.all(16),

            itemCount: docs.length,

            separatorBuilder:
                (_, __) =>
                    const SizedBox(
                      height: 14,
                    ),

            itemBuilder: (_, index) {
              return OrderCard(
                order: docs[index],

                onTap: () {
                  // Next Step
                },
              );
            },
          );
        },
      ),
    );
  }
}
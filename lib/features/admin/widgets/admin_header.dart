import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';
import 'dashboard_card.dart';
import '../../../models/admin_role.dart';
class AdminHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  final VoidCallback? onProfileTap;

  const AdminHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final admin = AdminService.instance.currentAdmin;

    return DashboardCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          //////////////////////////////////////////////////////
          /// PROFILE
          //////////////////////////////////////////////////////

          GestureDetector(
            onTap: onProfileTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      const Color(0xffF8E7EF),
                  backgroundImage:
                      admin != null &&
                              admin.photo.isNotEmpty
                          ? NetworkImage(
                              admin.photo,
                            )
                          : null,
                  child:
                      admin == null ||
                              admin.photo.isEmpty
                          ? const Icon(
                              Icons.person,
                              color:
                                  Color(0xffE91E63),
                              size: 34,
                            )
                          : null,
                ),

                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          //////////////////////////////////////////////////////
          /// NAME
          //////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  admin?.fullName ?? "",
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff241B2F),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xffE91E63,
                    ).withOpacity(.10),
                    borderRadius:
                        BorderRadius.circular(50),
                  ),
                 child: Text(
  admin?.role.displayName ?? "",
  style: const TextStyle(
    color: Color(0xffE91E63),
    fontWeight: FontWeight.bold,
  ),
),
                ),
              ],
            ),
          ),

          //////////////////////////////////////////////////////
          /// NOTIFICATION
          //////////////////////////////////////////////////////

          InkWell(
            borderRadius:
                BorderRadius.circular(100),
            onTap: onNotificationTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(
                  0xffF9F3F6,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xffE91E63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
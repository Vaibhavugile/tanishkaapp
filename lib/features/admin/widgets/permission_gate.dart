import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';

class PermissionGate extends StatelessWidget {
  final bool Function(AdminService admin) allow;

  final Widget child;

  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.allow,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final admin = AdminService.instance;

    if (allow(admin)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
enum AdminRole {
  superAdmin,
  owner,
  manager,
  sales,
  packing,
  accounts,
  support,
}

extension AdminRoleExtension on AdminRole {
  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return "superAdmin";

      case AdminRole.owner:
        return "owner";

      case AdminRole.manager:
        return "manager";

      case AdminRole.sales:
        return "sales";

      case AdminRole.packing:
        return "packing";

      case AdminRole.accounts:
        return "accounts";

      case AdminRole.support:
        return "support";
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return "Super Admin";

      case AdminRole.owner:
        return "Owner";

      case AdminRole.manager:
        return "Manager";

      case AdminRole.sales:
        return "Sales";

      case AdminRole.packing:
        return "Packing";

      case AdminRole.accounts:
        return "Accounts";

      case AdminRole.support:
        return "Support";
    }
  }

  static AdminRole fromString(String role) {
    return AdminRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => AdminRole.support,
    );
  }
}
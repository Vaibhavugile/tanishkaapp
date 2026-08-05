class AdminPermissions {
  final bool canManageAdmins;

  final bool canCreateAdmins;

  final bool canEditAdmins;

  final bool canDeleteAdmins;

  //--------------------------------------------------
  // Orders
  //--------------------------------------------------

  final bool canViewOrders;

  final bool canEditOrders;

  final bool canCancelOrders;

  final bool canAssignOrders;

  //--------------------------------------------------
  // Chat
  //--------------------------------------------------

  final bool canChat;

  final bool canDeleteMessages;

  //--------------------------------------------------
  // Packing
  //--------------------------------------------------

  final bool canPackOrders;

  final bool canMarkMissing;

  final bool canMarkDamaged;

  //--------------------------------------------------
  // Payments
  //--------------------------------------------------

  final bool canRequestPayment;

  final bool canVerifyPayments;

  final bool canRefundPayments;

  //--------------------------------------------------
  // Shipping
  //--------------------------------------------------

  final bool canShipOrders;

  final bool canGenerateLabels;

  //--------------------------------------------------
  // Products
  //--------------------------------------------------

  final bool canViewProducts;

  final bool canCreateProducts;

  final bool canEditProducts;

  final bool canDeleteProducts;

  //--------------------------------------------------
  // Inventory
  //--------------------------------------------------

  final bool canManageInventory;

  //--------------------------------------------------
  // Reports
  //--------------------------------------------------

  final bool canViewReports;

  //--------------------------------------------------
  // Settings
  //--------------------------------------------------

  final bool canManageSettings;

  //--------------------------------------------------
  // Audit
  //--------------------------------------------------

  final bool canViewAuditLogs;

  const AdminPermissions({
    this.canManageAdmins = false,
    this.canCreateAdmins = false,
    this.canEditAdmins = false,
    this.canDeleteAdmins = false,

    this.canViewOrders = false,
    this.canEditOrders = false,
    this.canCancelOrders = false,
    this.canAssignOrders = false,

    this.canChat = false,
    this.canDeleteMessages = false,

    this.canPackOrders = false,
    this.canMarkMissing = false,
    this.canMarkDamaged = false,

    this.canRequestPayment = false,
    this.canVerifyPayments = false,
    this.canRefundPayments = false,

    this.canShipOrders = false,
    this.canGenerateLabels = false,

    this.canViewProducts = false,
    this.canCreateProducts = false,
    this.canEditProducts = false,
    this.canDeleteProducts = false,

    this.canManageInventory = false,

    this.canViewReports = false,

    this.canManageSettings = false,

    this.canViewAuditLogs = false,
  });

  factory AdminPermissions.fromMap(
    Map<String, dynamic>? map,
  ) {
    map ??= {};

    return AdminPermissions(
      canManageAdmins:
          map["canManageAdmins"] ?? false,
      canCreateAdmins:
          map["canCreateAdmins"] ?? false,
      canEditAdmins:
          map["canEditAdmins"] ?? false,
      canDeleteAdmins:
          map["canDeleteAdmins"] ?? false,

      canViewOrders:
          map["canViewOrders"] ?? false,
      canEditOrders:
          map["canEditOrders"] ?? false,
      canCancelOrders:
          map["canCancelOrders"] ?? false,
      canAssignOrders:
          map["canAssignOrders"] ?? false,

      canChat:
          map["canChat"] ?? false,
      canDeleteMessages:
          map["canDeleteMessages"] ?? false,

      canPackOrders:
          map["canPackOrders"] ?? false,
      canMarkMissing:
          map["canMarkMissing"] ?? false,
      canMarkDamaged:
          map["canMarkDamaged"] ?? false,

      canRequestPayment:
          map["canRequestPayment"] ?? false,
      canVerifyPayments:
          map["canVerifyPayments"] ?? false,
      canRefundPayments:
          map["canRefundPayments"] ?? false,

      canShipOrders:
          map["canShipOrders"] ?? false,
      canGenerateLabels:
          map["canGenerateLabels"] ?? false,

      canViewProducts:
          map["canViewProducts"] ?? false,
      canCreateProducts:
          map["canCreateProducts"] ?? false,
      canEditProducts:
          map["canEditProducts"] ?? false,
      canDeleteProducts:
          map["canDeleteProducts"] ?? false,

      canManageInventory:
          map["canManageInventory"] ?? false,

      canViewReports:
          map["canViewReports"] ?? false,

      canManageSettings:
          map["canManageSettings"] ?? false,

      canViewAuditLogs:
          map["canViewAuditLogs"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "canManageAdmins": canManageAdmins,
      "canCreateAdmins": canCreateAdmins,
      "canEditAdmins": canEditAdmins,
      "canDeleteAdmins": canDeleteAdmins,

      "canViewOrders": canViewOrders,
      "canEditOrders": canEditOrders,
      "canCancelOrders": canCancelOrders,
      "canAssignOrders": canAssignOrders,

      "canChat": canChat,
      "canDeleteMessages": canDeleteMessages,

      "canPackOrders": canPackOrders,
      "canMarkMissing": canMarkMissing,
      "canMarkDamaged": canMarkDamaged,

      "canRequestPayment": canRequestPayment,
      "canVerifyPayments": canVerifyPayments,
      "canRefundPayments": canRefundPayments,

      "canShipOrders": canShipOrders,
      "canGenerateLabels": canGenerateLabels,

      "canViewProducts": canViewProducts,
      "canCreateProducts": canCreateProducts,
      "canEditProducts": canEditProducts,
      "canDeleteProducts": canDeleteProducts,

      "canManageInventory": canManageInventory,

      "canViewReports": canViewReports,

      "canManageSettings": canManageSettings,

      "canViewAuditLogs": canViewAuditLogs,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';

enum _VerificationFilter {
  all,
  pending,
  approved,
  rejected,
  suspended,
}

class VerificationApprovalScreen extends StatefulWidget {
  const VerificationApprovalScreen({super.key});

  @override
  State<VerificationApprovalScreen> createState() =>
      _VerificationApprovalScreenState();
}

class _VerificationApprovalScreenState
    extends State<VerificationApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  static const Color _pink = Color(0xffD81B78);
  static const Color _page = Color(0xffFFF8FB);

  _VerificationFilter _filter = _VerificationFilter.pending;
  String _search = '';
  bool _isProcessing = false;
  String? _processingUid;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _usersStream =>
      _firestore.collection('appUsers').snapshots();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim().toLowerCase();
    if (value != _search && mounted) {
      setState(() => _search = value);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  String _statusOf(Map<String, dynamic> data) {
    final status = (data['verificationStatus'] ?? '').toString().trim().toLowerCase();
    if (status.isNotEmpty) return status;

    // Compatibility for older documents that may have only boolean flags.
    if (data['isBlocked'] == true) return 'suspended';
    if (data['adminVerified'] == true || data['isVerified'] == true) {
      return 'approved';
    }
    return 'pending';
  }

  bool _matchesFilter(Map<String, dynamic> data) {
    final status = _statusOf(data);
    switch (_filter) {
      case _VerificationFilter.all:
        return true;
      case _VerificationFilter.pending:
        return status == 'pending' || status == 'submitted' || status == 'under_review';
      case _VerificationFilter.approved:
        return status == 'approved';
      case _VerificationFilter.rejected:
        return status == 'rejected';
      case _VerificationFilter.suspended:
        return status == 'suspended' || data['isBlocked'] == true;
    }
  }

  bool _matchesSearch(Map<String, dynamic> data, String uid) {
    if (_search.isEmpty) return true;
    final values = <String>[
      uid,
      data['firstName']?.toString() ?? '',
      data['lastName']?.toString() ?? '',
      data['phone']?.toString() ?? '',
      data['email']?.toString() ?? '',
      data['shopName']?.toString() ?? '',
      data['city']?.toString() ?? '',
      data['state']?.toString() ?? '',
      data['businessType']?.toString() ?? '',
      data['gstNumber']?.toString() ?? '',
    ];
    return values.any((value) => value.toLowerCase().contains(_search));
  }

  String _displayName(Map<String, dynamic> data) {
    final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    return name.isEmpty ? 'Unknown User' : name;
  }

  String _prettyStatus(String status) {
    if (status.isEmpty) return 'Pending';
    return status
        .split('_')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmText,
    Color confirmColor = _pink,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _approveUser(String uid, Map<String, dynamic> data) async {
    if (_isProcessing) return;
    final name = _displayName(data);
    final confirmed = await _confirm(
      title: 'Approve account?',
      message: 'Approve $name for wholesale access and activate this account?',
      confirmText: 'Approve',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
      _processingUid = uid;
    });

    try {
      await _firestore.collection('appUsers').doc(uid).update({
        'verificationStatus': 'approved',
        'adminVerified': true,
        'isVerified': true,
        'isActive': true,
        'isBlocked': false,
        'role': 'wholesale',
        'approvedBy': AdminService.instance.uid,
        'approvedAt': FieldValue.serverTimestamp(),
        'rejectedReason': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showMessage('$name approved successfully.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Approval failed: $e', success: false);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingUid = null;
        });
      }
    }
  }

  Future<void> _rejectUser(String uid, Map<String, dynamic> data) async {
    if (_isProcessing) return;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject verification',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter the reason for rejection',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reason == null || reason.trim().isEmpty || !mounted) return;

    setState(() {
      _isProcessing = true;
      _processingUid = uid;
    });
    try {
      await _firestore.collection('appUsers').doc(uid).update({
        'verificationStatus': 'rejected',
        'adminVerified': false,
        'isVerified': false,
        'isActive': false,
        'approvedBy': '',
        'approvedAt': null,
        'rejectedReason': reason.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _showMessage('${_displayName(data)} rejected.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Rejection failed: $e', success: false);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingUid = null;
        });
      }
    }
  }

  Future<void> _returnToPending(String uid, Map<String, dynamic> data) async {
    if (_isProcessing) return;
    final name = _displayName(data);
    final confirmed = await _confirm(
      title: 'Return to pending?',
      message: 'Move $name back to pending review? The account will be deactivated.',
      confirmText: 'Return to pending',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
      _processingUid = uid;
    });
    try {
      await _firestore.collection('appUsers').doc(uid).update({
        'verificationStatus': 'pending',
        'adminVerified': false,
        'isVerified': false,
        'isActive': false,
        'isBlocked': false,
        'approvedBy': '',
        'approvedAt': null,
        'rejectedReason': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _showMessage('$name returned to pending review.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not update status: $e', success: false);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingUid = null;
        });
      }
    }
  }

  Future<void> _setSuspended(
    String uid,
    Map<String, dynamic> data, {
    required bool suspend,
  }) async {
    if (_isProcessing) return;
    final name = _displayName(data);
    final confirmed = await _confirm(
      title: suspend ? 'Suspend account?' : 'Unsuspend account?',
      message: suspend
          ? 'Suspend $name? This will mark the account as suspended and inactive.'
          : 'Unsuspend $name? The account will remain inactive until approved again.',
      confirmText: suspend ? 'Suspend' : 'Unsuspend',
      confirmColor: suspend ? Colors.deepOrange : _pink,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
      _processingUid = uid;
    });
    try {
      await _firestore.collection('appUsers').doc(uid).update({
        'verificationStatus': suspend ? 'suspended' : 'pending',
        'isBlocked': suspend,
        'isActive': false,
        'isVerified': false,
        'adminVerified': false,
        if (!suspend) 'approvedBy': '',
        if (!suspend) 'approvedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _showMessage(
        suspend ? '$name suspended.' : '$name unsuspended and returned to pending.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Status update failed: $e', success: false);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingUid = null;
        });
      }
    }
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        content: Text(message),
      ),
    );
  }

  int _countFor(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    _VerificationFilter filter,
  ) {
    return docs.where((doc) {
      final data = doc.data();
      final status = _statusOf(data);
      switch (filter) {
        case _VerificationFilter.all:
          return true;
        case _VerificationFilter.pending:
          return status == 'pending' || status == 'submitted' || status == 'under_review';
        case _VerificationFilter.approved:
          return status == 'approved';
        case _VerificationFilter.rejected:
          return status == 'rejected';
        case _VerificationFilter.suspended:
          return status == 'suspended' || data['isBlocked'] == true;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2C2C2C),
        title: const Text(
          'Verification Management',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _pink));
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Unable to load users.\n\n${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data();
            return _matchesFilter(data) && _matchesSearch(data, doc.id);
          }).toList();

          // Sort most recently created records first; documents without timestamps go last.
          filteredDocs.sort((a, b) {
            final aValue = a.data()['createdAt'];
            final bValue = b.data()['createdAt'];
            final aDate = aValue is Timestamp ? aValue : null;
            final bDate = bValue is Timestamp ? bValue : null;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

          return Column(
            children: [
              _buildSummary(allDocs),
              _buildSearch(),
              _buildTabs(allDocs),
              Expanded(
                child: filteredDocs.isEmpty
                    ? _EmptyState(
                        filter: _filter,
                        hasSearch: _search.isNotEmpty,
                        onClear: () {
                          _searchController.clear();
                          setState(() => _filter = _VerificationFilter.all);
                        },
                      )
                    : RefreshIndicator(
                        color: _pink,
                        onRefresh: () async {
                          // Firestore snapshots refresh automatically. This rebuilds the UI.
                          setState(() {});
                          await Future<void>.delayed(
                            const Duration(milliseconds: 250),
                          );
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data = doc.data();
                            final status = _statusOf(data);
                            final busy = _isProcessing && _processingUid == doc.id;
                            return _ApprovalCard(
                              data: data,
                              uid: doc.id,
                              status: status,
                              busy: busy,
                              onApprove: () => _approveUser(doc.id, data),
                              onReject: () => _rejectUser(doc.id, data),
                              onReturnToPending: () => _returnToPending(doc.id, data),
                              onSuspend: () => _setSuspended(doc.id, data, suspend: true),
                              onUnsuspend: () => _setSuspended(doc.id, data, suspend: false),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final pending = _countFor(docs, _VerificationFilter.pending);
    final approved = _countFor(docs, _VerificationFilter.approved);
    final rejected = _countFor(docs, _VerificationFilter.rejected);
    final suspended = _countFor(docs, _VerificationFilter.suspended);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account overview',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Total', value: docs.length, color: const Color(0xff5B5BD6), icon: Icons.people_alt_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Pending', value: pending, color: Colors.orange.shade800, icon: Icons.hourglass_top_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Approved', value: approved, color: Colors.green.shade700, icon: Icons.verified_outlined)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Rejected', value: rejected, color: Colors.red.shade700, icon: Icons.cancel_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Suspended', value: suspended, color: Colors.deepOrange.shade700, icon: Icons.block_outlined)),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search name, phone, shop, email, city, UID...',
          prefixIcon: const Icon(Icons.search_rounded, color: _pink),
          suffixIcon: _search.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.pink.shade50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.pink.shade100),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    const filters = _VerificationFilter.values;
    const labels = {
      _VerificationFilter.all: 'All',
      _VerificationFilter.pending: 'Pending',
      _VerificationFilter.approved: 'Approved',
      _VerificationFilter.rejected: 'Rejected',
      _VerificationFilter.suspended: 'Suspended',
    };

    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _filter == filter;
          final count = _countFor(docs, filter);
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _filter = filter),
            selectedColor: _pink,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? _pink : Colors.pink.shade100,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels[filter]!,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xff39323A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withOpacity(.20) : _page,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.data,
    required this.uid,
    required this.status,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onReturnToPending,
    required this.onSuspend,
    required this.onUnsuspend,
  });

  final Map<String, dynamic> data;
  final String uid;
  final String status;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReturnToPending;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;

  static const Color _pink = Color(0xffD81B78);

  String get _name {
    final value = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    return value.isEmpty ? 'Unknown User' : value;
  }

  String get _statusLabel {
    if (status.isEmpty) return 'Pending';
    return status
        .split('_')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Color get _statusColor {
    switch (status) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'suspended':
        return Colors.deepOrange.shade700;
      default:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = data['phone']?.toString() ?? '';
    final email = data['email']?.toString() ?? '';
    final shop = data['shopName']?.toString() ?? '';
    final city = data['city']?.toString() ?? '';
    final state = data['state']?.toString() ?? '';
    final businessType = data['businessType']?.toString() ?? '';
    final reason = data['rejectedReason']?.toString() ?? '';
    final createdAt = data['createdAt'];
    final createdLabel = createdAt is Timestamp
        ? '${createdAt.toDate().day.toString().padLeft(2, '0')}/${createdAt.toDate().month.toString().padLeft(2, '0')}/${createdAt.toDate().year}'
        : 'Date unavailable';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _statusColor.withOpacity(.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xffFCE4EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: _pink, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone.isEmpty ? 'No phone number' : phone,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Submitted: $createdLabel',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _InfoRow(icon: Icons.storefront_outlined, label: 'Shop', value: shop),
          _InfoRow(icon: Icons.business_outlined, label: 'Business', value: businessType),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: [city, state].where((part) => part.trim().isNotEmpty).join(', '),
          ),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
          _InfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'GST',
            value: data['gstNumber']?.toString() ?? '',
          ),
          if (reason.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Rejection reason: $reason',
                style: TextStyle(color: Colors.red.shade800, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 15),
          if (busy)
            const LinearProgressIndicator(color: _pink)
          else
            _buildActions(),
          const SizedBox(height: 7),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: const Text(
              'More account details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            children: [
              _InfoRow(icon: Icons.fingerprint, label: 'UID', value: uid),
              _InfoRow(icon: Icons.language_outlined, label: 'Website', value: data['website']?.toString() ?? ''),
              _InfoRow(icon: Icons.camera_alt_outlined, label: 'Instagram', value: data['instagram']?.toString() ?? ''),
              _InfoRow(icon: Icons.location_city_outlined, label: 'Address', value: data['address']?.toString() ?? ''),
              _InfoRow(icon: Icons.pin_drop_outlined, label: 'Pincode', value: data['pincode']?.toString() ?? ''),
              _InfoRow(icon: Icons.badge_outlined, label: 'Role', value: data['role']?.toString() ?? ''),
              _InfoRow(icon: Icons.verified_user_outlined, label: 'Admin verified', value: '${data['adminVerified'] ?? false}'),
              _InfoRow(icon: Icons.check_circle_outline, label: 'Is verified', value: '${data['isVerified'] ?? false}'),
              _InfoRow(icon: Icons.toggle_on_outlined, label: 'Active', value: '${data['isActive'] ?? false}'),
              _InfoRow(icon: Icons.block_outlined, label: 'Blocked', value: '${data['isBlocked'] ?? false}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (status == 'pending' || status == 'submitted' || status == 'under_review') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Approve'),
              style: FilledButton.styleFrom(
                backgroundColor: _pink,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'approved') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReturnToPending,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Return to pending'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSuspend,
              icon: const Icon(Icons.block_rounded, size: 18),
              label: const Text('Suspend'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepOrange.shade700,
                side: BorderSide(color: Colors.deepOrange.shade300),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'suspended' || data['isBlocked'] == true) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onUnsuspend,
          icon: const Icon(Icons.lock_open_rounded, size: 18),
          label: const Text('Unsuspend and return to pending'),
          style: FilledButton.styleFrom(
            backgroundColor: _pink,
            minimumSize: const Size(0, 46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onReturnToPending,
        icon: const Icon(Icons.replay_rounded, size: 18),
        label: const Text('Reopen for review'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xffD81B78)),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              displayValue,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
    required this.hasSearch,
    required this.onClear,
  });

  final _VerificationFilter filter;
  final bool hasSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      _VerificationFilter.all => 'No users found',
      _VerificationFilter.pending => 'No pending approvals',
      _VerificationFilter.approved => 'No approved accounts',
      _VerificationFilter.rejected => 'No rejected accounts',
      _VerificationFilter.suspended => 'No suspended accounts',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: Color(0xffFCE4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_accounts_outlined,
                size: 43,
                color: Color(0xffD81B78),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasSearch ? 'No matching accounts' : label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try another name, phone number, shop name, email, or UID.'
                  : 'New registrations will appear here when they are saved to appUsers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Show all accounts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 54),
            const SizedBox(height: 16),
            const Text(
              'Could not load verification records',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SelectableText(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

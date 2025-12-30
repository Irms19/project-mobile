import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageBookingPage extends StatefulWidget {
  const AdminManageBookingPage({super.key});

  @override
  State<AdminManageBookingPage> createState() => _AdminManageBookingPageState();
}

class _AdminManageBookingPageState extends State<AdminManageBookingPage> {
  final Color primaryColor = const Color(0xFF102C57);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  String searchQuery = "";

  // Update Status in Firestore
  Future<void> _updateBookingStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // Confirmation Dialog logic
  void _showConfirmActionDialog(String docId, String newStatus, String actionLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Confirm $actionLabel",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to $actionLabel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionLabel == "Approve" ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _updateBookingStatus(docId, newStatus);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Booking ${actionLabel}d successfully")),
              );
            },
            child: Text(actionLabel.toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('MANAGE BOOKINGS',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'PENDING'), Tab(text: 'HISTORY')],
          ),
        ),
        body: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFirestoreList(['pending', 'pending_payment', 'Upcoming']),
                  _buildFirestoreList(['confirmed', 'cancelled', 'Approved', 'Rejected']),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: primaryColor,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search venue name...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFirestoreList(List<String> statuses) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('status', whereIn: statuses)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final venue = (data['venueName'] ?? "").toString().toLowerCase();
          return venue.contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) return const Center(child: Text("No bookings in this category"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final docId = filteredDocs[index].id;
            return _buildCleanCard(docId, data);
          },
        );
      },
    );
  }

  Widget _buildCleanCard(String docId, Map<String, dynamic> item) {
    String status = (item['status'] ?? '').toString();
    bool isPending = status == 'pending' || status == 'pending_payment' || status == 'Upcoming';
    String uID = (item['userId'] ?? '').toString();
    List<dynamic> addons = item['addons'] ?? [];

    String displayDate = "No Date";
    if (item['bookingDate'] != null) {
      DateTime dt = (item['bookingDate'] as Timestamp).toDate();
      displayDate = "${dt.day} ${_getMonth(dt.month)} ${dt.year}";
    }

    Color statusBadgeColor = (status == 'confirmed' || status == 'Approved')
        ? Colors.green : (status == 'cancelled' || status == 'Rejected') ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Side: Venue Image
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: Image.asset(
                  item['venueImagePath'] ?? 'assets/welcome1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                ),
              ),
            ),

            // Middle: Information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text((item['venueName'] ?? "NO NAME").toString().toUpperCase(),
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                        Text("RM${item['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(uID).get(),
                      builder: (context, userSnapshot) {
                        final userName = (userSnapshot.data?.data() as Map?)?['username'] ?? 'Anonymous';
                        return Text('User: $userName', style: TextStyle(color: Colors.grey[600], fontSize: 11));
                      },
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, size: 12, color: primaryColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(displayDate, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (!isPending) _buildStatusBadge(status, statusBadgeColor),
                      ],
                    ),

                    const Divider(height: 16),

                    // Display Add-ons
                    const Text("ADD-ONS:", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    addons.isEmpty
                        ? const Text("None selected", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic))
                        : Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: addons.map((addon) => _buildAddonChip(addon.toString())).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side: Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPending) ...[
                    _actionCircle(Icons.check, Colors.green, () => _showConfirmActionDialog(docId, 'confirmed', 'Approve')),
                    const SizedBox(height: 12),
                    _actionCircle(Icons.close, Colors.red, () => _showConfirmActionDialog(docId, 'Rejected', 'Reject')),
                  ] else
                    _actionCircle(Icons.edit_note_rounded, primaryColor, () {
                      showDialog(context: context, builder: (context) => EditBookingModal(docId: docId, bookingData: item));
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddonChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _actionCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 55,
          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(25)),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class EditBookingModal extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> bookingData;
  const EditBookingModal({super.key, required this.docId, required this.bookingData});

  @override
  State<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends State<EditBookingModal> {
  late TextEditingController venueController;
  late TextEditingController priceController;
  late String selectedStatus;

  final List<String> statusOptions = ['pending', 'confirmed', 'cancelled', 'Rejected'];

  @override
  void initState() {
    super.initState();
    venueController = TextEditingController(text: (widget.bookingData['venueName'] ?? '').toString());
    priceController = TextEditingController(text: (widget.bookingData['totalPrice'] ?? '').toString());
    String currentStatus = widget.bookingData['status'] ?? 'pending';
    selectedStatus = statusOptions.contains(currentStatus) ? currentStatus : 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Update Booking", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF102C57))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Booking Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: venueController,
              decoration: InputDecoration(
                labelText: "Venue Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Total Price (RM)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Booking Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF102C57),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('bookings').doc(widget.docId).update({
              'venueName': venueController.text,
              'totalPrice': double.tryParse(priceController.text) ?? 0.0,
              'status': selectedStatus,
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
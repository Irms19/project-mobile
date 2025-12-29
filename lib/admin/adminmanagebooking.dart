import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminpage.dart';

class AdminManageBookingPage extends StatefulWidget {
  const AdminManageBookingPage({super.key});

  @override
  State<AdminManageBookingPage> createState() => _AdminManageBookingPageState();
}

class _AdminManageBookingPageState extends State<AdminManageBookingPage> {
  final Color primaryColor = const Color(0xFF102C57);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
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
            tabs: [Tab(text: 'PENDING'), Tab(text: 'HISTORY')], // Changed name to History
          ),
        ),
        body: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Logic - Action required
                  _buildFirestoreList(['pending', 'pending_payment', 'Upcoming']),
                  // Tab 2: Logic - Archive/History
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
            return _buildPillCard(docId, data);
          },
        );
      },
    );
  }

  Widget _buildPillCard(String docId, Map<String, dynamic> item) {
    String status = (item['status'] ?? '').toString();
    bool isPending = status == 'pending' || status == 'pending_payment' || status == 'Upcoming';
    String uID = (item['userId'] ?? '').toString();

    String displayDate = "No Date";
    if (item['bookingDate'] != null) {
      DateTime dt = (item['bookingDate'] as Timestamp).toDate();
      displayDate = "${dt.day} ${_getMonth(dt.month)} ${dt.year}";
    }

    // Badge color logic for History tab
    Color statusBadgeColor = (status == 'confirmed' || status == 'Approved')
        ? Colors.green
        : (status == 'cancelled' || status == 'Rejected') ? Colors.red : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120, // Increased height for the badge
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120, height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(60), bottomLeft: Radius.circular(60)),
              child: Image.asset(
                item['venueImagePath'] ?? 'assets/welcome1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((item['venueName'] ?? "NO NAME").toString().toUpperCase(),
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(uID).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        return Text('User: ${userData?['username'] ?? 'Anonymous'}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12));
                      }
                      return const Text('User: ...', style: TextStyle(color: Colors.grey, fontSize: 12));
                    },
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14, color: primaryColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(displayDate, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // Status Badge for Completed Tab
                  if (!isPending) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusBadgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(status.toUpperCase(), style: TextStyle(color: statusBadgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                if (isPending) ...[
                  _actionCircle(Icons.check, Colors.green, () => _updateBookingStatus(docId, 'confirmed')),
                  const SizedBox(width: 10),
                  _actionCircle(Icons.close, Colors.red, () => _updateBookingStatus(docId, 'Rejected')),
                ] else
                  _actionCircle(Icons.edit_outlined, primaryColor, () {
                    showDialog(context: context, builder: (context) => EditBookingModal(docId: docId, bookingData: item));
                  }),
              ],
            ),
          ),
        ],
      ),
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

  // Define the available statuses for the Admin
  final List<String> statusOptions = ['pending', 'confirmed', 'cancelled', 'Rejected'];

  @override
  void initState() {
    super.initState();
    venueController = TextEditingController(text: (widget.bookingData['venueName'] ?? '').toString());
    priceController = TextEditingController(text: (widget.bookingData['totalPrice'] ?? '').toString());

    // Set initial status, ensuring it matches one of our options
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
            // STATUS DROPDOWN
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
              'totalPrice': priceController.text,
              'status': selectedStatus, // Saves the new status
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
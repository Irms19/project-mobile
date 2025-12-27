import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF102C57),
          title: const Text('My Bookings'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Current'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: currentUserId.isEmpty
            ? const Center(child: Text("Please login to see bookings"))
            : TabBarView(
          children: [
            _buildFirestoreBookingList(['pending', 'confirmed']), // Current
            _buildFirestoreBookingList(['completed', 'cancelled', 'Rejected']), // History
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreBookingList(List<String> statuses) {
    return StreamBuilder<QuerySnapshot>(
      // Filter by CURRENT USER and matching STATUSES
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUserId)
          .where('status', whereIn: statuses)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading bookings'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF102C57)));
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;

            // Handle Firestore Timestamp to String
            String formattedDate = "N/A";
            if (data['bookingDate'] != null) {
              DateTime dt = (data['bookingDate'] as Timestamp).toDate();
              formattedDate = DateFormat('dd/MM/yyyy').format(dt);
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Image (Using imagePath from Firestore)
                  _buildVenueImage(data['venueImagePath'] ?? data['imagePath']),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['venueName'] ?? 'Unknown Venue',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusChip(data['status'] ?? 'pending'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                            const Spacer(),
                            Text(
                              "RM${data['totalPrice'] ?? '0'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF102C57),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, thickness: 1),
                        ),

                        // Action Buttons based on status
                        if (data['status'] == 'pending' || data['status'] == 'confirmed')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF102C57),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () => _showEditModal(docId, data),
                                  child: const Text('Edit Booking'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => _confirmCancel(docId),
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                child: const Text('Cancel'),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVenueImage(String? path) {
    if (path != null && path.startsWith('http')) {
      return Image.network(path, width: double.infinity, height: 160, fit: BoxFit.cover);
    } else {
      return Image.asset(path ?? 'assets/welcome1.jpg', width: double.infinity, height: 160, fit: BoxFit.cover);
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // Handle Cancellation in Firestore
  void _confirmCancel(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': 'cancelled'});
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditModal(String docId, Map data) {
    showDialog(
      context: context,
      builder: (context) => EditBookingModal(docId: docId, bookingData: data),
    );
  }
}

// Updated Modal to save to Firestore
class EditBookingModal extends StatefulWidget {
  final String docId;
  final Map bookingData;
  const EditBookingModal({super.key, required this.docId, required this.bookingData});

  @override
  State<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends State<EditBookingModal> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.bookingData['bookingDate'] != null) {
      selectedDate = (widget.bookingData['bookingDate'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Date"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Current: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}"),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate!,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: const Text("Pick New Date"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('bookings').doc(widget.docId).update({
              'bookingDate': Timestamp.fromDate(selectedDate!),
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
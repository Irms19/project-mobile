import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  // Mock data for bookings
  final List<Map<String, dynamic>> bookings = [
    {
      'venue': 'Casandra',
      'date': '25/12/2025',
      'status': 'Upcoming',
      'price': 'RM5000',
    },
    {
      'venue': 'Conference Room A',
      'date': '10/11/2024',
      'status': 'Completed',
      'price': 'RM1200',
    },
  ];

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
        body: TabBarView(
          children: [
            _buildBookingList('Upcoming'),
            _buildBookingList('Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(String filterStatus) {
    final filteredList = bookings.where((b) => b['status'] == filterStatus).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['venue'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildStatusChip(item['status']),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Date: ${item['date']}', style: const TextStyle(color: Colors.grey)),
                Text('Total Paid: ${item['price']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Divider(height: 24),

                if (filterStatus == 'Upcoming')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF102C57),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _showEditModal(item),
                          child: const Text('Edit', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => _confirmCancel(item),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF102C57),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
                      onPressed: () {},
                      child: const Text('Rebook Venue'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Upcoming' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: status == 'Upcoming' ? Colors.blue : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _showEditModal(Map item) {
    showDialog(
      context: context,
      builder: (context) => EditBookingModal(bookingData: item),
    );
  }

  // --- FIGMA STYLED CANCEL DIALOG ---
  void _confirmCancel(Map item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Large corners per Figma
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cancel Booking?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),

              // Yes Button (Pill shape)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102C57),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    // logic here
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Yes, cancel booking',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // No Link
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'No, keep booking',
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- FIGMA STYLED EDIT MODAL ---
class EditBookingModal extends StatefulWidget {
  final Map bookingData;
  const EditBookingModal({super.key, required this.bookingData});

  @override
  State<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends State<EditBookingModal> {
  String? selectedHall;
  DateTime? selectedDate;
  final List<String> halls = ['Grand Ballroom', 'Casandra', 'Conference Room A', 'Outdoor Garden'];

  @override
  void initState() {
    super.initState();
    selectedHall = widget.bookingData['venue'];
    try {
      selectedDate = DateFormat('dd/MM/yyyy').parse(widget.bookingData['date']);
    } catch (e) {
      selectedDate = DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit your booking", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _buildLabel("Hall Name"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedHall,
                  isExpanded: true,
                  items: halls.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                  onChanged: (val) => setState(() => selectedHall = val),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Date"),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      selectedDate == null ? "Select Date" : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text("Calendar", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF102C57),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Update Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }
}
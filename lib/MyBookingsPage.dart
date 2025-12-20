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
      'imagePath': 'assets/welcome1.jpg',
      'venue': 'Casandra',
      'date': '25/12/2025',
      'status': 'Upcoming',
      'price': 'RM5000',
    },
    {
      'imagePath': 'assets/welcome1.jpg', // Replace with welcome2.jpg if available
      'venue': 'Conference Room A',
      'date': '10/11/2024',
      'status': 'Completed',
      'price': 'RM1200',
    },
    {
      'imagePath': 'assets/welcome2.jpg', // Replace with welcome3.jpg if available
      'venue': 'Outdoor Garden',
      'date': '15/06/2024',
      'status': 'Completed',
      'price': 'RM7500',
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
    final filteredList =
    bookings.where((b) => b['status'] == filterStatus).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Featured Image
              Image.asset(
                item['imagePath'] ?? 'assets/welcome1.jpg',
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Title & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['venue'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(item['status']),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 3. Date & Price
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(item['date'], style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        Text(
                          item['price'],
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

                    // 4. Action Buttons
                    if (filterStatus == 'Upcoming')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF102C57),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => _showEditModal(item),
                              child: const Text('Edit Booking'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => _confirmCancel(item),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent),
                            child: const Text('Cancel'),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF102C57)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Rebook Venue',
                            style: TextStyle(
                                color: Color(0xFF102C57),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Upcoming'
            ? Colors.blue.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: status == 'Upcoming' ? Colors.blue : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  void _showEditModal(Map item) {
    showDialog(
      context: context,
      builder: (context) => EditBookingModal(bookingData: item),
    );
  }

  void _confirmCancel(Map item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cancel Booking?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102C57),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Yes, cancel booking',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No, keep booking',
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditBookingModal extends StatefulWidget {
  final Map bookingData;
  const EditBookingModal({super.key, required this.bookingData});

  @override
  State<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends State<EditBookingModal> {
  String? selectedHall;
  DateTime? selectedDate;
  final List<String> halls = [
    'Grand Ballroom',
    'Casandra',
    'Conference Room A',
    'Outdoor Garden'
  ];

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
            const Text("Edit your booking",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  items: halls
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
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
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text("Calendar",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.waves, color: Colors.grey, size: 50),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF102C57),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Update Booking",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back",
                  style: TextStyle(
                      color: Colors.black, decoration: TextDecoration.underline)),
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
        child: Text(text,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }
}
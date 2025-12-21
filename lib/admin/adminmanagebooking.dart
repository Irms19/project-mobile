import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'adminpage.dart';

class AdminManageBookingPage extends StatefulWidget {
  const AdminManageBookingPage({super.key});

  @override
  State<AdminManageBookingPage> createState() => _AdminManageBookingPageState();
}

class _AdminManageBookingPageState extends State<AdminManageBookingPage> {
  final Color primaryColor = const Color(0xFF102C57);
  String searchQuery = "";

  final List<Map<String, dynamic>> bookings = [
    {
      'imagePath': 'assets/welcome1.jpg',
      'venue': 'Casandra',
      'user': 'AZAM',
      'date': '25/12/2025',
      'status': 'Upcoming',
      'price': 'RM5000',
    },
    {
      'imagePath': 'assets/welcome1.jpg',
      'venue': 'Conference Room A',
      'user': 'SITI',
      'date': '10/11/2024',
      'status': 'Completed',
      'price': 'RM1200',
    },
  ];

  void _updateStatus(int index, String newStatus) {
    setState(() => bookings[index]['status'] = newStatus);
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
            tabs: [Tab(text: 'PENDING'), Tab(text: 'COMPLETED')],
          ),
        ),
        body: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFilteredList('Upcoming'),
                  _buildFilteredList('Completed'),
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
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search venue or customer...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilteredList(String filterStatus) {
    final filteredList = bookings.where((b) {
      final matchesStatus = b['status'] == filterStatus;
      final matchesSearch = b['venue'].toLowerCase().contains(searchQuery) ||
          b['user'].toLowerCase().contains(searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) => _buildPillCard(filteredList[index]),
    );
  }

  Widget _buildPillCard(Map<String, dynamic> item) {
    int originalIndex = bookings.indexOf(item);
    bool isPending = item['status'] == 'Upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        // Uniform border color fixed the error
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Left: Image Section
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
              child: Image.asset(item['imagePath'], fit: BoxFit.cover),
            ),
          ),

          // Center: Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['venue'].toUpperCase(),
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('User: ${item['user']}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  Text('Date: ${item['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
          ),

          // Right: Actions
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                if (isPending) ...[
                  _actionCircle(Icons.check, Colors.green, () => _updateStatus(originalIndex, 'Approved')),
                  const SizedBox(width: 8),
                  _actionCircle(Icons.close, Colors.red, () => _updateStatus(originalIndex, 'Rejected')),
                  const SizedBox(width: 8),
                ],
                _actionCircle(Icons.edit_outlined, primaryColor, () {
                  showDialog(context: context, builder: (context) => EditBookingModal(bookingData: item));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage())),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class EditBookingModal extends StatelessWidget {
  final Map bookingData;
  const EditBookingModal({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Edit Booking"),
      content: Text("Managing ${bookingData['venue']}"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))
      ],
    );
  }
}
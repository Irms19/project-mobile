import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/venue.dart';

class BookingPage extends StatefulWidget {
  final Venue venue;

  const BookingPage({super.key, required this.venue});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  int guests = 1;
  double totalPrice = 0;

  final List<Map<String, dynamic>> addons = [
    {
      'name': 'Catering',
      'price': 30,
      'selected': false,
      'isPerGuest': true,
      'icon': Icons.restaurant
    },
    {
      'name': 'Decoration',
      'price': 800,
      'selected': false,
      'isPerGuest': false,
      'icon': Icons.celebration
    },
    {
      'name': 'Audio/Visual Equipment',
      'price': 500,
      'selected': false,
      'isPerGuest': false,
      'icon': Icons.mic_external_on
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshTotal();
  }

  void _refreshTotal() {
    setState(() {
      totalPrice = _calculateTotal();
    });
  }

  double _calculateTotal() {
    try {
      String cleanedPrice = widget.venue.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double venuePrice = double.tryParse(cleanedPrice) ?? 0.0;

      double addonsPrice = 0;
      for (var addon in addons) {
        if (addon['selected'] == true) {
          addonsPrice += addon['isPerGuest']
              ? (addon['price'] * guests)
              : (addon['price'] as num).toDouble();
        }
      }
      return venuePrice + addonsPrice;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // --- SUCCESS MODAL ---
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                "Congratulations!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF102C57)),
              ),
              const SizedBox(height: 15),
              const Text(
                "You have successfully booked your hall. See you there!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102C57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    // Navigate to your MyBookingsPage here
                  },
                  child: const Text("View Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Home", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Venue: ${widget.venue.name}\nDate: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}\nTotal: RM${totalPrice.toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Edit')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessModal();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF102C57),
        title: Text(widget.venue.name),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(widget.venue.imagePath, width: double.infinity, height: 220, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.venue.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.venue.info, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Text(widget.venue.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF102C57))),
                  ],
                ),
                const Divider(height: 40),
                const Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF102C57)),
                  title: Text(selectedDate == null ? 'Select Booking Date' : DateFormat('EEEE, dd MMM yyyy').format(selectedDate!)),
                  trailing: TextButton(onPressed: () => _pickDate(context), child: const Text('Change')),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of Guests', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(onPressed: () { if (guests > 1) { setState(() => guests--); _refreshTotal(); } }, icon: const Icon(Icons.remove_circle_outline)),
                        Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () { setState(() => guests++); _refreshTotal(); }, icon: const Icon(Icons.add_circle_outline)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Optional Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...addons.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var addon = entry.value;
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF102C57),
                    title: Text(addon['name']),
                    subtitle: Text(addon['isPerGuest'] ? 'RM ${addon['price']} × $guests' : 'RM ${addon['price']} flat'),
                    value: addon['selected'],
                    onChanged: (val) { setState(() { addons[idx]['selected'] = val!; _refreshTotal(); }); },
                  );
                }).toList(),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Material(
              elevation: 12, borderRadius: BorderRadius.circular(25), color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('RM${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF102C57), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: _confirmBooking,
                      child: const Text('BOOK NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
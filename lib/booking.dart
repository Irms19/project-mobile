import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/venue.dart';
import 'payment/PaymentPage.dart';

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
  bool isSubmitting = false;
  bool isLoadingDates = false; // New: Prevents UI from freezing during date fetch

  final List<Map<String, dynamic>> addons = [
    {
      'name': 'Catering',
      'price': 30.0,
      'selected': false,
      'isPerGuest': true,
      'icon': Icons.restaurant
    },
    {
      'name': 'Decoration',
      'price': 800.0,
      'selected': false,
      'isPerGuest': false,
      'icon': Icons.celebration
    },
    {
      'name': 'Audio/Visual Equipment',
      'price': 500.0,
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
    setState(() => isLoadingDates = true);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('venueId', isEqualTo: widget.venue.id)
          .where('status', whereIn: ['pending', 'confirmed', 'pending_payment'])
          .get();

      // 1. Create a Set of booked date strings for fast lookup
      Set<String> bookedDatesStrings = snapshot.docs.map((doc) {
        DateTime date = (doc['bookingDate'] as Timestamp).toDate();
        return "${date.year}-${date.month}-${date.day}";
      }).toSet();

      setState(() => isLoadingDates = false);
      if (!mounted) return;

      // 2. CRITICAL FIX: Find the first available date starting from tomorrow
      DateTime firstAvailable = DateTime.now().add(const Duration(days: 1));
      while (bookedDatesStrings.contains("${firstAvailable.year}-${firstAvailable.month}-${firstAvailable.day}")) {
        firstAvailable = firstAvailable.add(const Duration(days: 1));
      }

      // 3. Open the picker with the safe 'firstAvailable' date
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? firstAvailable, // Safe date used here
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        selectableDayPredicate: (DateTime day) {
          String formattedDay = "${day.year}-${day.month}-${day.day}";
          return !bookedDatesStrings.contains(formattedDay);
        },
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF102C57)),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() => selectedDate = picked);
      }
    } catch (e) {
      setState(() => isLoadingDates = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  // --- TRANSACTIONAL SAVE LOGIC (PREVENTS DOUBLE BOOKING) ---
  Future<void> _saveBookingToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedDate == null) return;

    setState(() => isSubmitting = true);

    try {
      // Transactions ensure that if two people click at once, only one succeeds
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existingQuery = await FirebaseFirestore.instance
            .collection('bookings')
            .where('venueId', isEqualTo: widget.venue.id)
            .where('bookingDate', isEqualTo: Timestamp.fromDate(selectedDate!))
            .where('status', whereIn: ['pending', 'confirmed', 'pending_payment'])
            .get();

        if (existingQuery.docs.isNotEmpty) {
          throw Exception("This date was just taken by someone else!");
        }

        DocumentReference newBookingRef = FirebaseFirestore.instance.collection('bookings').doc();

        List<String> selectedAddonNames = addons
            .where((a) => a['selected'] == true)
            .map((a) => a['name'] as String)
            .toList();

        transaction.set(newBookingRef, {
          'userId': user.uid,
          'venueId': widget.venue.id,
          'venueName': widget.venue.name,
          'venueImagePath': widget.venue.imagePath,
          'bookingDate': Timestamp.fromDate(selectedDate!),
          'totalPrice': totalPrice,
          'guests': guests,
          'addons': selectedAddonNames,
          'status': 'pending_payment',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                bookingId: newBookingRef.id,
                amount: totalPrice,
              ),
            ),
          ).then((_) => setState(() => isSubmitting = false));
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF102C57)),
            onPressed: () {
              Navigator.pop(context);
              _saveBookingToFirestore();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
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
                  trailing: isLoadingDates
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(onPressed: () => _pickDate(context), child: const Text('Change')),
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF102C57),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                      ),
                      onPressed: isSubmitting ? null : _confirmBooking,
                      child: isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('BOOK NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
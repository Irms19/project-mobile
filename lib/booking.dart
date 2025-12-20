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

  // Add-ons: 'isPerGuest' determines if we multiply by guest count
  final List<Map<String, dynamic>> addons = [
    {
      'name': 'Catering',
      'price': 30, // RM50 per person
      'selected': false,
      'isPerGuest': true,
      'icon': Icons.restaurant
    },
    {
      'name': 'Decoration',
      'price': 800, // Flat fee
      'selected': false,
      'isPerGuest': false,
      'icon': Icons.celebration
    },
    {
      'name': 'Audio/Visual Equipment',
      'price': 500, // Flat fee
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
      // This removes EVERYTHING except numbers and decimals
      String cleanedPrice = widget.venue.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double venuePrice = double.tryParse(cleanedPrice) ?? 0.0;

      double addonsPrice = 0;
      for (var addon in addons) {
        if (addon['selected'] == true) {
          addonsPrice += addon['isPerGuest']
              ? (addon['price'] * guests)
              : addon['price'];
        }
      }
      return venuePrice + addonsPrice;
    } catch (e) {
      print("Error calculating total: $e");
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

  void _bookVenue() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate!);

    // Show confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Venue: ${widget.venue.name}\n'
            'Date: $formattedDate\n'
            'Guests: $guests\n'
            'Total: RM${totalPrice.toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Edit')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking Successful!')),
              );
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                widget.venue.imagePath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Venue Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.venue.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.venue.info, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(widget.venue.price,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF102C57))),
              ],
            ),
            const Divider(height: 40),

            // Booking Details Section
            const Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Date Selection Card
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Color(0xFF102C57)),
              title: Text(selectedDate == null
                  ? 'Select Booking Date'
                  : DateFormat('EEEE, dd MMM yyyy').format(selectedDate!)),
              trailing: TextButton(
                onPressed: () => _pickDate(context),
                child: const Text('Change'),
              ),
            ),

            // Guest Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people_outline, color: Color(0xFF102C57)),
                    SizedBox(width: 33),
                    Text('Number of Guests', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (guests > 1) {
                          setState(() => guests--);
                          _refreshTotal();
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        setState(() => guests++);
                        _refreshTotal();
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            // Add-ons Section
            const Text('Optional Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...addons.asMap().entries.map((entry) {
              int idx = entry.key;
              var addon = entry.value;
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF102C57),
                secondary: Icon(addon['icon']),
                title: Text(addon['name']),
                subtitle: Text(addon['isPerGuest']
                    ? 'RM ${addon['price']} × $guests guests'
                    : 'RM ${addon['price']} flat fee'),
                value: addon['selected'],
                onChanged: (bool? value) {
                  setState(() {
                    addons[idx]['selected'] = value ?? false;
                    _refreshTotal();
                  });
                },
              );
            }).toList(),

            const SizedBox(height: 30),


            const SizedBox(height: 30),

          ],


        ),


      ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Material(
              // Elevation creates the "levitating" shadow effect
              elevation: 12,
              shadowColor: Colors.black45,
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total Price Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL PRICE',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          'RM${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green
                          ),
                        ),
                      ],
                    ),

                    // Book Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF102C57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0, // Button elevation 0 because the Parent Material handles it
                      ),
                      onPressed: () {
                        // Your booking logic or login dialog trigger
                      },
                      child: const Text(
                        'BOOK NOW',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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
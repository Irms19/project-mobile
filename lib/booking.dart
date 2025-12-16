import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/venue.dart';
import 'login.dart';

class GuestBookingPage extends StatefulWidget {
  final Venue venue;

  const GuestBookingPage({super.key, required this.venue});

  @override
  State<GuestBookingPage> createState() => _GuestBookingPageState();
}

class _GuestBookingPageState extends State<GuestBookingPage> {
  DateTime? selectedDate;

  // Add-ons options
  final List<Map<String, dynamic>> addons = [
    {'name': 'Catering', 'price': 1500, 'selected': false, 'quantity': 1},
    {'name': 'Decoration', 'price': 800, 'selected': false, 'quantity': 1},
    {
      'name': 'Audio/Visual Equipment',
      'price': 500,
      'selected': false,
      'quantity': 1
    },
  ];

  int guests = 1; // number of guests
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    totalPrice = _calculateTotal();
  }

  double _calculateTotal() {
    double venuePrice =
        double.tryParse(widget.venue.price.replaceAll('RM', '')) ?? 0;
    double addonsPrice = 0;
    for (var addon in addons) {
      if (addon['selected'] == true) {
        addonsPrice += addon['price'] * addon['quantity'];
      }
    }
    return venuePrice + addonsPrice;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Booked ${widget.venue.name} on $formattedDate for $guests guest(s)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF102C57),
        title: Text(widget.venue.name),
      ),
      body: SingleChildScrollView(
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
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Venue Name & Info
            Text(widget.venue.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.venue.info),
            const SizedBox(height: 10),
            Text(widget.venue.price,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const Divider(height: 30),

            const Text(
                'YOU ARE REQUIRED TO SIGN IN TO BOOK THIS VENUE',
                style:  TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )
            ),

            // Date Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : 'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102C57),
                  ),
                  onPressed: () => _pickDate(context),
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Number of Guests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Number of Guests:',
                    style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (guests > 1) setState(() => guests--);
                        },
                        icon: const Icon(Icons.remove)),
                    Text(guests.toString(),
                        style: const TextStyle(fontSize: 16)),
                    IconButton(
                        onPressed: () => setState(() => guests++),
                        icon: const Icon(Icons.add)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            // Add-ons
            const Text('Add-ons:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: addons.map((addon) {
                int index = addons.indexOf(addon);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: addon['selected'],
                          onChanged: (value) {
                            setState(() {
                              addons[index]['selected'] = value!;
                              totalPrice = _calculateTotal();
                            });
                          },
                        ),
                        Text(addon['name']),
                      ],
                    ),
                    if (addon['selected'])
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (addon['quantity'] > 1) {
                                setState(() {
                                  addons[index]['quantity']--;
                                  totalPrice = _calculateTotal();
                                });
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${addon['quantity']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                addons[index]['quantity']++;
                                totalPrice = _calculateTotal();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          Text('RM${addon['price'] * addon['quantity']}'),
                        ],
                      )
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price:',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('RM$totalPrice',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ),
            const SizedBox(height: 30),

            // Book Now button
            SizedBox( width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF102C57),
                  padding: const EdgeInsets.symmetric(vertical: 15), ),
                onPressed: _bookVenue,
                child: const Text('Book Now', style: TextStyle(fontSize: 18)
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentPage({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isProcessing = false;
  String selectedMethod = 'card'; // 'card' or 'fpx'
  String? selectedBank;

  final List<String> malaysianBanks = [
    'Maybank2u',
    'CIMB Clicks',
    'Public Bank',
    'RHB Now',
    'Hong Leong Connect',
    'AmBank',
    'Bank Islam'
  ];

  Future<void> _processPayment() async {
    if (selectedMethod == 'fpx' && selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your bank')),
      );
      return;
    }

    setState(() => isProcessing = true);

    // Simulate Payment Gateway delay
    await Future.delayed(const Duration(seconds: 3));

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': 'pending', // Now officially confirmed
        'paymentStatus': 'paid',
        'paymentMethod': selectedMethod,
        'bankName': selectedBank ?? 'N/A',
        'paidAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => isProcessing = false);
        _showSuccess();
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Secure Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF102C57),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AMOUNT HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_person_rounded, size: 50, color: Colors.green),
                  const SizedBox(height: 15),
                  const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    "RM ${widget.amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF102C57)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // --- PAYMENT OPTIONS ---
            _buildMethodCard(
              id: 'card',
              title: "Credit / Debit Card",
              subtitle: "Visa, Mastercard, AMEX",
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildMethodCard(
              id: 'fpx',
              title: "Online Banking (FPX)",
              subtitle: "Maybank2u, CIMB, etc.",
              icon: Icons.account_balance,
            ),

            // --- BANK DROPDOWN (ONLY SHOW IF FPX SELECTED) ---
            if (selectedMethod == 'fpx') ...[
              const SizedBox(height: 20),
              const Text("Choose Your Bank", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBank,
                    isExpanded: true,
                    hint: const Text("Select Bank"),
                    items: malaysianBanks.map((bank) {
                      return DropdownMenuItem(value: bank, child: Text(bank));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedBank = val),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 100), // Space for fixed button
          ],
        ),
      ),
      // --- BOTTOM ACTION BUTTON ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF102C57),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            onPressed: isProcessing ? null : _processPayment,
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("PAY NOW", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({required String id, required String title, required String subtitle, required IconData icon}) {
    bool isSelected = selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF102C57) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF102C57) : Colors.grey, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF102C57) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Payment Successful!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your venue is now officially reserved. You can view it under 'My Bookings'.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("Back to Home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}
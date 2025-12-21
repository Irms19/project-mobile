import 'package:flutter/material.dart';
import 'adminpage.dart';

class ManageHallPage extends StatefulWidget {
  const ManageHallPage({super.key});

  @override
  State<ManageHallPage> createState() => _ManageHallPageState();
}

class _ManageHallPageState extends State<ManageHallPage> {
  final List<Map<String, dynamic>> halls = [
    {
      'name': 'Casandra Hall',
      'location': 'Kuala Lumpur',
      'price': 'RM5000',
      'desc': 'A luxury hall for weddings and big events.',
      'image': 'assets/welcome1.jpg',
    },
    {
      'name': 'Conference Room A',
      'location': 'Kuala Lumpur',
      'price': 'RM1200',
      'desc': 'A luxury hall for weddings and big events.',
      'image': 'assets/welcome2.jpg',
    },
  ];

  // Logic to handle Delete
  void _deleteHall(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hall'),
        content: Text('Delete "${halls[index]['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => halls.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UPDATED EDIT/ADD FORM ---
  void _showHallForm({int? index}) {
    final bool isEditing = index != null;

    final nameController = TextEditingController(text: isEditing ? halls[index]['name'] : '');
    final locationController = TextEditingController(text: isEditing ? (halls[index]['location'] ?? '') : '');
    final priceController = TextEditingController(text: isEditing ? halls[index]['price'].replaceAll('RM', '') : '');
    final descController = TextEditingController(text: isEditing ? (halls[index]['desc'] ?? '') : '');

    showDialog(
      context: context,
      builder: (context) {
        // Using Padding + MediaQuery to handle the keyboard manually since showDialog
        // doesn't support isScrollControlled.
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isEditing ? 'Edit Hall' : 'Add Hall',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF102C57)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Hall Name'),
                  _buildTextField(nameController, 'Enter hall name'),
                  _buildLabel('Location'),
                  _buildTextField(locationController, 'Enter location'),
                  _buildLabel('Price'),
                  _buildTextField(priceController, 'Enter price', isNumber: true),
                  _buildLabel('Desc'),
                  _buildTextField(descController, 'Enter description', isLongText: true),
                  const SizedBox(height: 20),

                  // Update Hall Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF102C57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          setState(() {
                            final newData = {
                              'name': nameController.text,
                              'location': locationController.text,
                              'price': 'RM${priceController.text}',
                              'desc': descController.text,
                              'image': isEditing ? halls[index]['image'] : 'assets/welcome1.jpg',
                            };
                            if (isEditing) halls[index] = newData; else halls.add(newData);
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(isEditing ? 'Update Hall' : 'Add Hall', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // Helper for Input Fields
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, bool isLongText = false}) {
    return TextField(
      controller: controller,
      maxLines: isLongText ? 3 : 1,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Halls'),
        backgroundColor: const Color(0xFF102C57),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF102C57),
        onPressed: () => _showHallForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: halls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Increased ratio (0.8) makes the card shorter so there's no empty gap
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final hall = halls[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.zero, // Remove extra margin
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image - Occupies fixed percentage of card
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        hall['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spreads content evenly
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hall['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hall['location'] ?? 'No Location',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Price and Action Buttons at the bottom
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                hall['price'],
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => _showHallForm(index: index),
                                    child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () => _deleteHall(index),
                                    child: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage())),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 55,
          decoration: BoxDecoration(color: const Color(0xFF102C57), borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.home, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
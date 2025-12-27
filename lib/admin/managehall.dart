import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageHallPage extends StatefulWidget {
  const ManageHallPage({super.key});

  @override
  State<ManageHallPage> createState() => _ManageHallPageState();
}

class _ManageHallPageState extends State<ManageHallPage> {
  final ImagePicker _picker = ImagePicker();
  final Color primaryNavy = const Color(0xFF102C57);
  final Color accentGold = const Color(0xFFE1AA74);

  final List<String> _venueTypes = ['CONFERENCE ROOM', 'EVENT HALL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Manage Halls & Room',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1.2)),
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('venues').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading venues"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No venues found. Click + to add one."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final id = snapshot.data!.docs[index].id;
              return _buildHallCard(data, id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVenueForm(),
        backgroundColor: primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NEW HALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHallCard(Map<String, dynamic> data, String id) {
    final String imgPath = data['imagePath']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: _displayImage(imgPath, 180),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(20)),
                  child: Text(data['price'] ?? 'RM 0',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['type'] ?? 'VENUE',
                    style: TextStyle(color: accentGold, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(data['name'] ?? 'Unnamed Venue',
                    style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 8),
                Text(data['info'] ?? 'No description provided.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                const SizedBox(height: 15),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _iconBtn(Icons.edit_note, Colors.blue, () => _showVenueForm(docId: id, existingData: data)),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.delete_sweep, Colors.red, () => _confirmDelete(id)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showVenueForm({String? docId, Map<String, dynamic>? existingData}) {
    final nameCtrl = TextEditingController(text: existingData?['name'] ?? '');
    final priceCtrl = TextEditingController(text: existingData?['price']?.toString().replaceAll('RM', '').trim() ?? '');
    final infoCtrl = TextEditingController(text: existingData?['info'] ?? '');
    String selectedType = existingData?['type'] ?? _venueTypes[0];
    String currentPath = existingData?['imagePath'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text(docId == null ? "Add Venue" : "Edit Venue", style: TextStyle(color: primaryNavy, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),

                // DROPDOWN
                const Text("Venue Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: _venueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setModalState(() => selectedType = val!),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                _formField(nameCtrl, "Venue Name", Icons.business),
                _formField(priceCtrl, "Price (RM)", Icons.payments, isNumeric: true),
                _formField(infoCtrl, "Description", Icons.info_outline, maxLines: 3),

                const SizedBox(height: 15),
                if (currentPath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(borderRadius: BorderRadius.circular(15), child: _displayImage(currentPath, 120)),
                  ),

                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) setModalState(() => currentPath = picked.path);
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Select Cover Photo"),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),

                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                    final payload = {
                      'name': nameCtrl.text,
                      'type': selectedType,
                      'price': 'RM ${priceCtrl.text}',
                      'info': infoCtrl.text,
                      'imagePath': currentPath,
                    };
                    docId == null
                        ? await FirebaseFirestore.instance.collection('venues').add(payload)
                        : await FirebaseFirestore.instance.collection('venues').doc(docId).update(payload);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {bool isNumeric = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
      ),
    );
  }

  Widget _displayImage(String path, double h) {
    if (path.isEmpty) return _fallbackImg(h);
    try {
      if (path.startsWith('assets/')) return Image.asset(path, height: h, width: double.infinity, fit: BoxFit.cover);
      File file = File(path);
      if (file.existsSync()) return Image.file(file, height: h, width: double.infinity, fit: BoxFit.cover);
    } catch (_) {}
    return _fallbackImg(h);
  }

  Widget _fallbackImg(double h) => Container(height: h, width: double.infinity, color: Colors.grey[200], child: const Icon(Icons.image, size: 40, color: Colors.grey));

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Venue?"),
        content: const Text("Are you sure you want to remove this hall from the system?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () {
            FirebaseFirestore.instance.collection('venues').doc(id).delete();
            Navigator.pop(context);
          }, child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
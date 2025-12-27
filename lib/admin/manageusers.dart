import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminpage.dart'; // Ensure this matches your AdminDashboardPage file name

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color primaryColor = const Color(0xFF102C57);
  String searchQuery = "";

  // --- EDIT USER DIALOG ---
  void _editUser(String docId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['username'] ?? '');

    // --- CHANGE 1: Use a controller for Email to show it clearly ---
    final emailController = TextEditingController(text: userData['email'] ?? '');

    String rawRole = (userData['role'] ?? 'user').toString().toLowerCase();
    String selectedRole = (rawRole == 'admin' || rawRole == 'user') ? rawRole : 'user';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 25),

                      // 1. USERNAME
                      _buildEditField(nameController, 'Username'),
                      const SizedBox(height: 15),

                      // 2. EMAIL (The Fix)
                      TextField(
                        controller: emailController,
                        readOnly: true, // User can't type, but can see/copy the text
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100], // Soft grey background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          // This ensures the text inside is dark and readable
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 15),

                      // 3. ROLE (Dropdown)
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: TextStyle(color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('Customer')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() => selectedRole = newValue);
                          }
                        },
                      ),
                      const SizedBox(height: 25),

                      // UPDATE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('users').doc(docId).update({
                              'username': nameController.text.trim(),
                              'role': selectedRole,
                            });
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text('Update User', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('MANAGE USERS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- USER LIST (REAL-TIME STREAM) ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No users found."));
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    String name = (doc['username'] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var userData = filteredDocs[index].data() as Map<String, dynamic>;
                      String docId = filteredDocs[index].id;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[200],
                                  child: Text(
                                    userData['username']?[0].toUpperCase() ?? "U",
                                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userData['username'] ?? "No Name",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(userData['email'] ?? "No Email",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    Text(
                                      "Role: ${userData['role'] ?? 'user'}",
                                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () => _editUser(docId, userData),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
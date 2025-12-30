import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color primaryColor = const Color(0xFF102C57);
  String searchQuery = "";

  // --- DELETE USER LOGIC ---
  void _confirmDelete(String docId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Account",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text("Are you sure you want to permanently delete $username's account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User '$username' deleted successfully")),
                  );
                }
              } catch (e) {
                debugPrint("Delete Error: $e");
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- EDIT USER DIALOG ---
  void _editUser(String docId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['username'] ?? '');
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
                      _buildEditField(nameController, 'Username'),
                      const SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 15),
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back', style: TextStyle(color: Colors.grey))),
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
            // Search Bar
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
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
            // User List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No users found."));

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    String name = (doc['username'] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var userData = filteredDocs[index].data() as Map<String, dynamic>;
                      String docId = filteredDocs[index].id;
                      String username = userData['username'] ?? "No Name";

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Text(username[0].toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(userData['email'] ?? "No Email", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    Text("Role: ${userData['role'] ?? 'user'}", style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              // ACTION BUTTONS
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: primaryColor, size: 22),
                                    onPressed: () => _editUser(docId, userData),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                    onPressed: () => _confirmDelete(docId, username),
                                  ),
                                ],
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
          child: Container(
            height: 55,
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.home, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
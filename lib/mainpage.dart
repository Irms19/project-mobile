import 'package:bookinghall/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'floating_nav_bar.dart';
import 'models/venue.dart';
import 'MyBookingsPage.dart';
import 'booking.dart';
import 'models/animated_toggle.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  String searchText = '';

  final List<String> welcomeImages = const [
    'assets/welcome1.jpg',
    'assets/welcome2.jpg',
    'assets/welcome3.jpg',
  ];

  final List<String> welcomeTexts = const [
    'Welcome to Our Venue!',
    'Book Your Event Today!',
    'Experience the Best Service!',
  ];

  @override
  Widget build(BuildContext context) {
    String selectedType = selectedIndex == 0 ? 'EVENT HALL' : 'CONFERENCE ROOM';

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Premium off-white background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),

                // --- 1. CAROUSEL SECTION ---
                CarouselSlider.builder(
                  itemCount: welcomeImages.length,
                  itemBuilder: (context, index, realIndex) => _buildCarouselItem(index),
                  options: CarouselOptions(
                    height: 160,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.88,
                  ),
                ),

                // --- 2. SEARCH BAR SECTION ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchText = value),
                      decoration: InputDecoration(
                        hintText: 'Search for a perfect venue...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF102C57)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 3. TOGGLE SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: AnimatedToggle(
                    labels: const ['EVENT HALLS', 'CONFERENCE'],
                    initialIndex: 0,
                    onToggle: (index) => setState(() => selectedIndex = index),
                  ),
                ),

                // --- 4. DYNAMIC LIST SECTION ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('venues')
                        .where('type', isEqualTo: selectedType)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error loading venues"));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF102C57)));
                      }

                      final filteredVenues = snapshot.data!.docs
                          .map((doc) => Venue.fromFirestore(doc))
                          .where((venue) => venue.name.toLowerCase().contains(searchText.toLowerCase()))
                          .toList();

                      if (filteredVenues.isEmpty) {
                        return const Center(child: Text("No venues available."));
                      }

                      return ListView.builder(
                        itemCount: filteredVenues.length,
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
                        itemBuilder: (context, index) => _VenueCard(venue: filteredVenues[index]),
                      );
                    },
                  ),
                ),
              ],
            ),

            // --- 5. FLOATING NAVIGATION BAR ---
            Positioned(
              left: 0, right: 0, bottom: 10,
              child: FloatingNavBar(
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsPage()));
                  if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Carousel Item Design ---
  Widget _buildCarouselItem(int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(welcomeImages[index]),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomLeft,
        child: Text(
          welcomeTexts[index],
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --- MODERN VENUE CARD WIDGET ---
class _VenueCard extends StatelessWidget {
  final Venue venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(venue: venue)));
        },
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            // Image with Price Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: _buildImage(venue.imagePath),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      venue.price,
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Venue Details Row
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF102C57)
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venue.info,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF102C57),
                    child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return Container(color: Colors.grey, height: 160, child: const Icon(Icons.image_not_supported));
    }

    if (path.startsWith('http')) {
      // For images uploaded to Firebase/Web
      return Image.network(
        path,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else if (path.startsWith('/') || path.startsWith('content://') || path.contains('com.google')) {
      // For images from Image Picker (File Path)
      // The File() class requires 'import 'dart:io';'
      return Image.file(
        File(path),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      // For local assets (welcome images)
      return Image.asset(
        path,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
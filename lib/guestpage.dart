import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'floating_nav_bar.dart';
import 'models/venue.dart';
import 'guestbookingpage.dart';
import 'ProfileGuest.dart';
import 'SavedPageGuest.dart';
import 'login.dart';
import 'models/animated_toggle.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  int selectedIndex = 0;
  String searchText = '';

  final List<String> welcomeImages = const [
    'assets/welcome1.jpg',
    'assets/welcome2.jpg',
    'assets/welcome3.jpg'
  ];

  final List<String> welcomeTexts = const [
    'Welcome to Our Site!',
    'Book Your Event Today!',
    'The Best Service!'
  ];

  @override
  Widget build(BuildContext context) {
    // Determine the type string to filter by based on toggle
    String selectedType = selectedIndex == 0 ? 'EVENT HALL' : 'CONFERENCE ROOM';

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 15),
                // --- SIGN IN WARNING ---
                _buildSignInWarning(),

                const SizedBox(height: 15),
                // --- PREMIUM CAROUSEL ---
                _buildCarousel(),

                // --- MODERN SEARCH ---
                _buildSearchBar(),

                // --- TOGGLE ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: AnimatedToggle(
                    labels: const ['EVENT HALLS', 'CONFERENCE'],
                    initialIndex: 0,
                    onToggle: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),

                // --- FIREBASE VENUE LIST ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('venues').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading data"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Convert Firestore docs to Venue objects and filter locally
                      final docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toString().toLowerCase();
                        final type = (data['type'] ?? '').toString();

                        return type == selectedType && name.contains(searchText.toLowerCase());
                      }).toList();

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("No venues found in this category."),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;

                          // Creating Venue object from Firebase data
                          final venue = Venue(
                            name: data['name'] ?? 'No Name',
                            imagePath: data['imagePath'] ?? 'assets/welcome1.jpg',
                            info: data['info'] ?? 'No description available',
                            price: data['price'] ?? '0',
                            type: data['type'] ?? '',
                          );

                          return _GuestVenueCard(venue: venue);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // --- NAVIGATION ---
            Positioned(
              left: 0, right: 0, bottom: 10,
              child: FloatingNavBar(
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPageGuest()));
                  }
                  if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileGuest()));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildSignInWarning() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'YOU ARE REQUIRED TO ',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
        children: [
          TextSpan(
            text: 'SIGN IN',
            style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // FIXED: Use pushReplacement to clean up the stack
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage())
                );
              },
          ),
          const TextSpan(text: ' TO BOOK A VENUE'),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider.builder(
      itemCount: welcomeImages.length,
      itemBuilder: (context, index, realIndex) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              image: AssetImage(welcomeImages[index]),
              fit: BoxFit.cover
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent]
            ),
          ),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.bottomLeft,
          child: Text(
              welcomeTexts[index],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      ),
      options: CarouselOptions(
          height: 150,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (v) => setState(() => searchText = v),
        decoration: InputDecoration(
          hintText: 'Search venues...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF102C57)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }
}

// --- MODERN CARD FOR GUESTS ---
class _GuestVenueCard extends StatelessWidget {
  final Venue venue;
  const _GuestVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GuestBookingPage(venue: venue))
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                  venue.imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover
              ),
            ),
            ListTile(
              title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(venue.info, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(
                  venue.price,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
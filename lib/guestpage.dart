import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'floating_nav_bar.dart';
import 'models/venue.dart';
import 'guestbookingpage.dart';
import 'ProfileGuest.dart';
import 'SavedPageGuest.dart';
import 'models/animated_toggle.dart';
import 'package:flutter/gestures.dart';


class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  // Toggle state
  List<bool> isSelected = [true, false];

  // Search text
  String searchText = '';

  // Example venues
  final List<Venue> venues = [
    Venue(
      imagePath: 'assets/welcome1.jpg',
      name: 'Grand Ballroom',
      info: 'Spacious hall for weddings and events',
      price: 'RM5000',
      type: 'EVENT HALL',
    ),
    Venue(
      imagePath: 'assets/welcome2.jpg',
      name: 'Conference Room A',
      info: 'Perfect for business meetings',
      price: 'RM1200',
      type: 'CONFERENCE ROOM',
    ),
    Venue(
      imagePath: 'assets/welcome3.jpg',
      name: 'Outdoor Garden',
      info: 'Beautiful setting for outdoor events',
      price: 'RM3000',
      type: 'EVENT HALL',
    ),
    Venue(
      imagePath: 'assets/welcome1.jpg',
      name: 'Meeting Room B',
      info: 'Small conference room for team meetings',
      price: 'RM1000',
      type: 'CONFERENCE ROOM',
    ),
  ];

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
    // Filter venues based on toggle & search text
    String selectedType = isSelected[0] ? 'EVENT HALL' : 'CONFERENCE ROOM';
    List<Venue> filteredVenues = venues
        .where((venue) =>
    venue.type == selectedType &&
        venue.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'YOU ARE REQUIRED \n TO ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    children: [
                      TextSpan(
                        text: 'SIGN IN',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // clickable text color
                          decoration: TextDecoration.underline, // optional
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle click here, e.g., navigate to login page
                            print('SIGN IN clicked');
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
                          },
                      ),
                      TextSpan(
                        text: ' TO BOOK',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Carousel
                CarouselSlider.builder(
                  itemCount: welcomeImages.length,
                  itemBuilder: (context, index, realIndex) {
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(welcomeImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color: Colors.black.withOpacity(0.5),
                            child: Text(
                              welcomeTexts[index],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 190,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                  ),
                ),
                const SizedBox(height: 20),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedToggle(
                    labels: const ['EVENT HALLS', 'CONFERENCE ROOM'],
                    initialIndex: 0,
                    onToggle: (index) {
                      setState(() {
                        isSelected[0] = index == 0;
                        isSelected[1] = index == 1;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Venue list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredVenues.length,
                    itemBuilder: (context, index) {
                      final venue = filteredVenues[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GuestBookingPage(venue: venue),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          elevation: 15,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                venue.imagePath,
                                width: 100,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              venue.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(venue.info),
                            trailing: Text(
                              venue.price,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80), // Space for floating nav bar
              ],
            ),

            // Floating nav bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: FloatingNavBar(
                currentIndex: 1,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SavedPageGuest()),
                      );
                      break;
                    case 2:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileGuest()),
                      );
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

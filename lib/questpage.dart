
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'floating_nav_bar.dart';
import 'models/venue.dart';

class GuestPage extends StatelessWidget {
  GuestPage({super.key});

  // Example venue list; later, update this from admin page or backend
  final List<Venue> venues = [
    Venue(
      imagePath: 'assets/welcome1.jpg',
      name: 'Grand Ballroom',
      info: 'Spacious hall for weddings and events',
      price: 'RM5000',
    ),
    Venue(
      imagePath: 'assets/welcome2.jpg',
      name: 'Conference Room A',
      info: 'Perfect for business meetings',
      price: 'RM1200',
    ),
    Venue(
      imagePath: 'assets/welcome3.jpg',
      name: 'Outdoor Garden',
      info: 'Beautiful setting for outdoor events',
      price: 'RM3000',
    ),
    Venue(
      imagePath: 'assets/welcome3.jpg',
      name: 'Outdoor Garden',
      info: 'Beautiful setting for outdoor events',
      price: 'RM3000',
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
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
                    height: 230,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(20),
                    isSelected: [true, false],
                    onPressed: (index) {},
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('EVENT HALLS'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('CONFERENCE ROOM'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: venues.length,
                    itemBuilder: (context, index) {
                      final venue = venues[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80), // Space for floating nav bar
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: FloatingNavBar(
                currentIndex: 1,
                onTap: (index) {
                  // handle navigation
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
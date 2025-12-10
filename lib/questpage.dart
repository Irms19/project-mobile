import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';



class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  // List of images for the carousel
  final List<String> welcomeImages = const [
    'assets/welcome1.jpg',
    'assets/welcome2.jpg',
    'assets/welcome3.jpg',
  ];

  // Corresponding overlay texts
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

        child: Column(
          children: [
            // Carousel for Welcome Images
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
                    // Text overlay
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
                height: 150,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
            ),

            const SizedBox(height: 10),

            // Search Bar
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

            const SizedBox(height: 10),

            // Toggle buttons for Event Halls / Conference Room
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

            // List of halls / rooms
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3, // Example number of items
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
                      title: const Text('NAME: BLABLABLABLA'),
                      subtitle: const Text('INFO DESC: BLALBALBALBAL'),
                      trailing: const Text('PRICE: RMXXXXX'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

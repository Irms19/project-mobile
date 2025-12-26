import 'package:cloud_firestore/cloud_firestore.dart';

class Venue {
  final String? id; // Added ID for Firestore
  final String imagePath;
  final String name;
  final String info;
  final String price;
  final String type;

  Venue({
    this.id,
    required this.imagePath,
    required this.name,
    required this.info,
    required this.price,
    required this.type,
  });

  // Convert Firestore Document to Venue object
  factory Venue.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Venue(
      id: doc.id,
      imagePath: data['imagePath'] ?? 'assets/welcome1.jpg',
      name: data['name'] ?? '',
      info: data['info'] ?? '',
      price: data['price'] ?? 'RM0',
      type: data['type'] ?? 'EVENT HALL',
    );
  }
}
class Venue {
  final String imagePath;
  final String name;
  final String info;
  final String price;
  final String type; // NEW: type of venue

  Venue({
    required this.imagePath,
    required this.name,
    required this.info,
    required this.price,
    required this.type,
  });
}

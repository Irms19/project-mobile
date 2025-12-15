import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const FloatingNavBar({
    Key? key,
    this.currentIndex = 1,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF102C57),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.bookmark,
                  color: currentIndex == 0 ? Colors.grey : Colors.white),
              onPressed: () => onTap?.call(0),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.home,
                  color: currentIndex == 1 ? Colors.grey : Colors.white),
              onPressed: () => onTap?.call(1),
            ),
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.person,
                  color: currentIndex == 2 ? Colors.grey : Colors.white),
              onPressed: () => onTap?.call(2),
            ),
          ],
        ),
      ),
    );
  }
}
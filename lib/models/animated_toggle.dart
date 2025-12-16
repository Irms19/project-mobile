import 'package:flutter/material.dart';

class AnimatedToggle extends StatefulWidget {
  final List<String> labels;
  final Function(int) onToggle;
  final int initialIndex;

  const AnimatedToggle({
    super.key,
    required this.labels,
    required this.onToggle,
    this.initialIndex = 0,
  });

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Sliding background
          AnimatedAlign(
            alignment:
            selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 40, // adjust width
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF102C57),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.labels.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      widget.onToggle(index);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.labels[index],
                      style: TextStyle(
                        color: selectedIndex == index ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

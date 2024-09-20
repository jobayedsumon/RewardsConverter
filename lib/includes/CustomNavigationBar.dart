import 'package:flutter/material.dart';

class CookieNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onScreenChange;

  const CookieNavigationBar(
      {Key? key, required this.selectedIndex, required this.onScreenChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.red[900],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home", tooltip: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.store), label: "Store", tooltip: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History", tooltip: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profile", tooltip: ""),
          ],
          currentIndex: selectedIndex,
          onTap: onScreenChange,
        ),
      ),
    );
  }
}

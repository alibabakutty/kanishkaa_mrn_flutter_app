import 'package:flutter/material.dart';
import 'package:mobile_app/features/screens/home_dashboard.dart';
import 'package:mobile_app/features/screens/mrn_dashboard.dart';
import 'package:mobile_app/features/screens/profile_screen.dart';

class BottomThree extends StatefulWidget {
  const BottomThree({super.key});

  @override
  State<BottomThree> createState() => _BottomThreeState();
}

class _BottomThreeState extends State<BottomThree> {
  int selectedIndex = 0;

  List<Widget> screens = [HomeDashboard(), MrnDashboard(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0C685B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
            setState(() {
              selectedIndex = index;
            });

        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_outlined),
            activeIcon: Icon(Icons.shopping_cart_checkout),
            label: 'MRN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Site Engg.',
          ),
        ],
      ),
    );
  }
}

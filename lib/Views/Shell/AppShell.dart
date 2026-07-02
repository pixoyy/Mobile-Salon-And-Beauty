import 'package:flutter/material.dart';
import 'package:salon_and_beauty/Views/Booking/BookingMenuPage.dart';
import 'package:salon_and_beauty/Views/Dashboard/DashboardPage.dart';
import 'package:salon_and_beauty/Views/Service/ServiceListPage.dart';
import 'package:salon_and_beauty/Views/Stylist/StylistListPage.dart';
import 'package:salon_and_beauty/Views/User/UserMenuPage.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  int _bookingTabVersion = 0;
  // int _historyTabVersion = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const DashboardPage(),
      const StylistListPage(),
      const ServiceListPage(),
      BookingMenuPage(key: ValueKey<int>(_bookingTabVersion)),
      const UserMenuPage(),
      // BookingMenuPage(key: ValueKey<int>(_bookingTabVersion)),
      // HistoryPage(key: ValueKey<int>(_historyTabVersion)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 3) {
              _bookingTabVersion++;
            }
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Stylist'),
          NavigationDestination(icon: Icon(Icons.content_cut_outlined), selectedIcon: Icon(Icons.content_cut), label: 'Layanan'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

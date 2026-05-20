import 'package:flutter/material.dart';

import '../../booking/presentation/booking_menu_page.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../service/presentation/service_list_page.dart';
import '../../stylist/presentation/stylist_list_page.dart';
import '../../booking/presentation/history_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  int _bookingTabVersion = 0;
  int _historyTabVersion = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const DashboardPage(),
      const StylistListPage(),
      const ServiceListPage(),
      BookingMenuPage(key: ValueKey<int>(_bookingTabVersion)),
      HistoryPage(key: ValueKey<int>(_historyTabVersion)),
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
            if (index == 3) {
              _bookingTabVersion += 1;
            }
            if (index == 4) {
              _historyTabVersion += 1;
            }
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Stylist'),
          NavigationDestination(icon: Icon(Icons.content_cut_outlined), selectedIcon: Icon(Icons.content_cut), label: 'Layanan'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'pages/timetable_page.dart';
import 'pages/links_page.dart';
import 'pages/misc_page.dart';

@immutable
class _NavigationItem {
  final NavigationDestination destination;
  final Widget page;

  const _NavigationItem({required this.destination, required this.page});
}

const List<_NavigationItem> _items = [
  _NavigationItem(
    destination: NavigationDestination(
      icon: Icon(Icons.calendar_month),
      label: '時間割',
    ),
    page: TimetablePage(),
  ),
  _NavigationItem(
    destination: NavigationDestination(
      icon: Icon(Icons.language),
      label: 'リンク',
    ),
    page: LinksPage(),
  ),
  _NavigationItem(
    destination: NavigationDestination(
      icon: Icon(Icons.more_horiz),
      label: 'その他',
    ),
    page: MiscPage(),
  ),
];

@immutable
class TUTilityNavigation extends StatefulWidget {
  const TUTilityNavigation({Key? key}) : super(key: key);

  @override
  State<TUTilityNavigation> createState() => _TUTilityNavigationState();
}

class _TUTilityNavigationState extends State<TUTilityNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _items[_selectedIndex].page,
      bottomNavigationBar: NavigationBar(
        destinations: _items.map((e) => e.destination).toList(),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
      ),
    );
  }
}

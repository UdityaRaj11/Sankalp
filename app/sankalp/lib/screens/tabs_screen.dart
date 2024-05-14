import 'package:flutter/material.dart';
import 'package:sankalp/screens/note_screen.dart';
import 'package:sankalp/screens/patients_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages = [];
  @override
  void initState() {
    _pages = const [
      {'page': PatientsScreen(), 'title': 'Node'},
      {'page': PatientsScreen(), 'title': 'Node'},
      {'page': PatientsScreen(), 'title': 'Node'},
      {'page': PatientsScreen(), 'title': 'Node'},
    ];
    super.initState();
  }

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sankalp',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 27, 46, 27),
      ),
      body: _pages[_selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: const Color.fromARGB(255, 27, 46, 27),
        unselectedItemColor: const Color.fromARGB(255, 112, 126, 112),
        selectedItemColor: const Color.fromARGB(255, 251, 251, 251),
        selectedFontSize: 10,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.chat),
            label: '',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}

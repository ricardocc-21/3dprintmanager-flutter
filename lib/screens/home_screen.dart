import 'package:flutter/material.dart';

import 'filamentos_screen.dart';
import 'impresiones_screen.dart';
import 'impresoras_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ImpresorasScreen(),
    const ImpresionesScreen(),
    const FilamentosScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Print Manager"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.print), label: "Impresoras"),
          BottomNavigationBarItem(icon: Icon(Icons.print), label: "Impresiones"),
          BottomNavigationBarItem(icon: Icon(Icons.print), label: "Filamentos"),
        ],
      ),
    );
  }
}

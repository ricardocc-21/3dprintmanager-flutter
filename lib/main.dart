import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:print_manager/core/app_colors.dart';
import 'package:print_manager/screens/filamentos_screen.dart';
import 'package:print_manager/screens/impresiones_screen.dart';
import 'package:print_manager/screens/impresoras_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
    return MaterialApp(
      title: '3D Print Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundComponent,
          foregroundColor: Colors.white,
          title: Text(
            "3D Print Manager",
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: AppColors.background,
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppColors.backgroundComponent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.print),
              label: "Impresoras",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.print),
              label: "Impresiones",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.print),
              label: "Filamentos",
            ),
          ],
        ),
      ),
    );
  }
}

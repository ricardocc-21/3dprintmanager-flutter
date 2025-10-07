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
        // Colores principales
        primaryColor: AppColors.primary, // color principal de la app
        scaffoldBackgroundColor: AppColors.background, // fondo general
        cardColor: AppColors.backgroundCard, // fondos de tarjetas
        canvasColor: AppColors.background, // fondos de drawer, bottomSheet, etc.

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white, // color del título y iconos
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        // Texto
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),

        // Otros colores de acento
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondary,
          error: AppColors.error,
          brightness: Brightness.light
        ),
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
          // backgroundColor: AppColors.backgroundComponent,
          // foregroundColor: AppColors.foregroundColor,
          title: Text(
            "3D Print Manager",
            style: TextStyle(
              // color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // backgroundColor: AppColors.backgroundComponent,
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // backgroundColor: AppColors.backgroundComponent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondary,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/3d_print.png',
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset(
                'assets/icons/3d_print.png',
                width: 36,
                height: 36,
                color: Colors.blue,
              ),
              label: "Impresoras",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/impresion.png',
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset(
                'assets/icons/impresion.png',
                width: 36,
                height: 36,
                color: Colors.blue,
              ),
              label: "Impresiones",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/filament_spool.png',
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset(
                'assets/icons/filament_spool.png',
                width: 36,
                height: 36,
                color: Colors.blue,
              ),
              label: "Filamentos",
            ),
          ],
        ),
      ),
    );
  }
}

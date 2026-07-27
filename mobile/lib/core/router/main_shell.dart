import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

/// Shell dengan [BottomNavigationBar] untuk 4 tab utama (Beranda, Jadwal,
/// Warta, Profil). Fitur lain (Formulir, Donasi, Direktori, dst) diakses
/// sebagai halaman terpisah dari shortcut di Beranda, bukan lewat bottom
/// nav, sesuai spesifikasi menu.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Jadwal',
    ),
    (
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      label: 'Warta',
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

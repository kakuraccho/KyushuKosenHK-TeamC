import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/view/view_screen.dart';
import 'screens/shoot_screen.dart';
import 'screens/sns_screen.dart';
import 'widgets/navigation/main_navigation.dart';
import 'widgets/navigation/sub_menu_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Lapse',
      theme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _viewSubTab = 0; // 0=Pomodoro, 1=Videos
  bool _showSubMenu = false;

  void _onNavTap(int index) {
    setState(() {
      if (index == 0 && _currentIndex == 0) {
        // Already on View → toggle the sub-menu
        _showSubMenu = !_showSubMenu;
      } else {
        _currentIndex = index;
        _showSubMenu = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Main content area
          IndexedStack(
            index: _currentIndex,
            children: [
              ViewScreen(subTab: _viewSubTab),
              const ShootScreen(),
              const SnsScreen(),
            ],
          ),
          // Pomodoro / Videos overlay (slides up above BottomBar)
          Positioned(
            bottom: 8,
            left: 14,
            right: 14,
            child: ClipRect(
              child: AnimatedAlign(
                heightFactor: _showSubMenu ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  ignoring: !_showSubMenu,
                  child: SubMenuOverlay(
                    selectedTab: _viewSubTab,
                    onTabSelected: (tab) => setState(() {
                      _viewSubTab = tab;
                      _showSubMenu = false;
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

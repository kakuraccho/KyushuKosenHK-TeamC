import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/view/view_screen.dart';
import 'screens/shoot_screen.dart';
import 'screens/sns_screen.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/navigation/main_navigation.dart';
import 'widgets/navigation/sub_menu_overlay.dart';
import 'core/supabase/supabase_client.dart';
import 'features/shoot/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeSupabase();
  await NotificationService.init();
  debugPrint('supabase connected ${supabase.auth.currentSession}');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Lapse',
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
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
      if (index == 0) {
        _showSubMenu = !_showSubMenu;
      } else {
        _currentIndex = index;
        _showSubMenu = false;
      }
    });
  }

  void _dismissOverlay() {
    setState(() => _showSubMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              ViewScreen(subTab: _viewSubTab),
              const ShootScreen(),
              const SnsScreen(),
            ],
          ),
          if (_showSubMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissOverlay,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 14,
            child: ClipRect(
              child: AnimatedAlign(
                heightFactor: _showSubMenu ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  ignoring: !_showSubMenu,
                  child: SubMenuOverlay(
                    selectedTab: _currentIndex == 0 ? _viewSubTab : -1,
                    onTabSelected: (tab) => setState(() {
                      _viewSubTab = tab;
                      _currentIndex = 0;
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

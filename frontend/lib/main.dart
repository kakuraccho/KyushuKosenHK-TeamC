import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_colors.dart';
import 'core/camera/camera_cache.dart';
import 'core/supabase/supabase_client.dart';
import 'theme/app_theme.dart';
import 'screens/view/view_screen.dart';
import 'screens/shoot_screen.dart';
import 'screens/sns_screen.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/navigation/main_navigation.dart';
import 'widgets/navigation/sub_menu_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // warm-up frame が旧ウィジェットツリーを描画する前にローディング画面に差し替える
  runApp(const _SplashApp());

  await dotenv.load(fileName: '.env');

  // Supabase 初期化とカメラリスト取得を並列で実行
  String? initError;
  await Future.wait([
    initializeSupabase().then((_) {
      debugPrint('supabase connected: ${supabase.auth.currentSession}');
    }).catchError((e, st) {
      initError = e.toString();
      debugPrint('Supabase init failed: $e\n$st');
    }),
    availableCameras().then((cameras) {
      cachedCameras = cameras;
      debugPrint('cameras cached: ${cameras.length}');
    }).catchError((e) {
      debugPrint('Camera list failed: $e');
    }),
  ]);

  runApp(ProviderScope(child: MyApp(initError: initError)));
}

class _SplashApp extends StatelessWidget {
  const _SplashApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final String? initError;
  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Lapse',
      theme: AppTheme.dark,
      home: initError != null
          ? Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Supabase 初期化エラー:\n$initError',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          : const AuthGate(),
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
        // View タップ: 現在のタブに関わらずサブメニューをトグル
        // 他タブからでもオーバーレイで選択してから遷移させる
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
          IndexedStack(
            index: _currentIndex,
            children: [
              ViewScreen(subTab: _viewSubTab),
              ShootScreen(isActive: _currentIndex == 1),
              const SnsScreen(),
            ],
          ),
          // オーバーレイ表示中は背面タップで閉じる
          if (_showSubMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showSubMenu = false),
                behavior: HitTestBehavior.translucent,
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
                alignment: Alignment.bottomLeft,
                child: IgnorePointer(
                  ignoring: !_showSubMenu,
                  child: SubMenuOverlay(
                    selectedTab: _viewSubTab,
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

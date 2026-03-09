import 'package:flutter/material.dart';
import 'dart:math';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF16213E),
          selectedItemColor: Color(0xFF4FC3F7),
          unselectedItemColor: Color(0xFF8D8D8D),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// =============================================================================
// MainScreen - BottomNavigationBar with 3 tabs
// =============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ViewScreen(),
    ShootScreen(),
    SnsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF16213E),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A4A), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF16213E),
          selectedItemColor: const Color(0xFF4FC3F7),
          unselectedItemColor: const Color(0xFF8D8D8D),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.visibility_outlined),
              activeIcon: Icon(Icons.visibility),
              label: 'View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: 'Shoot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'SNS',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ViewScreen - Contains Pomodoro and Videos sub-tabs
// =============================================================================
class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App title
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Focus Lapse',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF8D8D8D),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Pomodoro'),
                Tab(text: 'Videos'),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PomodoroView(),
                VideosView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PomodoroView - Circular timer with controls
// =============================================================================
class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  int _remainingSeconds = 25 * 60; // 25 minutes
  bool _isRunning = false;
  int _totalSeconds = 25 * 60;

  String get _timeString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    return _remainingSeconds / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Circular Timer
            SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: TimerPainter(
                  progress: _progress,
                  backgroundColor: const Color(0xFF2A2A4A),
                  progressColor: const Color(0xFF4FC3F7),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _timeString,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'FOCUS' : 'READY',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8D8D8D),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Start / Stop button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRunning = !_isRunning;
                });
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRunning
                      ? const Color(0xFFE57373)
                      : const Color(0xFF4FC3F7),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRunning
                              ? const Color(0xFFE57373)
                              : const Color(0xFF4FC3F7))
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Session info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSessionInfo('Session', '1 / 4'),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF2A2A4A),
                  ),
                  _buildSessionInfo('Focus', '25 min'),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF2A2A4A),
                  ),
                  _buildSessionInfo('Break', '5 min'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Today's Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Stats",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.timer_outlined,
                          '2h 15m',
                          'Total Focus',
                          const Color(0xFF4FC3F7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.check_circle_outline,
                          '5',
                          'Sessions',
                          const Color(0xFF81C784),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4FC3F7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8D8D8D),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8D8D8D),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TimerPainter - Draws the circular progress ring
// =============================================================================
class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const strokeWidth = 8.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// VideosView - Grid of recorded videos
// =============================================================================
class VideosView extends StatefulWidget {
  const VideosView({super.key});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Sort / Filter row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Recent', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Videos grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildVideoCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF8D8D8D),
        ),
      ),
    );
  }

  Widget _buildVideoCard(int index) {
    final dates = [
      '2026/03/09',
      '2026/03/08',
      '2026/03/07',
      '2026/03/06',
      '2026/03/05',
      '2026/03/04',
    ];
    final durations = [
      '25:00',
      '50:00',
      '25:00',
      '25:00',
      '50:00',
      '25:00',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A4A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Video info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Color(0xFF8D8D8D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      durations[index],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dates[index],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ShootScreen - Camera / TimeLapse recording screen
// =============================================================================
class ShootScreen extends StatefulWidget {
  const ShootScreen({super.key});

  @override
  State<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends State<ShootScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Focus Lapse',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Camera preview area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2A2A4A),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Camera placeholder
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Preview',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Recording indicator
                  if (_isRecording)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE57373),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'REC',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Timer overlay (top right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '00:00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flip camera
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16213E),
                    border: Border.all(
                      color: const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                // Record button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isRecording ? 28 : 56,
                        height: _isRecording ? 28 : 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE57373),
                          borderRadius: _isRecording
                              ? BorderRadius.circular(6)
                              : BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
                // Settings
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16213E),
                    border: Border.all(
                      color: const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SnsScreen - Social feed with posts
// =============================================================================
class SnsScreen extends StatefulWidget {
  const SnsScreen({super.key});

  @override
  State<SnsScreen> createState() => _SnsScreenState();
}

class _SnsScreenState extends State<SnsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Focus Lapse',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF16213E),
                    border: Border.all(
                      color: const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildPostCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final userNames = [
      'Taro Yamada',
      'Hanako Suzuki',
      'Kenji Tanaka',
      'Yuki Sato',
      'Rina Watanabe',
    ];
    final focusTimes = [
      '2h 30m',
      '1h 45m',
      '3h 10m',
      '0h 55m',
      '4h 20m',
    ];
    final sessions = ['6', '4', '8', '2', '10'];
    final timeAgo = [
      '5 min ago',
      '1h ago',
      '3h ago',
      '5h ago',
      'Yesterday',
    ];
    final comments = [
      'Great focus session today!',
      'Finally finished my assignment.',
      'Productive morning session.',
      'Short but effective!',
      'New personal record!',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    const Color(0xFF4FC3F7),
                    const Color(0xFF81C784),
                    index / 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    userNames[index][0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userNames[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      timeAgo[index],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_horiz,
                color: Color(0xFF8D8D8D),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            comments[index],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Video thumbnail
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                size: 48,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPostStat(
                    Icons.timer_outlined, focusTimes[index], 'Focus'),
                Container(
                  width: 1,
                  height: 30,
                  color: const Color(0xFF2A2A4A),
                ),
                _buildPostStat(
                    Icons.check_circle_outline, sessions[index], 'Sessions'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, 'Like'),
              const SizedBox(width: 24),
              _buildActionButton(Icons.chat_bubble_outline, 'Comment'),
              const SizedBox(width: 24),
              _buildActionButton(Icons.share_outlined, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4FC3F7)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8D8D8D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8D8D8D)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8D8D8D),
          ),
        ),
      ],
    );
  }
}

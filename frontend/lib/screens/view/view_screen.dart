import 'package:flutter/material.dart';
import '../../widgets/common/app_bar.dart';
import 'pomodoro_screen.dart';
import 'videos_screen.dart';

class ViewScreen extends StatelessWidget {
  final int subTab;

  const ViewScreen({super.key, required this.subTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FocusAppBar(
          title: subTab == 0 ? 'View - Pomodoro' : 'View - Videos',
        ),
        Expanded(
          child: subTab == 0 ? const PomodoroView() : const VideosView(),
        ),
      ],
    );
  }
}

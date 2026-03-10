import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'session_repository.dart';

const _pomoDurationSec = 25 * 60; // 25分

class PomodoroNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _timer;

  PomodoroNotifier(this._ref) : super(_pomoDurationSec);

  void start() {
    _timer?.cancel();
    state = _pomoDurationSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state <= 1) {
        _timer?.cancel();
        state = 0;
        _onComplete();
      } else {
        state = state - 1;
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = _pomoDurationSec;
  }

  Future<void> _onComplete() async {
    await NotificationService.showPomodoroComplete();
    await _ref.read(sessionRepositoryProvider).postSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider =
    StateNotifierProvider<PomodoroNotifier, int>(
  (ref) => PomodoroNotifier(ref),
);

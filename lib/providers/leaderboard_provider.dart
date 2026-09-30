import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/progress_repository.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider(this._repository) {
    _subscription = _repository.watchLeaderboard().listen((value) {
      _entries = value;
      notifyListeners();
    });
  }

  final ProgressRepository _repository;
  StreamSubscription<List<LeaderboardEntry>>? _subscription;

  List<LeaderboardEntry> _entries = const [];
  List<LeaderboardEntry> get entries => _entries;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

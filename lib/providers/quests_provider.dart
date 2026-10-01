import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/progress_repository.dart';
import '../models/weekly_quest.dart';

class QuestsProvider extends ChangeNotifier {
  QuestsProvider(this._repository);

  final ProgressRepository _repository;
  StreamSubscription<List<WeeklyQuest>>? _subscription;
  String? _userId;

  List<WeeklyQuest> _quests = const [];
  List<WeeklyQuest> get quests => _quests;

  void watchUser(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _subscription = _repository.watchQuests(userId).listen((value) {
      _quests = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

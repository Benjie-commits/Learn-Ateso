import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/progress_repository.dart';
import '../models/user_progress.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);

  final ProgressRepository _repository;
  StreamSubscription<UserProgress>? _subscription;
  String? _userId;

  UserProgress _progress = UserProgress.empty();
  UserProgress get progress => _progress;

  void watchUser(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _subscription = _repository.watchProgress(userId).listen((value) {
      _progress = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

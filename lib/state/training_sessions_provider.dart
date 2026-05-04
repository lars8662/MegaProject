import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_session.dart';

final trainingSessionsProvider = NotifierProvider<TrainingSessionsNotifier, List<TrainingSession>>(
  TrainingSessionsNotifier.new,
);

class TrainingSessionsNotifier extends Notifier<List<TrainingSession>> {
  @override
  List<TrainingSession> build() => const [];

  void addSession(TrainingSession session) {
    state = [session, ...state];
  }
}

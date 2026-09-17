import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  /// Short single buzz — used when saving a task
  static Future<void> onSave() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  /// Double short buzz — used when deleting a task
  static Future<void> onDelete() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 80, 100, 80]);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  /// Long satisfying buzz — used when completing a task
  static Future<void> onComplete() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 400);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }
}
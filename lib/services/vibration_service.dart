import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  static Future<bool> _canVibrate() async {
    try {
      return await Vibration.hasVibrator() == true;
    } catch (e) {
      debugPrint('Vibration check error: $e');
      return false;
    }
  }

  /// Short single buzz — used when saving a task
  static Future<void> onSave() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  /// Double short buzz — used when deleting a task
  static Future<void> onDelete() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(pattern: [0, 80, 100, 80]);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  /// Long satisfying buzz — used when completing a task
  static Future<void> onComplete() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(duration: 400);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }
}

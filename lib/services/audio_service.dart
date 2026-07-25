import 'package:flutter/services.dart';

class AudioService {
  /// Trigger haptic & system alert sound on successful scan
  static Future<void> playScanSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignore audio errors on unsupported platforms
    }
  }
}

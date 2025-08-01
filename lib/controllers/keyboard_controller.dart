import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardController {
  final VoidCallback onToggleFullScreen;
  final VoidCallback onExitFullScreen;
  final VoidCallback onPreviousSlide;
  final VoidCallback onNextSlide;
  final VoidCallback onTogglePlayPause;

  KeyboardController({
    required this.onToggleFullScreen,
    required this.onExitFullScreen,
    required this.onPreviousSlide,
    required this.onNextSlide,
    required this.onTogglePlayPause,
  });

  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isMetaPressed &&
          event.logicalKey == LogicalKeyboardKey.keyF) {
        onToggleFullScreen();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        onExitFullScreen();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        onPreviousSlide();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        onNextSlide();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        onTogglePlayPause();
        return true;
      }
    }
    return false;
  }

  void setupKeyboardShortcuts() {
    HardwareKeyboard.instance.addHandler(handleKeyEvent);
  }

  void dispose() {
    HardwareKeyboard.instance.removeHandler(handleKeyEvent);
  }
} 
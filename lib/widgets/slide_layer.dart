import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import '../slide_item.dart';
import '../animations/slideshow_animations.dart';

class SlideLayer extends StatelessWidget {
  final String folderPath;
  final SlideItem slideData;
  final bool isTransitioning;
  final bool isCurrentSlide;
  final SlideshowAnimations animations;

  const SlideLayer({
    super.key,
    required this.folderPath,
    required this.slideData,
    required this.isTransitioning,
    required this.isCurrentSlide,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = path.join(folderPath, slideData.image);
    final scale = slideData.scale ?? 1.0;
    final pan = slideData.pan;

    final shouldPan = scale > 1.0 && pan != null && (isCurrentSlide || !isCurrentSlide);

    Widget imageWidget = Stack(
      children: [
        // Background blurred image
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // Main image
        Positioned.fill(
          child: Center(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );

    // Apply scale transformation
    if (scale != 1.0) {
      imageWidget = Transform.scale(
        scale: scale,
        child: imageWidget,
      );
    }

    // Apply pan transformation
    if (shouldPan) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final windowSize = MediaQuery.of(context).size;
          final panOffset = animations.getPanOffset(slideData, isTransitioning, isCurrentSlide);

          if (panOffset != null) {
            final pixelOffset = Offset(
              panOffset.dx * windowSize.width,
              panOffset.dy * windowSize.height,
            );

            return Transform.translate(
              offset: pixelOffset,
              child: imageWidget,
            );
          }

          return imageWidget;
        },
      );
    }

    return imageWidget;
  }
} 
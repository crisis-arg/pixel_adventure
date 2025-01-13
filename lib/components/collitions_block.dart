import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;

  CollisionsBlock({
    this.isPlatform = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        ) {
    debugMode = true;
    if (isPlatform) {
      debugColor = Colors.green;
    }
  }
}
